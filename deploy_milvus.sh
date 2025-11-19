#!/bin/bash
# /usr/local/bin/deploy_milvus.sh
APP_DIR="/home/milvus_server"
SERVICE="milvus_server.service"
TAG="$1"

echo "[INFO] Deploying tag $TAG ..."

cd $APP_DIR || exit 1

git fetch --all
git checkout "tags/$TAG" -f

systemctl restart $SERVICE

echo "[INFO] Deploy complete."
