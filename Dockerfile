FROM almalinux:9
LABEL maintainer="Kevin Pedro <pedrok@fnal.gov>"

ADD cvmfs/cern.repo /etc/yum.repos.d/cern.repo
ADD cvmfs/cernvm.repo /etc/yum.repos.d/cernvm.repo

RUN    dnf update -y \
    && dnf install -y epel-release \
    && dnf repolist \
    && dnf install -y https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm \
    && dnf install -y emacs nano vim python3 openssh-server cvmfs man freetype libXpm libXext wget git \
       tcsh zsh tcl perl-ExtUtils-Embed perl-libwww-perl libXmu libXpm zip e2fsprogs \
       krb5-devel krb5-workstation strace libXft ImageMagick ImageMagick-devel mesa-libGL mesa-libGL-devel \
       mesa-libGLU mesa-libGLU-devel glx-utils libXrender-devel libXtst-devel xorg-x11-server-Xvfb xorg-x11-xauth \
       xclock openmotif openmotif-devel xz-devel tigervnc-server xterm openbox dbus-daemon \
       python3-pip novnc python3-websockify \
    && /usr/bin/python3 -m pip install --no-cache-dir --upgrade pip \
    && dnf clean all \
    && rm -rf /tmp/.X*

RUN for repo in cms.cern.ch cms-ib.cern.ch oasis.opensciencegrid.org cms-lpc.opensciencegrid.org \
                sft.cern.ch cms-bril.cern.ch cms-opendata-conddb.cern.ch ilc.desy.de unpacked.cern.ch \
                muoncollider.cern.ch sw.hsf.org; \
       do mkdir /cvmfs/$repo; echo "$repo /cvmfs/$repo cvmfs defaults 0 0" >> /etc/fstab; \
    done

RUN    groupadd cmsusr \
    && useradd -m -s /bin/bash -g cmsusr cmsusr

ADD cvmfs/default.local /etc/cvmfs/default.local
ADD cvmfs/krb5.conf /etc/krb5.conf
ADD cvmfs/run.sh /run.sh

WORKDIR /home/cmsusr
ADD cvmfs/mount_cvmfs.sh mount_cvmfs.sh
ADD cvmfs/vnc_utils.sh vnc_utils.sh
ADD cvmfs/append_to_bashrc.sh .append_to_bashrc.sh
RUN cat .append_to_bashrc.sh >> .bashrc \
    && rm .append_to_bashrc.sh \
    && mkdir -p /home/cmsusr/.vnc
ADD cvmfs/xstartup /home/cmsusr/.vnc/xstartup

ENV GEOMETRY=1920x1080

ENTRYPOINT ["/run.sh"]
