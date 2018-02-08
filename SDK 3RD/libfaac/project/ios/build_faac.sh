#!/bin/sh  
  
# http://www.linuxfromscratch.org/blfs/view/svn/multimedia/faac.html  
# ftp://mirror.ovh.net/gentoo-distfiles/distfiles/  

major=1  
minor=28  
micro=  

DEPLOYMENT_TARGET="8.0"  

XCD_ROOT="/Applications/Xcode.app/Contents/Developer"  
TOL_ROOT="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain"  
SDK_ROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS10.2.sdk"  
SDK_SML_ROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator10.2.sdk"  

export PATH=$TOL_ROOT/usr/bin:$PATH  
  

work=`pwd`  
srcs=$work/src
buid=$work/build  
insl=$buid/install  
name=faac-${major}.${minor}  
pakt=${name}.tar.gz  
dest=$work/faac-iOS-${major}.${minor}.tgz  
rm -rf $srcs $buid $dest && mkdir -p $srcs $buid  
if [ ! -f $pakt ];then 
  cp -Rf ../../src .
  mv src $name
  tar czvf $pakt $name && rm -Rf $name
fi

 
archs="armv7 armv7s arm64"
  
for a in $archs; do  
  case $a in  
    arm*)  
      sys_root=${SDK_ROOT}  
      host=arm-apple-darwin
      ;;  
    i386|x86_64)  
      sys_root=${SDK_SML_ROOT}  
      host=$a-apple-darwin
      ;;  
  esac  
  prefix=$insl/$a && rm -rf $prefix && mkdir -p $prefix  
  rm -rf $srcs && mkdir -p $srcs && cd $work && tar xvzf $pakt -C $srcs && cd $srcs/$name 
  
  export CC="$TOL_ROOT/usr/bin/clang -arch $a -isysroot $sys_root"
  export CXX="$TOL_ROOT/usr/bin/clang++ -arch $a -isysroot $sys_root"
  export CXXFLAGS="-arch $a -isysroot $sys_root"
  export CFLAGS="-arch $a -isysroot $sys_root -mios-version-min=$DEPLOYMENT_TARGET "
  export LDFLAGS="-isysroot $sys_root"
  export LIBS="-L${sys_root}/usr/lib"

  chmod +x install-sh
  chmod +x bootstrap  
  chmod +x configure
  ./bootstrap \
    &&./configure \
    --host=$host \
    --with-sysroot=$sys_root \
    --prefix=$prefix \
    --disable-shared \
    --enable-static \
    --disable-faac \
    --with-mp4v2 \
    &&make && make install
  lipo_archs="$lipo_archs $prefix/lib/libfaac.a"
  
  #echo 'continue any key pressed..'
  #read -n 1
done
  
univ=$insl/universal && mkdir -p $univ/lib  
cp -r $prefix/include $univ/  
lipo $lipo_archs -create -output $univ/lib/libfaac.a  
ranlib $univ/lib/libfaac.a  
strip -S $univ/lib/libfaac.a  
  
cd $univ && tar cvzf $dest *
cd $work && tar xvzf $dest

:<< 'END'
work=`pwd`  
build=$work/build  
insl=$build/install  
univ=$insl/universal && mkdir -p $univ/lib 
DESTDIR="faac-iOS"
if [ ! -d ${DESTDIR} ]; then
  mkdir -p ${DESTDIR}
fi
cp -R -f $univ/include $univ/lib ${DESTDIR}
END