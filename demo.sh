# safeties off!
sudo su
cd

# create copy-on-write filesystem capable of storing layers using loopback device and btrfs
mkdir -p /var/btrfs
dd if=/dev/zero of=/var/btrfs/loop0 bs=1k count=512000
losetup /dev/loop0 /var/btrfs/loop0
mkfs.btrfs -m single /dev/loop0

# show the shiny new btrfs volume
btrfs filesystem show

# mount filesystem
mkdir /mnt/demo
mount /dev/loop0 /mnt/demo

# show the shiny new mounted filesystem
df -h /mnt/demo
ls /mnt/demo

# foundation of isolation is filesystem
# inside fresh btrfs volume: /mnt/demo
cd /mnt/demo

# start with a clean state. Set all mounts to private
# disable propagation of mounts from /, recursively
# https://www.ibm.com/developerworks/library/l-mount-namespaces/index.html
mount --make-rprivate /

# make a directory to hold images and containers
mkdir -p images containers

echo "Achievement Unlocked: You have a place to store images and containers!"

# create a sub volume to hold an alpine image
btrfs subvol create images/alpine

# show the subvol has been created
btrfs subvol list images

# use docker to download an image and create a filesystem we can use later
# alternatively, use docker save!
CID=$(docker run -d alpine true)
echo $CID
docker export $CID | tar -C images/alpine/ -xf-

# inspect the image filesystem
ls -la images/alpine
echo "Always be demoing! $(date)" > images/alpine/README
cat images/alpine/README

echo "Achievement Unlocked: You have an image to create a container from!"

# start containerizing!

# create btrfs snapshot of alpine image and store in containers directory as 'tupperware' - our container name!
btrfs subvol snapshot images/alpine/ containers/tupperware

# beginning of container
unshare --mount --uts --ipc --net --pid --fork bash
hostname tupperware
exec bash

# show some things: process list, hostname
ps # shows processes, note pids are not namespaced.  because /proc is shared

# mount new proc filesystem
mount -t proc none /proc

# shows only container's processes
ps

# remove fresh proc
umount /proc/

# isolate filesystem
mkdir /mnt/demo/containers/tupperware/oldroot
cd /
mount --bind /mnt/demo/containers/tupperware/ /mnt/demo/containers/tupperware/
mount --move /mnt/demo/containers/tupperware/ /mnt/demo/
cd /mnt/demo
pivot_root . oldroot/

# clean up process namespace again
mount -t proc none /proc

# show mounts, including a bunch of stuff from host
mount

# unmount host's filesystem and associated mounts
umount -l /oldroot/

# show mounts
mount

# spawn new shell on *host*
sudo su
cd
CPID=$(pidof unshare)
echo $CPID
ip link add name host${CPID} type veth peer name cont${CPID}
ip link set cont${CPID} netns ${CPID}

# configure docker bridge
ip link set host${CPID} master docker0 up

# in *container*
# show interfaces are visible but do not have addresses, no bytes sent
ifconfig -a
ping www.google.com #nothing

# start up interfaces
export CPID=NNNN
ip link set lo up
ip link set cont${CPID} name eth0 up

ip addr add 172.17.42.42/16 dev eth0
ifconfig -a

ip route add default via 172.17.0.1

# demo network!
ping 8.8.8.8

# final step: switch to the shell inside container
exec chroot / sh



# reference #

# network routes
# $ ip route
# default via 10.0.2.2 dev enp0s3
# 10.0.2.0/24 dev enp0s3  proto kernel  scope link  src 10.0.2.15
# 172.17.0.0/16 dev docker0  proto kernel  scope link  src 172.17.0.1 linkdown
# 192.168.0.0/24 dev enp0s8  proto kernel  scope link  src 192.168.0.42
