
ipa:
	flutter build ipa --no-tree-shake-icons --release 
	open build/ios/ipa

run:
	flutter run --release 

build-all: build-android ipa

build-android:
	flutter build apk --release --no-tree-shake-icons
	# open build/app/outputs/flutter-apk
	mv build/app/outputs/flutter-apk/app-release.apk /Users/mylxsw/ResilioSync/ResilioSync/临时文件/aidea-release.apk

build-macos:
	flutter build macos --no-tree-shake-icons --release
	codesign -f -s "Developer ID Application: YIYAO  GUAN (N95437SZ2A)" build/macos/Build/Products/Release/AIdea.app

build-appimage:
	flutter build linux --no-tree-shake-icons --release 
	mkdir -p aidea_app.AppDir
	cp -r build/linux/x64/release/bundle/* aidea_app.AppDir
	cp assets/app.png aidea_app.AppDir/
	cp AppRun aidea_app.AppDir/
	cp askaide.desktop aidea_app.AppDir/
	appimagetool aidea_app.AppDir/

build-dmg: build-macos
	rm -fr build/macos/Build/Products/Package
	mkdir -p build/macos/Build/Products/Package && cp -r build/macos/Build/Products/Release/AIdea.app build/macos/Build/Products/Package
	create-dmg --volname "AIdea Installer" \
		--volicon "install.icns" \
		--background "assets/background-discovery.png" \
		--window-pos 200 120 \
		--window-size 600 320 \
		--icon-size 100 \
		--icon "AIdea.app" 170 130 \
		--hide-extension "AIdea.app" \
		--app-drop-link 430 130 \
		"build/macos/Build/Products/Package/AIdea-Installer.dmg" \
		"build/macos/Build/Products/Package"
	open build/macos/Build/Products/Package/

build-web:
	flutter build web --web-renderer canvaskit --release --dart-define=FLUTTER_WEB_CANVASKIT_URL=https://resources.aicode.cc/canvaskit/
	cd scripts && go run main.go ../build/web/main.dart.js && cd ..

build-web-samehost:
	flutter build web --web-renderer canvaskit --release --dart-define=API_SERVER_URL=/
	cd scripts && go run main.go ../build/web/main.dart.js && cd ..

deploy-web: build-web
	cd build && tar -zcvf web.tar.gz web
	scp build/web.tar.gz huawei-1:/data/webroot
	ssh huawei-1 "cd /data/webroot && tar -zxvf web.tar.gz && rm -rf web.tar.gz app && mv web app"
	rm -fr build/web.tar.gz

.PHONY: run build-android build-macos ipa build-web-samehost build-web deploy-web build-dmg
