#!/bin/sh

if [ "$1" = "--conf" ]; then
    conf_package=1
fi

prefix=$APR_PREFIX
destdir=$APR_TOPDIR/package

export BUILD_PACKAGE_NAME="$APR_COMPONENT-$APR_PACKAGE"
export BUILD_PACKAGE_VERSION="$APR_VERSION.$APR_OS"

if [ $conf_package ]; then
    $APR_TOPDIR/build.sh --prefix=$prefix --destdir=$destdir --conf
else
    $APR_TOPDIR/build.sh --prefix=$prefix --destdir=$destdir --exec
fi

