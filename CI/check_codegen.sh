#!/usr/bin/env bash
# Copyright 2020 Yi Tseng
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


set -eo pipefail

THIS_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

pushd "$THIS_DIR/.." >/dev/null

rm -rf go/*
rm -rf py/p4
./codegen/update.sh

go_diff="$(git diff --name-only go/ go.mod go.sum)"

# Ensure generated Go files are up-to-date
if [ -n "$go_diff" ]; then
    echo "ERROR: The generated Go files are not up-to-date."
    echo "Run './codegen/update.sh' locally and commit the result."
    echo ""
    echo "Diff:"
    echo "$go_diff"
    exit 1
fi

py_diff="$(git diff --name-only py/)"

if [ -n "$py_diff" ]; then
    echo "ERROR: The generated Python files are not up-to-date."
    echo "Run './codegen/update.sh' locally and commit the result."
    echo ""
    echo "Diff:"
    echo "$py_diff"
    exit 1
fi

echo "Codegen check passed: all generated files are up-to-date."

popd >/dev/null
