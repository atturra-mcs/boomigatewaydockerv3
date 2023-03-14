#!/bin/bash
# Copyright (c) 2015 Boomi, Inc.

source .profile

if [[ ! -f ${ATOM_HOME}/conf/container.id ]];
then
    sh /home/boomi/install.sh
    sed -i '/export BOOMI_PASSWORD=/d' /home/boomi/.profile
    export BOOMI_PASSWORD=

    # Verify the installation was successful
    if [[ -f ${ATOM_HOME}/conf/container.id ]]; then
        rm -f ${ATOM_HOME}/.install4j/pref_jre.cfg
        rm -f ${ATOM_HOME}/.install4j/inst_jre.cfg

        mv /home/boomi/atom ${ATOM_HOME}/bin
        ln -s ${ATOM_HOME}/bin/atom /usr/local/bin/atom
        mv /home/boomi/restart.sh ${ATOM_HOME}/bin

        sh /home/boomi/override_properties.sh

        #make sure everything is still ok now that we've overwritten atom script
        atom stop
    else
        # if we're here, then the installation failed for some reason
        echo "Installation was unsuccessful. Please check the log file in ${ATOM_HOME}."
        exit 1
    fi
else
    rm /home/boomi/atom
    ln -s ${ATOM_HOME}/bin/atom /usr/local/bin/atom

    # Needed for upgrading from Java 8 to 11.
    # If the "java.endorsed.dirs" system property is present, the JVM exits immediately. So we need to comment it out.
    sed -ci "s/^\-Djava.endorsed.dirs=/#&/" "${ATOM_HOME}/bin/atom.vmoptions"
fi

atom start
atom status

exit 0
