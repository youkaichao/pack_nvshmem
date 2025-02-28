export ROOT_DIR=$(pwd)
export DEPS_DIR=$ROOT_DIR/deps
cd $DEPS_DIR/gdrcopy_src
sudo ./insmod.sh
# run gdrcopy_copybw to test the installation
$DEPS_DIR/gdrcopy_install/bin/gdrcopy_copybw
echo 'options nvidia NVreg_EnableStreamMemOPs=1 NVreg_RegistryDwords="PeerMappingOverride=1;"' | sudo tee -a /etc/modprobe.d/nvidia.conf
sudo update-initramfs -u

echo "Please reboot the system to apply the changes"