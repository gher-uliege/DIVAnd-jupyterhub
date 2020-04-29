#!/bin/bash

if [ ! -d /home/jovyan/work/DIVAnd-Workshop ]; then
    cp -R /data/Diva-Workshops-master/notebooks /home/jovyan/work/DIVAnd-Workshop
fi


if [ ! -d /home/jovyan/work/DIVAnd-Workshop/Adriatic/WOD/CTD ]; then
    mkdir -p /home/jovyan/work/DIVAnd-Workshop/Adriatic/WOD
    ln -s /data/Diva-Workshops-data/WOD/* /home/jovyan/work/DIVAnd-Workshop/Adriatic/WOD/
fi

if test -n "$NB_UID"; then
    #done in Dockerfile for speed
    if [ "$NB_UID" != "501" ]; then
	chown -R "$NB_UID":"$NB_GID" /home/jovyan/.local
	chown -R "$NB_UID":"$NB_GID" /home/jovyan/.julia
    fi

    chown -R "$NB_UID":"$NB_GID" /home/jovyan/work
fi

exec /usr/local/bin/start-singleuser.sh --KernelSpecManager.ensure_native_kernel=False
