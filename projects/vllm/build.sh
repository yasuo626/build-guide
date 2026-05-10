#!/bin/bash
source /etc/profile

DEPLOY_PATH="${1:-$HOME/projects/vllm}"
CONDA_ENV_NAME="vllm"
PYTHON_VERSION="3.11"

mkdir -p "$DEPLOY_PATH"

cd $DEPLOY_PATH

if [ ! -d "vllm" ]; then
    git clone https://github.com/vllm-project/vllm.git
fi

# conda init
source /opt/Anaconda3/etc/profile.d/conda.sh

if ! conda env list | grep -q "^$CONDA_ENV_NAME "; then
    echo Creating new conda environment $CONDA_ENV_NAME...
    conda create -n $CONDA_ENV_NAME python=$PYTHON_VERSION -y
fi

conda activate $CONDA_ENV_NAME

# if ! command -v uv &> /dev/null; then
#     echo "uv not found, installing..."
#     curl -LsSf https://astral.sh/uv/install.sh | sh
#     source $HOME/.local/bin/env
# fi

# which uv
# uv --version
which python
which pip
python --version
nvcc -V

python -m pip install --upgrade pip
# --force-reinstall --no-cache-dir
python -m pip install torch==2.11+cu128 torchvision==0.26.0+cu128 torchaudio==2.11+cu128 --index-url https://download.pytorch.org/whl/cu128 --extra-index-url https://pypi.tuna.tsinghua.edu.cn/simple
python -m pip install setuptools_scm
python -c "import torch; print(torch.__version__)"

export VLLM_MAIN_CUDA_VERSION="cu128"
python use_existing_torch.py

export MAX_JOBS=8 # may crash if set too high
export NVCC_THREADS=2
python -m pip install --no-build-isolation -e . -i https://pypi.tuna.tsinghua.edu.cn/simple

echo "vllm deployed to: $DEPLOY_PATH"
exit 0
