function loadChunkScript(url) {
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open("get", url, true);
      xhr.onreadystatechange = () => {
        if (xhr.readyState == 4) {
          if ((xhr.status >= 200 && xhr.status < 300) || xhr.status == 304) {
            resolve(xhr.responseText);
          }
        }
      };
      xhr.onerror = reject;
      xhr.ontimeout = reject;
      xhr.send();
    });
  }
  
  let retryCount = 0;
  const mainDartJsFileMapJSON = "{}";
  const mainDartJsFileMap = JSON.parse(mainDartJsFileMapJSON);
  const promises = Object.keys(mainDartJsFileMap)
    .sort()
    .map((key) => `${baseHref}${mainDartJsFileMap[key]}`)
    .map(loadChunkScript);
  Promise.all(promises)
    .then((values) => {
      const contents = values.join("");
      const script = document.createElement("script");
      script.text = contents;
      script.type = "text/javascript";
  
      document.body.appendChild(script);
    })
    .catch(() => {
  
      if (++retryCount > 3) {
        console.error("load chunk fail");
      } else {
        _createScriptTag(url);
      }
    });
  
  