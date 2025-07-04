#!/usr/bin/env bash
set -e

# ─────────────────────────────────────────────────────
# 1) 필요한 디렉토리 생성
# ─────────────────────────────────────────────────────
mkdir -p models/checkpoints models/lora

# ─────────────────────────────────────────────────────
# 2) Hugging Face 공개 모델 직접 다운로드 (wget)
# ─────────────────────────────────────────────────────
# 1) city96/Wan2.1-I2V-14B-480P-gguf
if [ ! -f models/checkpoints/wan2.1-i2v-14b-480p-Q8_0.gguf ]; then
  echo "[START.SH] Downloading wan2.1-i2v-14b-480p-Q8_0.gguf..."
  wget -q \
    https://huggingface.co/city96/Wan2.1-I2V-14B-480P-gguf/resolve/main/wan2.1-i2v-14b-480p-Q8_0.gguf \
    -O models/checkpoints/wan2.1-i2v-14b-480p-Q8_0.gguf
fi

# 2) alibaba-pai/Wan2.1-Fun-Reward-LoRAs
if [ ! -f models/lora/Wan2.1-Fun-14B-InP-MPS.safetensors ]; then
  echo "[START.SH] Downloading Wan2.1-Fun-14B-InP-MPS.safetensors..."
  wget -q \
    https://huggingface.co/alibaba-pai/Wan2.1-Fun-Reward-LoRAs/resolve/main/Wan2.1-Fun-14B-InP-MPS.safetensors \
    -O models/lora/Wan2.1-Fun-14B-InP-MPS.safetensors
fi

# 3) Kijai/WanVideo_comfy
if [ ! -f models/lora/Wan21_AccVid_I2V_480P_14B_lora_rank32_fp16.safetensors ]; then
  echo "[START.SH] Downloading Wan21_AccVid_I2V_480P_14B_lora_rank32_fp16.safetensors..."
  wget -q \
    https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_AccVid_I2V_480P_14B_lora_rank32_fp16.safetensors \
    -O models/lora/Wan21_AccVid_I2V_480P_14B_lora_rank32_fp16.safetensors
fi

# ─────────────────────────────────────────────────────
# 3) ComfyUI 서버 실행
# ─────────────────────────────────────────────────────
echo "[START.SH] Launching ComfyUI..."
exec python launch.py --listen 0.0.0.0 --port "$PORT"

