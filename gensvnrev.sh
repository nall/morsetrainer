#!/bin/sh

SVN="/usr/bin/env svn"
GREP=/usr/bin/grep
SED=/usr/bin/sed
RM=/bin/rm
ECHO=/bin/echo
COPYRIGHT=$PWD/copyright.pl

GENFILE=$DERIVED_FILE_DIR/svnRevision.m

VERSION=1.0

REVISION=`$SVN info | $GREP "^Revision: " | $SED -e "s/^Revision: //"`

$RM -f $GENFILE

$ECHO "NSString* svnRevision = @\"v$VERSION (build $REVISION)\";" > $GENFILE
$COPYRIGHT $GENFILE
