#!/bin/bash
# /usr/local/bin/deploy_milvus.sh
APP_DIR="/home/milvus_api_server"
SERVICE1="milvus_insert.service"
SERVICE2="milvus_search.service"
TAG="$1"

echo "[INFO] Deploying tag $TAG ..."

cd $APP_DIR || exit 1

git fetch --all
git checkout "tags/$TAG" -f

systemctl restart $SERVICE1
systemctl restart $SERVICE2

echo "[INFO] Deploy complete."


