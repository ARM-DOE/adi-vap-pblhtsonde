#!/bin/sh

# Check if the test is being run by APR
if [ "$APR_TOPDIR" ]; then
    export VAP_BIN="$APR_TOPDIR/package/$APR_PREFIX/bin"
    cd $APR_TOPDIR/test
fi

/apps/ds/bin/dsproc_test

if [ $? != 0 ]; then
    echo "***** FAILED TEST *****"
    exit 1
fi

echo "***** PASSED TEST *****"
exit
