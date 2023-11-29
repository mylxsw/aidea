#!/usr/bin/env bash

VERSION=1.0.9

rm -fr build/web

flutter build web --web-renderer canvaskit --release --dart-define=API_SERVER_URL=/
cd scripts && go run main.go ../build/web/main.dart.js && cd ..
rm -fr build/web/fonts/ && mkdir build/web/fonts
cp -r scripts/s build/web/fonts/s

docker buildx build --platform=linux/amd64,linux/arm64 -t mylxsw/aidea-web:$VERSION . --push

