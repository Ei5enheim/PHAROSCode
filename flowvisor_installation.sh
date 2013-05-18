#!/bin/bash

#download flowvisor
apt-get install -y build-essential openjdk-6-jdk ant

#install git
apt-get install -y git

#clone the git repository
git clone git://github.com/OPENNETWORKINGLAB/flowvisor.git

#build flowvisor
cd flowvisor
make

#add user flowvisor to the group flowvisor
groupadd flowvisor
useradd flowvisor -g flowvisor

INPUT="\n
       \n
       flowvisor"

#install flowvisor
echo -e "$INPUT" | make install fvuser=flowvisor fvgroup=flowvisor
