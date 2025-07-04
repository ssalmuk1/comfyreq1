#!/usr/bin/env bash
set -e

# ─────────────────────────────────────────────────────
# 1) GitHub 리포지토리 클론 (없으면)
# ─────────────────────────────────────────────────────
if [ ! -d /workspace/comfyreq1 ]; then
  echo "[START.SH] Cloning repo into /workspace/comfyreq1..."
  git clone https://github.com/ssalmuk1/comfyreq1.git /workspace/comfyreq1
fi

# 워크스페이스를 comfygui용 루트로 참조하려면, 아래처럼 심볼릭 링크를 걸어도 됩니다.
# ln -sfn /workspace/comfyreq1 /workspace

# ─────────────────────────────────────────────────────
# 2) 의존성 설치
# ─────────────────────────────────────────────────────
echo "[START.SH] Installing huggingface_hub if needed..."
pip install --no-cache-dir huggingface_hub

# ─────────────────────────────────────────────────────
# 3) 환경 변수 복사
# ─────────────────────────────────────────────────────
# RunPod 대시보드에서 HF_TOKEN 을 Secret으로 등록해 두시면 안전합니다
export HUGGINGFACE_TOKEN="${HF_TOKEN}"

# ─────────────────────────────────────────────────────
# 4) Hugging Face 모델 자동 다운로드
# ─────────────────────────────────────────────────────
echo "[START.SH] Downloading models from Hugging Face..."
python - <<'EOF'
import os
from huggingface_hub import snapshot_download

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
  local_dir = cfg["local_dir"]
  os.makedirs(local_dir, exist_ok=True)
  print(f"[HF ↓] {repo_id} → {local_dir} ({cfg['patterns']})")
  snapshot_download(
    repo_id=repo_id,
    repo_type="model",
    local_dir=local_dir,
    token=os.environ.get("HUGGINGFACE_TOKEN", None),
    allow_patterns=cfg["patterns"],
    resume_download=True
  )
EOF

# ─────────────────────────────────────────────────────
# 5) ComfyUI 실행
# ─────────────────────────────────────────────────────
echo "[START.SH] Launching ComfyUI..."
exec python launch.py --listen 0.0.0.0 --port "$PORT"
