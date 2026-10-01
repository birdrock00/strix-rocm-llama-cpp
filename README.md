# strix-rocm-llama-cpp

Container image for `llama-server` from
[halo-box/strix-llama.cpp](https://github.com/halo-box/strix-llama.cpp) —
the Strix Halo (gfx1151) optimized llama.cpp fork — packaged for Kubernetes
serving on AMD Strix Halo APUs.

## Layout

- Base: `ubuntu:24.04` + minimal ROCm 7.0 runtime (`hip-runtime-amd`,
  `comgr`, `hsa-rocr-dev`).
- `llama-server` and friends come from the upstream per-merge release asset
  `llama-<TAG>-ubuntu-rocm-gfx1151-x64.zip`, which already bundles the
  HIP/rocBLAS/hipBLASLt/HSA shared libraries.
- The daily workflow queries the latest
  [strix-llama.cpp release](https://github.com/halo-box/strix-llama.cpp/releases)
  and rebuilds automatically, so `latest` tracks the fork. To pin a build,
  use the `STRIX_TAG` (`ARG` in the Dockerfile, e.g. `b1005`).

## Build

```sh
podman build --build-arg STRIX_TAG=b1005 -t strix-rocm-llama-cpp:b1005 .
```

## Run

The image expects GGUF model file(s) mounted at `/models` and the Strix Halo
device nodes (`/dev/kfd`, `/dev/dri`) from the host. See the
[strix-llama.cpp issues](https://github.com/halo-box/strix-llama.cpp/issues)
for recommended `llama-server` flags (MTP speculative decoding, `dio`
load mode with `on-direct` lazy mode, `f16` KV cache) for Qwen3.8-Flash-Next
class models.
