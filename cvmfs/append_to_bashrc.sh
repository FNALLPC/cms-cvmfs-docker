
# add some aliases that don't exist by default in this container
alias lla='ll -ah'
alias voms-proxy-init='voms-proxy-init -voms cms --valid 192:00 -cert ~/.globus/usercert.pem -key ~/.globus/userkey.pem'

# Check to see if the cvmfs folders are mounted
if [ -z "$CVMFS_MOUNTS" ] || [ "${CVMFS_MOUNTS,,}" == "none" ] || [ "${CVMFS_MOUNTS}" == " " ] ; then
    echo -e "Not necessary to check the CVMFS mounts points."
else
    echo -ne "Checking CVMFS mounts ... "
    if cvmfs_config probe ${CVMFS_MOUNTS} >/dev/null; then
        echo -e "DONE"
	if [ "${CVMFS_MOUNTS,,}" == "all" ]; then
    	    echo -e "\tAll CVMFS folders mounted"
        else
    	    echo -e "\tThe following CVMFS folders have been successfully mounted:"
    	    for MOUNT in ${CVMFS_MOUNTS[@]}; do
    		echo -e "\t\t${MOUNT}"
    	    done
        fi
    else
        echo -e "DONE\n\tAt least one CVMFS folders is not mounted. Will automatically retry the CVMFS mounts."
        source /home/cmsusr/mount_cvmfs.sh
        mount_cvmfs
    fi
fi

# Source some CMS/VOMS specific setup scripts

cmsset_loc=/cvmfs/cms.cern.ch/cmsset_default.sh
if [ -f "$cmsset_loc" ]; then
    source $cmsset_loc
else
    echo -e "Unable to source $cmsset_loc"
fi
osg_loc=/cvmfs/oasis.opensciencegrid.org/mis/osg-wn-client/3.6/current/el7-x86_64/setup.sh
if [ -f "$osg_loc" ]; then
    source $osg_loc
else
    echo -e "Unable to setup the grid utilities from /cvmfs/oasis.opensciencegrid.org/"
fi

# Needed to access FNAL EOS
export XrdSecGSISRVNAMES="cmseos.fnal.gov"

# Get access to the VNC helper function
source /home/cmsusr/vnc_utils.sh
