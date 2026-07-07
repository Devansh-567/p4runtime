#!/usr/bin/env bash
# Copyright 2025 Steffen Smolka
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

#
# Updates proto/google/rpc/status.proto with the latest version from the
# official upstream repository.
#
# The file is very stable and hasn't changed in many years, but we enforce
# freshness of this copy using a GitHub Actions workflow just in case.

set -eu

STATUS_PROTO_URL="https://raw.githubusercontent.com/googleapis/googleapis/refs/heads/master/google/rpc/status.proto"
THIS_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
DEST_FILE="$THIS_DIR/google/rpc/status.proto"

TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

if command -v curl >/dev/null 2>&1; then
    curl -fLsS "$STATUS_PROTO_URL" -o "$TMP_FILE"
elif command -v wget >/dev/null 2>&1; then
    wget -q "$STATUS_PROTO_URL" -O "$TMP_FILE"
else
    echo "Neither curl nor wget is available to download status.proto" >&2
    exit 1
fi

# Basic sanity check: make sure we actually got a .proto file and not, say,
# an HTML error/rate-limit page served with a 200-ish status.
if ! grep -q '^syntax' "$TMP_FILE"; then
    echo "Downloaded file does not look like a valid .proto file (missing 'syntax' line); aborting" >&2
    exit 1
fi

mv "$TMP_FILE" "$DEST_FILE"
