#!/bin/bash
cd ~

# download android tools if not present
if [ ! -d "platform-tools" ]; then
    wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
    unzip platform-tools-latest-linux.zip -d ~
    rm platform-tools-latest-linux.zip
fi

# add Android SDK platform tools to path
export PATH=$PATH:$HOME/platform-tools

sudo apt install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick lib32readline-dev lib32z1-dev libelf-dev liblz4-tool libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev lib32ncurses5-dev libncurses5 libncurses5-dev python-is-python3
wget http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.4-2_amd64.deb && sudo dpkg -i libtinfo5_6.4-2_amd64.deb && rm -f libtinfo5_6.4-2_amd64.deb
wget http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libncurses5_6.4-2_amd64.deb && sudo dpkg -i libncurses5_6.4-2_amd64.deb && rm -f libncurses5_6.4-2_amd64.deb

mkdir -p ~/bin
mkdir -p ~/android/lineage
mkdir -p ~/.cache/ccache/tmp

curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

export PATH=$PATH:$HOME/bin

git config --global user.email "luuxis8215@gmail.com"
git config --global user.name "Luuxis"

git lfs install


cd ~/android/lineage
repo init -u https://github.com/LineageOS/android.git -b lineage-20.0 --git-lfs

repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

mkdir -p ~/android/lineage/.repo/local_manifests/
echo '<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="samsung-8550" fetch="https://github.com/chaptsand" sync-c="true" sync-tags="false" revision="lineage-20" />
  
  <project name="android_device_samsung_dm3q" path="device/samsung/dm3q" remote="samsung-8550"/>
  <project name="android_device_samsung_sm8550-common" path="device/samsung/sm8550-common" remote="samsung-8550"/>
  <project name="android_device_samsung_dm3q-kernel" path="device/samsung/dm3q-kernel" remote="samsung-8550"/>

  <project name="android_vendor_samsung_dm3q" path="vendor/samsung/dm3q" remote="samsung-8550"/>
  <project name="android_vendor_samsung_sm8550-common" path="vendor/samsung/sm8550-common" remote="samsung-8550"/>
  
  <project name="LineageOS/android_kernel_qcom_sm8550" path="kernel/samsung/sm8550" revision="lineage-20"/>
  <project name="LineageOS/android_kernel_qcom_sm8550-modules" path="kernel/samsung/sm8550-modules" revision="lineage-20"/>

  <project name="LineageOS/android_hardware_samsung" path="hardware/samsung" revision="lineage-20" />
</manifest>
' > ~/android/lineage/.repo/local_manifests/dm3q.xml

repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

rm -rf ~/android/lineage/kernel/samsung/sm8550-modules/Android.bp

echo 'soong_namespace {
    imports: ["kernel/samsung/sm8550"]
}' > ~/android/lineage/kernel/samsung/sm8550-modules/Android.bp

export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache

source build/envsetup.sh
breakfast lineage_dm3q-userdebug

croot
brunch lineage_dm3q-userdebug
