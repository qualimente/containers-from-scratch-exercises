# safeties off!
sudo su
cd

# create device and btrfs
modprobe loop
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
# inside fresh btrfs volume: /btrfs
cd /mnt/demo

# make filesystem private so container fs does not bleed into host
mount --make-rprivate /

# make a directory to hold images and containers
mkdir -p images containers

# create a sub volume to hold an alpine image
btrfs subvol create images/alpine

# show the subvol has been created
btrfs subvol list images

# use docker to download an image and create a filesystem we can use later
# alternatively, use docker save!
CID=$(docker run -d alpine:3.6 true)
echo $CID
docker export $CID | tar -C images/alpine-3.6/ -xf-

# inspect the image filesystem
ls -la images/alpine-3.6

# create btrfs snapshot of alpine image and store in containers directory as 'tupperware' - our container name!
btrfs subvol snapshot images/alpine-3.6/ containers/tupperware

# beginning of container
unshare --mount --uts --ipc --net --pid --fork bash
hostname tupperware
exec bash

# show some things: process list, hostname
ps # shows processes, note pids are not namespaced.  because /proc is shared

