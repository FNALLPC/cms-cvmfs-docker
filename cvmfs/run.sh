#!/bin/bash

chmod o+rw /dev/fuse

if [ -z "$MY_UID" ]; then
    MY_UID=$(id -u cmsuser)
    echo "MY_UID variable not specified, defaulting to cmsuser user id ($MY_UID)"
fi

if [ -z "$MY_GID" ]; then
    MY_GID=$(id -g cmsuser)
    echo "MY_GID variable not specified, defaulting to cmsuser user group id ($MY_GID)"
fi

FIND_GROUP=$(grep ":$MY_GID:" /etc/group)

if [ -z "$FIND_GROUP" ]; then
    usermod -g users cmsuser
    groupdel cmsuser
    groupadd -g $MY_GID cmsuser
fi

# Set cmsuser account's UID.
usermod -u $MY_UID -g $MY_GID --non-unique cmsuser > /dev/null 2>&1

# Change ownership to cmsuser account on all working folders.
chown -R $MY_UID:$MY_GID /home/cmsuser

if [ -z "$CVMFS_MOUNTS" ]; then
    echo -ne "Mounting all filesystems in /etc/fstab ... "
    mount -a -F > /dev/null 2>&1
    echo -e "DONE"
else
    for MOUNT in ${CVMFS_MOUNTS[@]}; do
	echo -ne "Mounting the filesystem \"${MOUNT}\" ... "
	mount -F ${MOUNT} > /dev/null 2>&1
	echo -e "DONE"
    done
fi

#trap : TERM INT; sleep infinity & wait
su cmsuser -s /bin/bash "$@"
