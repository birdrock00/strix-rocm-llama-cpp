FROM ubuntu:24.04

EXPOSE 8080

# Install only what's needed
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg unzip libatomic1 libgomp1 libnuma1 && \
    rm -rf /var/lib/apt/lists/*

# Add ROCm 7.0 repo for minimal host-driver glue
# (the strix release zip already bundles HIP/rocBLAS/hipBLASLt/HSA libs;
#  this provides the kernel-facing runtime pieces)
RUN curl -fsSL https://repo.radeon.com/rocm/rocm.gpg.key | gpg --dearmor -o /usr/share/keyrings/rocm.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/7.0 noble main" \
        > /etc/apt/sources.list.d/rocm.list

# Install MINIMAL ROCm runtime (no dev tools!)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        hip-runtime-amd \
        comgr \
        hsa-rocr-dev \
        && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV ROCM_PATH=/opt/rocm
ENV PATH=$ROCM_PATH/bin:$PATH
ENV LD_LIBRARY_PATH=$ROCM_PATH/lib:$LD_LIBRARY_PATH

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
