#!/bin/bash
name=mklittlefs-$(git rev-parse --short HEAD)
rel=${rel:=030200}

rm -f *.json *.gz *.zip

build ()
{(
    TARGET_OS=${tgt} CC=${pfx}-gcc CXX=${pfx}-g++ STRIP=${pfx}-strip make clean mklittlefs${exe} BUILD_CONFIG_NAME="-arduino-esp32" CPPFLAGS="-DSPIFFS_OBJ_META_LEN=4"
    rm -rf tmp
    mkdir -p tmp/mklittlefs
    mv mklittlefs${exe} tmp/mklittlefs/.
    cd tmp
    if [ "${exe}" == "" ]; then
        tarball=${pfx}-$name.tar.gz
    else
        tarball=${pfx}-$name.zip
    fi
    ( echo '            {' &&
      echo '              "name": "tool-mklittlefs",' &&
      echo '              "version": "2.'${rel}'",' &&
      echo '              "description": "Utility for creating LittleFS images for ESP32x SOCs",' &&
      echo '              "keywords": ["tools","build tools","filesystem"],' &&
      echo '              "license": "MIT",' &&
      echo '              "system": '$AHOST',' &&
      echo '              "repository": {"type": "git","url": "https://github.com/jason2866/mklittlefs"}' &&
      echo '            }') > mklittlefs/package.json
    if [ "${exe}" == "" ]; then
        tar zcvf ../${tarball} mklittlefs
    else
        zip -rq ../${tarball} mklittlefs
    fi
    cd ..
)}

tgt=osx pfx=x86_64-apple-darwin14 exe="" AHOST='["darwin_x86_64","darwin_arm64"]' build
tgt=windows pfx=x86_64-w64-mingw32 exe=".exe" AHOST="windows_amd64" build
tgt=windows pfx=i686-w64-mingw32 exe=".exe" AHOST="windows_x86" build
tgt=linux pfx=arm-linux-gnueabihf exe="" AHOST="linux_armv6l" build
tgt=linux pfx=aarch64-linux-gnu exe="" AHOST="linux_aarch64" build
tgt=linux pfx=x86_64-linux-gnu exe="" AHOST="linux_x86_64" build
