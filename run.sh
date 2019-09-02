#!/bin/bash

if [ ! -d /home/jovyan/work/DIVAnd-Workshop ]; then
    cp -R /data/Diva-Workshops-master/notebooks /home/jovyan/work/DIVAnd-Workshop
fi


if [ ! -d /home/jovyan/work/DIVAnd-Workshop/Adriatic/WOD/CTD ]; then
    mkdir -p /home/jovyan/work/DIVAnd-Workshop/Adriatic/WOD
    ln -s /data/Diva-Workshops-data/WOD/* /home/jovyan/work/DIVAnd-Workshop/Adriatic/WOD/
fi

exec /usr/local/bin/start-singleuser.sh --KernelSpecManager.ensure_native_kernel=False
