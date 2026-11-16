# ComfyUI for servers without a graphics card (CPU only, slow).
# Needs about 8 GB of RAM to generate even small images; ./stack refuses to
# enable it on smaller servers unless you pass --force.
FROM python:3.12-slim-bookworm

ARG COMFYUI_REF=master

RUN apt-get update \
  && apt-get install -y --no-install-recommends git \
  && rm -rf /var/lib/apt/lists/* \
  && useradd --create-home --uid 1000 comfy

RUN git clone --depth 1 --branch "${COMFYUI_REF}" https://github.com/Comfy-Org/ComfyUI.git /opt/ComfyUI

# CPU builds of PyTorch first: requirements.txt leaves torch unpinned, so pip
# keeps these instead of downloading the much larger CUDA builds.
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu \
  && pip install --no-cache-dir -r /opt/ComfyUI/requirements.txt \
  && chown -R comfy:comfy /opt/ComfyUI

USER comfy
WORKDIR /opt/ComfyUI
EXPOSE 8188
CMD ["python", "main.py", "--cpu", "--listen", "0.0.0.0", "--port", "8188", "--disable-auto-launch"]
