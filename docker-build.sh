#!/usr/bin/env bash

VERSION=1.0.14

rm -fr build/web

flutter build web --web-renderer canvaskit --release --dart-define=API_SERVER_URL=/
docker buildx build --platform=linux/amd64,linux/arm64 -t mylxsw/aidea-web:$VERSION . --push

