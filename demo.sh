# safeties off!
sudo su
cd

function achievement() {
  echo '=== Achievement Unlocked! ==='
  echo "$1"
  echo '============================='
}

# show cgroups are already in-use
tree /sys/fs/cgroup/pids
cat /sys/fs/cgroup/pids/user.slice/pids.current
cat /sys/fs/cgroup/pids/user.slice/user-1000.slice/pids.current
cat /sys/fs/cgroup/pids/user.slice/user-1000.slice/tasks

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

achievement "You have a place to store images and containers!"

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

achievement "You have an image to create a container from!"

# start containerizing!

# create btrfs snapshot of alpine image and store in containers directory as 'tupperware' - our container name!
btrfs subvol snapshot images/alpine/ containers/tupperware

# Unshare the indicated namespaces from the parent process and then execute the specified program.
# --mount Mounting and unmounting filesystems will not affect the rest of the system
# --uts   Setting hostname or domainname will not affect the rest of the system.
# --ipc   Process will have an independent namespace for System V message queues, semaphore sets and shared memory segments.
# --net   Process will have independent IPv4 and IPv6 stacks, IP routing tables, firewall rules, the /proc/net and /sys/class/net directory trees, sockets, etc.
# --pid   Children will have a distinct set of PID to process mappings from their parent.
unshare \
  --mount \
  --uts \
  --ipc \
  --net \
  --pid \
  --fork bash
exec bash
#hostname tupperware # will actually change hostname; because bash is from parent?

function achievement() {
  echo '=== Achievement Unlocked! ==='
  echo "$1"
  echo '============================='
}

# show some things: process list, hostname
ps # shows processes, note pids are not namespaced.  because /proc is shared

# mount new proc filesystem
mount -t proc none /proc

# shows only container's processes with pids mapped from container's pid namespace
ps

# show network isolation
ifconfig -a
ping 8.8.8.8

achievement "You have created a container with mount, uts, ipc, net, and pid namespaces enabled!"

# remove fresh proc
umount /proc/

# isolate filesystem
cd /
mkdir /mnt/demo/containers/tupperware/oldroot
# create a mountpoint from the tupperware container directory
mount --bind \
  /mnt/demo/containers/tupperware/ \
  /mnt/demo/containers/tupperware/
# move tupperware container mount to /mnt/demo; making container fs contents accessible under /mnt/demo
mount --move /mnt/demo/containers/tupperware/ /mnt/demo/
cd /mnt/demo
ls

# pivot_root <new_root> <put_old> moves the root file system of the current process to the directory put_old and makes new_root the new root file system.
pivot_root . oldroot/

# clean up proc filesystem again
mount -t proc none /proc

# show mounts, including a bunch of stuff from host
mount

# unmount host's filesystem and associated mounts
umount -l /oldroot/

# show mounts
mount

echo "This is the container's filesystem! $(date)" >> README
cat README

# spawn new shell on *host*
sudo su
cd

function achievement() {
  echo '=== Achievement Unlocked! ==='
  echo "$1"
  echo '============================='
}

cat /mnt/demo/images/alpine/README
cat /mnt/demo/containers/tupperware/README

achievement "You have pivoted to an isolated filesystem created from an image snapshot!"

# Create and integrate network
CPID=$(pidof unshare)
echo $CPID
ip link add name host${CPID} type veth peer name cont${CPID}
ip link set cont${CPID} netns ${CPID}

# configure docker bridge
ip link set host${CPID} master docker0 up

# in *container*
# show interfaces are visible but do not have addresses, no bytes sent
ifconfig -a
ping 8.8.8.8

# start up interfaces
export CPID=NNNN # set to value of the unshared process, ${CPID} from the host shell
ip link set lo up
ip link set cont${CPID} name eth0 up

ip addr add 172.17.42.42/16 dev eth0
ifconfig -a

ip route add default via 172.17.0.1

# demo network!
ping 8.8.8.8

achievement "You have created and integrated an isolated network adapter in your container!"

# final step: switch to the shell inside container
exec chroot / sh
hostname tupperware

# reference #

# network routes
# $ ip route
# default via 10.0.2.2 dev enp0s3
# 10.0.2.0/24 dev enp0s3  proto kernel  scope link  src 10.0.2.15
# 172.17.0.0/16 dev docker0  proto kernel  scope link  src 172.17.0.1 linkdown
# 192.168.0.0/24 dev enp0s8  proto kernel  scope link  src 192.168.0.42
