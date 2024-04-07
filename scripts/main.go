package main

import (
	"os"
	"strings"

	"github.com/mylxsw/asteria/log"
	"github.com/mylxsw/go-utils/must"
)

// 用于替换 Web 端的字体文件地址，将字体文件下载到本地，解决无法访问 Google 字体的问题
func main() {

	mainDartJSPath := os.Args[1]

	data := string(must.Must(os.ReadFile(mainDartJSPath)))
	// 替换字体为本地 CDN
	// fontRegex := regexp.MustCompile(`https://fonts\.gstatic\.com/(.*?)\.(ttf|otf|woff|woff2)`)

	// for _, u := range fontRegex.FindAllString(data, -1) {
	// 	savePath := must.Must(download(u))
	// 	data = strings.ReplaceAll(data, u, "https://resources.aicode.cc/fonts/"+savePath)
	// }

	// 替换字体为国内镜像
	data = strings.ReplaceAll(data, "fonts.gstatic.com", "global-cdn.aicode.cc")
	data = strings.ReplaceAll(data, "www.gstatic.com", "global-cdn.aicode.cc")

	// 替换字体为国内镜像
	data = strings.ReplaceAll(data, "fonts.gstatic.com", "fonts-gstatic.lug.ustc.edu.cn")

	must.NoError(os.WriteFile(mainDartJSPath, []byte(data), 0755))

	log.Debugf("replace font url success")
}

// func download(remoteURL string) (string, error) {
// 	savePath := strings.TrimPrefix(remoteURL, "https://fonts.gstatic.com/")
// 	//  检查目录是否存在，不存在则创建
// 	if err := os.MkdirAll(filepath.Dir(savePath), 0755); err != nil {
// 		return "", err
// 	}

// 	// 检查文件是否存在
// 	if _, err := os.Stat(savePath); err == nil {
// 		return savePath, nil
// 	}

// 	log.Debugf("download %s to %s", remoteURL, savePath)

// 	// 下载文件到本地
// 	resp, err := http.Get(remoteURL)
// 	if err != nil {
// 		return "", err
// 	}
// 	defer resp.Body.Close()

// 	f, err := os.Create(savePath)
// 	if err != nil {
// 		return "", err
// 	}
// 	defer f.Close()

// 	if _, err := io.Copy(f, resp.Body); err != nil {
// 		return "", err
// 	}

// 	return savePath, nil
// }
