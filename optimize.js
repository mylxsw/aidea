import fs from "fs";
import path from "path";
import { glob } from "glob";
import crypto from "crypto";
import { minify_sync } from "terser";
import { exec } from "child_process";
import { transform } from "@babel/core";
import { program, Option } from "commander";

program
  .command("build")
  .requiredOption("-p, --project <string>", "project name") // 要打包的项目名
  .addOption(
    new Option("-e, --env <string>", "dev or prod environment") // 运行的环境
      .choices(["dev", "prod"])
      .default("dev")
  )
  .addOption(
    new Option("--web-renderer <string>", "web renderer mode") // 渲染方式
      .choices(["auto", "html", "canvaskit"])
      .default("auto")
  )
  .action((cmd) => {
    build(cmd);
  });
program.parse(process.argv);

/**
 * @param {{ project: string, env: string, webRenderer: string }} args
 */
function build(args) {
  // 要打包的项目路劲
  const buildTargetPath = path.resolve(`./lib/${args.project}`);
  // 打包文件输出位置，如：build/dev/project_1
  const buildOutPath = path.resolve(`./build/web`);
  // 见下方解释，具体根据部署路劲设置
  const baseHref = `/`;

  const hashFileMap = new Map();
  const mainDartJsFileMap = {};
  
  // 删除原打包文件
  fs.rmSync(buildOutPath, { recursive: true, force: true });

  // 打包命令 -o 指定输出位置
  // --release 构建发布版本，有对代码进行混淆压缩等优化
  // --pwa-strategy none 不使用 pwa
  const commandStr = `fvm flutter build web --base-href ${baseHref} --web-renderer ${args.webRenderer} --release --pwa-strategy none --dart-define=INIT_ENV=${args.env} `;

  exec(
    commandStr,
    {
      cwd: buildTargetPath,
    },
    async (error, stdout, stderr) => {
      if (error) {
        console.error(`exec error: ${error}`);
        console.error(`error stack: ${error.stack}`);
        return;
      }
      console.log(`stdout: ${stdout}`);

      replaceGoogleResource();
      splitFile();
      await hashFile();
      insertLoadChunkScript();

      if (stderr) {
        console.error(`stderr: ${stderr}`);
        return;
      }
    }
  );

  // 替换 Google 资源为国内镜像资源
  function replaceGoogleResource() {
    const filesToReplace = [
      path.resolve(buildOutPath, './main.dart.js'),
      path.resolve(buildOutPath, './flutter.js'),
      path.resolve(buildOutPath, './flutter_bootstrap.js')
    ];
    
    filesToReplace.forEach(targetFile => {
      if (fs.existsSync(targetFile)) {
        let data = fs.readFileSync(targetFile, 'utf8');
        
        // 替换字体、CanvasKit 为国内镜像
        data = data.replace(/fonts\.gstatic\.com/g, 'global-cdn.aicode.cc');
        data = data.replace(/www\.gstatic\.com/g, 'global-cdn.aicode.cc');
        
        fs.writeFileSync(targetFile, data, 'utf8');
        console.log(`Google resources replaced successfully in ${path.basename(targetFile)}`);
      } else {
        console.log(`File not found: ${targetFile}, skipping replacement`);
      }
    });
  }

  // 对 main.dart.js 进行分片
  function splitFile() {
    const chunkCount = 5; // 分片数量

    const targetFile = path.resolve(buildOutPath, `./main.dart.js`);
    const fileData = fs.readFileSync(targetFile, "utf8");
    const fileDataLen = fileData.length;
    const eachChunkLen = Math.floor(fileDataLen / chunkCount);
    for (let i = 0; i < chunkCount; i++) {
      const start = i * eachChunkLen;
      const end = i === chunkCount - 1 ? fileDataLen : (i + 1) * eachChunkLen;
      const chunk = fileData.slice(start, end);
      const chunkFilePath = path.resolve(
        `./build/web/main.dart_chunk_${i}.js`
      );
      fs.writeFileSync(chunkFilePath, chunk);
    }
    fs.unlinkSync(targetFile);
  }

  // 文件名添加 hash 值
  async function hashFile() {
    const files = await glob(
      ["**/main.dart@(*).js"],
      // ["**/images/**.*", "**/*.{otf,ttf}", "**/main.dart@(*).js"],
      {
        cwd: buildOutPath,
        nodir: true,
      }
    );
    // console.log(files);
    for (let i = 0; i < files.length; i++) {
      const oldFilePath = path.resolve(buildOutPath, files[i]);
      const newFilePath =
        oldFilePath.substring(
          0,
          oldFilePath.length - path.extname(oldFilePath).length
        ) +
        "." +
        getFileMD5({ filePath: oldFilePath }) +
        path.extname(oldFilePath);
      fs.renameSync(oldFilePath, newFilePath);
      const oldFileName = path.basename(oldFilePath);
      const newFileName = path.basename(newFilePath);
      hashFileMap.set(oldFileName, {
        oldFilePath,
        newFilePath,
        newFileName,
      });
      if (oldFileName.includes("main.dart_chunk"))
        mainDartJsFileMap[oldFileName] = newFileName;
    }
  }

  /**
   * 获取文件的 md5 值
   * @param {{fileContent?: string, filePath?: string}} options
   * @returns {string}
   */
  function getFileMD5(options) {
    const { fileContent, filePath } = options;
    const _fileContent = fileContent || fs.readFileSync(filePath);
    const hash = crypto.createHash("md5");
    hash.update(_fileContent);
    return hash.digest("hex").substring(0, 8);
  }

  // 插入加载分片脚本
  function insertLoadChunkScript() {
    let loadChunkContent = fs
      .readFileSync(path.resolve("./chunk.js"))
      .toString();
    loadChunkContent = loadChunkContent
      .replace(
        'const mainDartJsFileMapJSON = "{}";',
        `const mainDartJsFileMapJSON = '${JSON.stringify(mainDartJsFileMap)}';`
      )
      .replace("${baseHref}", `${baseHref}`);

    const parseRes = transform(loadChunkContent, {
      presets: ["@babel/preset-env"],
    });

    const terserRes = minify_sync(parseRes.code, {
      compress: true,
      mangle: true,
      output: {
        beautify: false,
        comments: false,
      },
    });

    if (!fs.existsSync(path.resolve(buildOutPath, "script")))
      fs.mkdirSync(path.resolve(buildOutPath, "script"));

    const loadChunkJsHash = getFileMD5({ fileContent: terserRes.code });

    fs.writeFileSync(
      path.resolve(buildOutPath, `./script/chunk.${loadChunkJsHash}.js`),
      Buffer.from(terserRes.code)
    );

    // 替换 flutter.js 里的 _createScriptTag
    const pattern = /_createScriptTag\([\w,]+\){(.*?)}/;
    const flutterJsPath = path.resolve(buildOutPath, "./flutter.js");
    let flutterJsContent = fs.readFileSync(flutterJsPath).toString();
    flutterJsContent = flutterJsContent.replace(pattern, (match, p1) => {
      return `_createScriptTag(){let t=document.createElement("script");t.type="application/javascript";t.src='${baseHref}script/chunk.${loadChunkJsHash}.js';return t}`;
    });
    // flutter js 加 hash
    fs.writeFileSync(flutterJsPath, Buffer.from(flutterJsContent));
    const flutterJsHashName = `flutter.${getFileMD5({
      fileContent: flutterJsContent,
    })}.js`;
    fs.renameSync(flutterJsPath, path.resolve(buildOutPath, flutterJsHashName));
    // 替换 index.html 内容
    const bridgeScript = `<script src="${flutterJsHashName}" defer></script>`;
    const htmlPath = path.resolve(buildOutPath, "./index.html");
    let htmlText = fs.readFileSync(htmlPath).toString();

    const headEndIndex = htmlText.indexOf("</head>");
    htmlText =
      htmlText.substring(0, headEndIndex) +
      bridgeScript +
      htmlText.substring(headEndIndex);

    htmlText = htmlText.replace(`<script src="flutter.js" defer=""></script>`, "");

    fs.writeFileSync(htmlPath, Buffer.from(htmlText));
  }
}
