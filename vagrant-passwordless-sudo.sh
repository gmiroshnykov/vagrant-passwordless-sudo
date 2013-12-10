#!/usr/bin/env bash

# fail on error
set -e

MARKER_BEGIN="##### BEGIN VAGRANT PASSWORDLESS SUDO #####"
MARKER_END="##### END VAGRANT PASSWORDLESS SUDO #####"

# copy the content of /etc/sudoers to a temporary sudoers file
TMP_SUDOERS=$(mktemp -t vagrant_sudoers)
cat /etc/sudoers > $TMP_SUDOERS

# remove any previously added instructions from the temporary sudoers file
sed -i -e "/^$MARKER_BEGIN\$/,/^$MARKER_END\$/d" $TMP_SUDOERS

# add new instructions to temporary sudoers file
cat >> $TMP_SUDOERS <<EOF
$MARKER_BEGIN
#
# Do not modify this block unless you really know what you're doing!
#

# NFS commands
Cmnd_Alias VAGRANT_EXPORTS_ADD = $SHELL -c echo '*' >> /etc/exports
Cmnd_Alias VAGRANT_NFSD = /sbin/nfsd restart
Cmnd_Alias VAGRANT_EXPORTS_REMOVE = /usr/bin/sed -E -e /*/ d -ibak /etc/exports
%staff ALL=(root) NOPASSWD: VAGRANT_EXPORTS_ADD, VAGRANT_NFSD, VAGRANT_EXPORTS_REMOVE

# vagrant-hostsupdater commands
Cmnd_Alias VAGRANT_HOST_ADD = /bin/sh -c echo "*" >> /etc/hosts
Cmnd_Alias VAGRANT_HOST_REMOVE = /usr/bin/sed -i -e /*/ d /etc/hosts
%staff ALL=(root) NOPASSWD: VAGRANT_HOST_ADD, VAGRANT_HOST_REMOVE
$MARKER_END
EOF

visudo -c -f $TMP_SUDOERS
