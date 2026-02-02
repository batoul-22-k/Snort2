#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST=${1:-protected}
TARGET_PORTS=${2:-1-100}

nmap -sS -p "${TARGET_PORTS}" "${TARGET_HOST}"
