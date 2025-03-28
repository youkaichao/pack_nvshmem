# usage: ./prepare_deepep.sh
# install gdrcopy and nvshmem
# after execution, there will be a `deps` directory in the current directory, which contains:
# - gdrcopy_install: gdrcopy installation
# - nvshmem_install: nvshmem installation
# - nvshmem_build: nvshmem build directory
# - nvshmem_src: nvshmem source code
# - gdrcopy_src: gdrcopy source code
# - nvshmem_src_3.2.5-1.txz: nvshmem source code package
# - v2.4.4.tar.gz: gdrcopy source code package
# In the end, users should set the following environment variables:
# - NVSHMEM_DIR: nvshmem installation directory
# - LD_LIBRARY_PATH: to add nvshmem library path
# - PATH: to add nvshmem binary path
# then, please also execute ./prepare_deepep_host.sh to install the host-side drivers and reboot the system
set -ex
INSTALL_LOCATION=$1
if [ -z "$INSTALL_LOCATION" ]; then
    INSTALL_LOCATION="container"
fi

export ROOT_DIR=$(pwd)
export DEPS_DIR=$ROOT_DIR/deps
mkdir -p $DEPS_DIR

# install gdrcopy
pushd $DEPS_DIR
wget https://github.com/NVIDIA/gdrcopy/archive/refs/tags/v2.4.4.tar.gz
mkdir -p gdrcopy_src
tar -xvf v2.4.4.tar.gz -C gdrcopy_src --strip-components=1
pushd gdrcopy_src
make -j$(nproc)
make prefix=$DEPS_DIR/gdrcopy_install install

# build and install deb packages
pushd packages
sudo apt install devscripts -y
CUDA=${CUDA_HOME:-/usr/local/cuda} ./build-deb-packages.sh
sudo dpkg -i *.deb
popd

popd

# install nvshmem
mkdir -p nvshmem_src
wget https://developer.download.nvidia.com/compute/redist/nvshmem/3.2.5/source/nvshmem_src_3.2.5-1.txz
tar -xvf nvshmem_src_3.2.5-1.txz -C nvshmem_src --strip-components=1
pushd nvshmem_src
wget https://github.com/deepseek-ai/DeepEP/raw/main/third-party/nvshmem.patch
git init
git apply -vvv nvshmem.patch

# assume CUDA_HOME is set correctly
export GDRCOPY_HOME=$DEPS_DIR/gdrcopy_install
export NVSHMEM_SHMEM_SUPPORT=0
export NVSHMEM_UCX_SUPPORT=0
export NVSHMEM_USE_NCCL=0
export NVSHMEM_IBGDA_SUPPORT=1
export NVSHMEM_PMIX_SUPPORT=0
export NVSHMEM_TIMEOUT_DEVICE_POLLING=0
export NVSHMEM_USE_GDRCOPY=1
export NVSHMEM_BUILD_TESTS=0
export NVSHMEM_BUILD_EXAMPLES=0

cmake -S . -B $DEPS_DIR/nvshmem_build/ -DCMAKE_INSTALL_PREFIX=$DEPS_DIR/nvshmem_install

cd $DEPS_DIR/nvshmem_build/
make -j$(nproc)
make install

cd $ROOT_DIR
# create a temp file to store the environment variables
temp_file=$(mktemp)
echo "export NVSHMEM_DIR=$DEPS_DIR/nvshmem_install" >> $temp_file
echo "export LD_LIBRARY_PATH=\$NVSHMEM_DIR/lib:\$LD_LIBRARY_PATH" >> $temp_file
echo "export PATH=\$NVSHMEM_DIR/bin:\$PATH" >> $temp_file
echo "please add the following environment variables to your shell:"
cat $temp_file