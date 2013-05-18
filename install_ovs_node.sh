#!/bin/bash
#creating a temporary directory to store the installating logs for debugging purpose.
mkdir /root/temp

# capturing events by writting to the log file
echo creating_dir > /root/temp/log

#installing gcc, as it is required to build OVS module
apt-get -y install gcc >> /root/temp/log

echo installed_gcc >> /root/temp/log 

# Downloading linux headers for the system kernel to build OVS kernel module
apt-get -y install linux-headers-$(uname -r) >> /root/temp/log

echo installed_linux_headers >> /root/temp/log

#changing directory
cd temp

# downloading the source package from openvswitch resource repository
wget http://openvswitch.org/releases/openvswitch-1.7.1.tar.gz 2>> /root/temp/log

echo downloaded_ovs >> /root/temp/log

#unzip the tar file
tar -zxvf openvswitch-1.7.1.tar.gz >> /root/temp/log
echo unzipped >> /root/temp/log

pwd >> /root/temp/log

cd openvswitch-1.7.1

#building the openvswitch module 
./configure --disable-ssl --with-linux=/lib/modules/`uname -r`/build >> /root/temp/log
echo firing_make >> /root/temp/log
make >> /root/temp/log
echo firing_make_install >> /root/temp/log
make install >> /root/temp/log

#removing the default bridge module for smooth addition of the OVS module
echo removing_bridge >> /root/temp/log
rmmod bridge >> /root/temp/log

#inserting the OVS module into linux kernel datapath
echo inserting_OVS_mod >> /root/temp/log
insmod datapath/linux/openvswitch.ko >> /root/temp/log

#configuring the database server at the user level [this stores the state of the switch]
mkdir -p /usr/local/etc/openvswitch >> /root/temp/log
echo creating_database >> /root/temp/log
/usr/local/bin/ovsdb-tool create /usr/local/etc/openvswitch/conf.db vswitchd/vswitch.ovsschema >> /root/temp/log 2>&1

#starting the database server 
echo starting_the_dbserver >> /root/temp/log
server='/usr/local/sbin/ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock --remote=db:Open_vSwitch,manager_options --pidfile --detach'
$server  >> /root/temp/log 2>&1

#starting the OVS switch deamon, which accpets the command from the open flow controller and communicates the changes to flow tables to kernel data path via Netlink socket 
echo starting_switch_module >> /root/temp/log
/usr/local/bin/ovs-vsctl --no-wait init >> /root/temp/log 2>&1
switchd='/usr/local/sbin/ovs-vswitchd unix:/usr/local/var/run/openvswitch/db.sock --pidfile --detach'
$switchd >> /root/temp/log 2>&1

# custome commands to create a bridge and assign a controller to it.
#ovs-vsctl add-br test
#ovs-vsctl set-controller test tcp:<public ip>:6633
