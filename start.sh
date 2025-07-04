#!/bin/bash
set -e

# (1) huggingface_hub 설치 — 이미 설치되어 있으면 skip 됨
pip install --no-cache-dir huggingface_hub

# (2) HF 토큰 설정 (RunPod 대시보드에서 HF_TOKEN 환경변수로 등록)
export HUGGINGFACE_TOKEN="${HF_TOKEN}"

# (3) 자동 다운로드
python - <<'EOF'
import os
from huggingface_hub import snapshot_download

# repo_id 와 로컬 저장 디렉토리, 그리고 받아올 파일명 리스트
models = {
  "city96/Wan2.1-I2V-14B-480P-gguf": {
    "local_dir": "models/checkpoints",
    "patterns": ["wan2.1-i2v-14b-480p-Q8_0.gguf"]
  },
  "alibaba-pai/Wan2.1-Fun-Reward-LoRAs": {
    "local_dir": "models/lora",
    "patterns": ["Wan2.1-Fun-14B-InP-MPS.safetensors"]
  },
  "Kijai/WanVideo_comfy": {
    "local_dir": "models/lora",
    "patterns": ["Wan21_AccVid_I2V_480P_14B_lora_rank32_fp16.safetensors"]
  }
}

for repo_id, cfg in models.items():
  ld = cfg["local_dir"]
  os.makedirs(ld, exist_ok=True)
  print(f"[HF ↓] {repo_id} → {ld}  files: {cfg['patterns']}")
  snapshot_download(
    repo_id=repo_id,
    repo_type="model",
    local_dir=ld,
    token=os.environ["HUGGINGFACE_TOKEN"],
    allow_patterns=cfg["patterns"],
    resume_download=True
  )
EOF

# (4) ComfyUI 실행 — 기존에 쓰시던 명령 그대로
exec python launch.py --listen 0.0.0.0 --port "$PORT"