#!/usr/bin/env bash

VERSION=1.0.6
VERSION_DATE=202310091100

rm -fr build/web

flutter build web --web-renderer canvaskit --release --dart-define=API_SERVER_URL=/
cd scripts && go run main.go ../build/web/main.dart.js && cd ..
rm -fr build/web/fonts/ && mkdir build/web/fonts
cp -r scripts/s build/web/fonts/s

docker build -t mylxsw/aidea-web:$VERSION .
docker tag mylxsw/aidea-web:$VERSION mylxsw/aidea-web:$VERSION_DATE
docker tag mylxsw/aidea-web:$VERSION mylxsw/aidea-web:latest

docker push mylxsw/aidea-web:$VERSION
docker push mylxsw/aidea-web:$VERSION_DATE
docker push mylxsw/aidea-web:latest

