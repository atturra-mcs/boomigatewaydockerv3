#!/bin/bash
# Copyright (c) 2015 Boomi, Inc

#The purpose of this script is to bypass issues trying to run the atom as a non-root user
: ${BOOMI_ATOMNAME:?echo "BOOMI_ATOMNAME not set"}

if [ -z "${BOOMI_CONTAINERNAME}" ]; then
    export BOOMI_CONTAINERNAME="${BOOMI_ATOMNAME}"
fi

default_installation_dir="/var/boomi"
if [ -z "${INSTALLATION_DIRECTORY}" ]; then
    export INSTALLATION_DIRECTORY="${default_installation_dir}"
fi
if [ -z "${HOST_INSTALLATION_DIRECTORY}" ]; then
    export HOST_INSTALLATION_DIRECTORY="${default_installation_dir}"
fi

if [ -n "${SECURITY_CRON}" ]; then
    echo "Creating security update cron job"
    echo "$SECURITY_CRON root yum upgrade -y" > /etc/cron.d/security_updates
fi

DOCKERUSER="boomi"
DEFAULT_DOCKERUID=1000

if [ -z "${DOCKERUID}" ]; then
    DOCKERUID=$DEFAULT_DOCKERUID
fi

dirName=`echo ${BOOMI_CONTAINERNAME} | sed -r 's/ |-/_/g'`
atom_home=${INSTALLATION_DIRECTORY}/${AMC}_${dirName}

#set up for new boomi user to get all environment variables
if [[ ! -e .profile ]]; then
    echo "Creating boomi user profile"
    /home/boomi/create_profile.sh
    rm create_profile.sh
    echo "Initializing boomi user"
    useradd -u ${DOCKERUID} -c "Docker image user" $DOCKERUSER
    chown -R $DOCKERUSER:$DOCKERUSER /home/boomi
    chown -R $DOCKERUSER:$DOCKERUSER /opt/boomi/local
    echo "export DIRNAME=$dirName" >> .profile
    echo "export ATOM_HOME=$atom_home" >> .profile
fi

if [[ ! -e /etc/sudoers.d/boomi ]]; then
    echo 'boomi ALL=NOPASSWD: /bin/systemctl start atom' >> /etc/sudoers.d/boomi
    echo 'boomi ALL=NOPASSWD: /bin/systemctl stop atom' >> /etc/sudoers.d/boomi
    echo 'boomi ALL=NOPASSWD: /bin/systemctl restart atom' >> /etc/sudoers.d/boomi
fi

if [[ ! -e ${atom_home} ]]; then
    echo "Creating atom home directory"
    mkdir -p ${atom_home}
    echo "Changing ownership for atom home directory to $DOCKERUSER user"
    chown -R $DOCKERUSER:$DOCKERUSER ${atom_home}
fi

