set -ex
export ROOT_DIR=$(pwd)
export DEPS_DIR=$ROOT_DIR/deps
mkdir -p $DEPS_DIR
pushd $DEPS_DIR
wget https://github.com/NVIDIA/gdrcopy/archive/refs/tags/v2.4.4.tar.gz
# unzip to gdrcopy_src
mkdir -p gdrcopy_src
tar -xvf v2.4.4.tar.gz -C gdrcopy_src --strip-components=1
pushd gdrcopy_src
make -j$(nproc)
sudo make prefix=$DEPS_DIR/gdrcopy_install install
popd

# unzip to nvshmem_src
mkdir -p nvshmem_src
# nvshmem_src_3.1.7-1.txz comes from https://developer.nvidia.com/downloads/assets/secure/nvshmem/nvshmem_src_3.1.7-1.txz
cp $ROOT_DIR/nvshmem_src_3.1.7-1.txz nvshmem_src_3.1.7-1.txz
tar -xvf nvshmem_src_3.1.7-1.txz -C nvshmem_src --strip-components=1
pushd nvshmem_src
wget https://github.com/deepseek-ai/DeepEP/raw/main/third-party/nvshmem.patch
git init
git apply nvshmem.patch

# assume CUDA_HOME is set correctly
GDRCOPY_HOME=$DEPS_DIR/gdrcopy_install \
NVSHMEM_SHMEM_SUPPORT=0 \
NVSHMEM_UCX_SUPPORT=0 \
NVSHMEM_USE_NCCL=0 \
NVSHMEM_IBGDA_SUPPORT=1 \
NVSHMEM_PMIX_SUPPORT=0 \
NVSHMEM_TIMEOUT_DEVICE_POLLING=0 \
NVSHMEM_USE_GDRCOPY=1 \
cmake -S . -B $DEPS_DIR/nvshmem_build/ -DCMAKE_INSTALL_PREFIX=$DEPS_DIR/nvshmem_install

cd $DEPS_DIR/nvshmem_build/
make -j$(nproc)
make install

cd $ROOT_DIR
cp -r $DEPS_DIR/nvshmem_install $ROOT_DIR/vllm_nvshmem
touch $ROOT_DIR/vllm_nvshmem/__init__.py
touch $ROOT_DIR/vllm_nvshmem/include/__init__.py
touch $ROOT_DIR/vllm_nvshmem/lib/__init__.py
touch $ROOT_DIR/vllm_nvshmem/share/__init__.py
