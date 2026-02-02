#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST=${1:-protected}
TARGET_PORT=${2:-8080}

curl -i "http://${TARGET_HOST}:${TARGET_PORT}/admin"
