FROM ubuntu:24.04

EXPOSE 8080

# Install only what's needed to fetch and run the release.
# NOTE: no system ROCm stack is installed on purpose. The strix-llama.cpp
# release zip is self-contained (HIP, HSA, rocBLAS, hipBLASLt with $ORIGIN
# RPATH, same layout as lemonade-sdk/llamacpp-rocm releases, which run
# without a host ROCm install). A distro ROCm runtime (e.g. hsa-rocr from
# the ROCm apt repo) ships an older libhsa-runtime that shadows the
# bundled one via LD_LIBRARY_PATH and segfaults in hsa init on gfx1151
# (observed: libhsa-runtime64.so.1.18 vs bundled 1.21). The host only
# needs the amdgpu kernel driver (/dev/kfd, /dev/dri).
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates curl unzip libatomic1 libgomp1 libnuma1 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN mkdir -p /models

# halo-box/strix-llama.cpp prebuilt ROCm release for gfx1151 (Strix Halo).
# Bump STRIX_TAG to track new per-merge releases:
# https://github.com/halo-box/strix-llama.cpp/releases
ARG STRIX_TAG=b1005
RUN curl -L -o llama.zip "https://github.com/halo-box/strix-llama.cpp/releases/download/${STRIX_TAG}/llama-${STRIX_TAG}-ubuntu-rocm-gfx1151-x64.zip" && \
    unzip llama.zip && \
    rm llama.zip && \
    chmod +x ./llama-*
