#!/bin/bash

# The IPython image starts as privileged user.
# The parent Galaxy server is mounting data into /import with the same 
# permissions as the Galaxy server is running on.
# In case of 1450 as UID and GID we are fine, because our preconfigured ipython
# user owns this UID/GID. 
# (1450 is the user id the Galaxy-Docker Image is using)
# If /import is not owned by 1450 we need to create a new user with the same
# UID/GID as /import and make everything accessible to this new user.
#
# In the end the IPython Server is started as non-privileged user. Either
# with the UID 1450 (preconfigured jupyter user) or a newly created 'galaxy' user
# with the same UID/GID as /import.

export PATH=/home/$NB_USER/.local/bin:$PATH

if [ ! -d /home/$NB_USER/work/DIVAnd-Workshop/Adriatic/WOD/CTD ]; then
    mkdir -p /home/$NB_USER/work/DIVAnd-Workshop/Adriatic/WOD
    ln -s /data/Diva-Workshops-data/WOD/* /home/$NB_USER/work/DIVAnd-Workshop/Adriatic/WOD/
    chown $NB_USER /work/DIVAnd-Workshop/Adriatic/WOD
fi

echo "Copy notebooks"
if [ ! -d /home/$NB_USER/work/DIVAnd-Workshop ]; then
    cp -R /data/Diva-Workshops-master/notebooks /home/$NB_USER/work/DIVAnd-Workshop
    chown $NB_USER /work/DIVAnd-Workshop/notebooks/*/*.ipynb
fi

# this is very slow and should not be necessary in most cases
if test -n "$NB_UID"; then
    echo "Change ownership to user id $NB_UID"
    chown -R "$NB_UID":"$NB_GID" /home/jovyan/.local
    chown -R "$NB_UID":"$NB_GID" /home/jovyan/.julia
fi


jupyter trust /home/$NB_USER/work/DIVAnd-Workshop/notebooks/*/*.ipynb

jupyter lab --no-browser

