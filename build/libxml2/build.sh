#!/usr/bin/bash
#
# {{{ CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END }}}
#
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2017 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=libxml2
VER=2.9.7
PKG=library/libxml2
SUMMARY="$PROG - XML C parser and toolkit"
DESC="$SUMMARY"

RUN_DEPENDS_IPS="compress/xz library/zlib"
# For lint library creation
BUILD_DEPENDS_IPS="developer/sunstudio12.1"

XFORM_ARGS="-D VER=$VER"

python_cleanup() {
    mv $DESTDIR/usr/lib/python$PYTHONVER/site-packages \
        $DESTDIR/usr/lib/python$PYTHONVER/vendor-packages \
        || logerr "Cannot move from site-packages to vendor-packages"
}

make_install64() {
    logmsg "--- make install"

    # Install 64-bit python modules into 64/
    for f in libxml2mod.la .libs/libxml2mod.la .libs/libxml2mod.lai; do
        logcmd perl -pi -e 's#(\/site-packages)#$1\/64#g;' python/$f \
            || logerr "libtool libxml2mod.la patch failed"
    done

    logcmd $MAKE DESTDIR=${DESTDIR} \
        PYTHON_SITE_PACKAGES=/usr/lib/python2.7/site-packages/64 \
        install \
        || logerr "--- Make install failed"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
python_cleanup
run_testsuite check
make_lintlibs xml2 /usr/lib /usr/include/libxml2 "libxml/*.h"
make_isa_stub
make_package local.mog final.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
