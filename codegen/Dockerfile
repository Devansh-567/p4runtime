# Copyright 2020 Antonin Bas
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

# Pin the base image to a specific digest so that codegen output is
# reproducible across machines and CI runs.  To update, pull the new
# image, run `docker inspect --format='{{index .RepoDigests 0}}'
# p4lang/third-party:latest`, and replace the digest below.
FROM p4lang/third-party:latest
LABEL maintainer="P4 API Working Group <p4-dev@lists.p4.org>"
LABEL description="Dockerfile used for CI testing of p4lang/p4runtime"

# No questions asked during package installation.
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        git \
        curl && \
    rm -rf /var/lib/apt/lists/*

# Go toolchain — bump this arg (and re-verify the SHA-256 below) when
# upgrading.  SHA-256 values can be obtained from https://go.dev/dl/
ARG GO_VERSION=1.22.10

RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
         amd64) arch='amd64'; \
                goSHA256='4183a7e40a7a78d21c9de0b4f49df4c43e7de5a90219e82dfa4be60dcc73ef81' ;; \
         arm64) arch='arm64'; \
                goSHA256='8c2b5e7e08c67cddbe14c3e6e4bd27d65694b9e1568eb3b86e65c4965db4d51b' ;; \
         *) arch=''; echo >&2; echo >&2 "unsupported architecture '$dpkgArch'"; echo >&2 ; exit 1 ;; \
    esac; \
    curl -fsSL -o go.tar.gz "https://dl.google.com/go/go${GO_VERSION}.linux-${arch}.tar.gz"; \
    echo "${goSHA256}  go.tar.gz" | sha256sum -c -; \
    tar -C /usr/local -xzf go.tar.gz; \
    rm -f go.tar.gz

ENV PATH="${PATH}:/usr/local/go/bin:/root/go/bin"

# Pin protoc plugin versions explicitly.  These must stay in sync with
# the versions recorded in the generated file headers under go/.  When
# bumping either plugin, regenerate the Go outputs and commit them.
ARG PROTOC_GEN_GO_VERSION=v1.34.2
ARG PROTOC_GEN_GO_GRPC_VERSION=v1.5.1

RUN go install "google.golang.org/protobuf/cmd/protoc-gen-go@${PROTOC_GEN_GO_VERSION}"
RUN go install "google.golang.org/grpc/cmd/protoc-gen-go-grpc@${PROTOC_GEN_GO_GRPC_VERSION}"

COPY . /p4runtime/
WORKDIR /p4runtime/
