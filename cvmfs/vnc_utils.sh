#!/bin/bash

export NOVNC_PID_FILE="$HOME/.vnc/novnc_session.pid"

_start_vnc_worker() {
    nvnc=$((`vncserver -list | wc -l`-4))
    vncname="myvnc:$(($nvnc+1))"
    desktop="`hostname`:$(($nvnc+1))"
    vncserver -geometry $GEOMETRY -name $vncname
    export ORIGINAL_DISPLAY=$DISPLAY
    export DISPLAY=$desktop
    if [[ "${1}" == "verbose" ]]; then
        novnc_proxy --listen 6080 --vnc 127.0.0.1:$((5900+$nvnc+1)) &
    else
        novnc_proxy --listen 6080 --vnc 127.0.0.1:$((5900+$nvnc+1)) > /dev/null 2>&1 &
    fi
    echo $! > "$NOVNC_PID_FILE"
    echo -e "VNC connection points:"
    echo -e "\tVNC viewer address: 127.0.0.1:$((5900+$nvnc+1))"
    echo -e "\tOSX built-in VNC viewer command: open vnc://127.0.0.1:$((5900+$nvnc+1))"
    echo -e "\tWeb browser URL: http://127.0.0.1:6080/vnc.html?host=127.0.0.1&port=6080"
    echo -e "\nTo stop noVNC enter 'pkill -9 -P $NOVNCPID'"
    echo -e "To kill the vncserver enter 'vncserver -kill :$(($nvnc+1))'"
}

start_vnc() {
    export -f _start_vnc_worker

    # set the display safely in the parent shell context
    local nvnc=$((`vncserver -list | wc -l`-4))
    export ORIGINAL_DISPLAY=$DISPLAY
    export DISPLAY="`hostname`:$(($nvnc+1))"

    # DBUS session needed for openbox (vnc display)
    dbus-run-session -- bash -c '_start_vnc_worker "$@"' bash "$@"
}

stop_vnc() {
    nvnc=$((`vncserver -list | wc -l`-4))
    for i in $(seq 1 $nvnc); do
        vncserver -kill :${i}
    done
    NOVNCPID=$(cat "$NOVNC_PID_FILE")
    pkill -9 -P $NOVNCPID
    rm -f "$NOVNC_PID_FILE"
    export DISPLAY=$ORIGINAL_DISPLAY
}

clean_vnc() {
    NOVNCPID=$(cat "$NOVNC_PID_FILE")
    output=$(ps -p "$NOVNCPID")
    if [[ "$?" -eq 0 ]]; then
        stop_vnc
    fi
    rm ~/.vnc/*.log ~/.vnc/config ~/.vnc/passwd
}
