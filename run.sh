#!/bin/bash

echo "Copy notebooks"
if [ ! -d /home/jovyan/work/DIVAnd-Workshop ]; then
    cp -R /data/Diva-Workshops-master/notebooks /home/jovyan/work/DIVAnd-Workshop
fi


if [ ! -d /home/jovyan/work/DIVAnd-Workshop/Adriatic/WOD/CTD ]; then
    mkdir -p /home/jovyan/work/DIVAnd-Workshop/Adriatic/WOD
    ln -s /data/Diva-Workshops-data/WOD/* /home/jovyan/work/DIVAnd-Workshop/Adriatic/WOD/
fi

# this is very slow and should not be necessary in most cases
# if test -n "$NB_UID"; then
#     echo "Change ownership to user id $NB_UID"
#    chown -R "$NB_UID":"$NB_GID" /home/jovyan/.local
#    chown -R "$NB_UID":"$NB_GID" /home/jovyan/.julia
#    chown -R "$NB_UID":"$NB_GID" /home/jovyan/work
# fi

echo "Executing /usr/local/bin/start-singleuser.sh"
exec /usr/local/bin/start-singleuser.sh --KernelSpecManager.ensure_native_kernel=False
