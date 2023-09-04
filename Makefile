
ipa:
	flutter build ipa --no-tree-shake-icons --release 
	open build/ios/ipa

run:
	flutter run --release 

build-all: build-android ipa

build-android:
	flutter build apk --release --no-tree-shake-icons
	# open build/app/outputs/flutter-apk
	mv build/app/outputs/flutter-apk/app-release.apk /Users/mylxsw/ResilioSync/临时文件/

build-macos:
	flutter build macos --no-tree-shake-icons --release
	open build/macos/Build/Products/Release/

build-web:
	flutter build web --web-renderer canvaskit --release --pwa-strategy none --dart2js-optimization O4 --dart-define=FLUTTER_WEB_CANVASKIT_URL=https://resources.aicode.cc/canvaskit/
	cd scripts && go run main.go ../build/web/main.dart.js && cd ..
	rm -fr build/web/fonts/ && mkdir build/web/fonts
	cp -r scripts/s build/web/fonts/s

deploy-web: build-web
	cd build && tar -zcvf web.tar.gz web
	scp build/web.tar.gz huawei-1:/data/webroot
	ssh huawei-1 "cd /data/webroot && tar -zxvf web.tar.gz && rm -rf web.tar.gz app && mv web app"
	rm -fr build/web.tar.gz

.PHONY: run build-android build-macos ipa
