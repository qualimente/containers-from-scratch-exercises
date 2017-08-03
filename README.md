# Containers from Scratch #

This repo contains the exercises and demo code for a Containers from Scratch presentation ([slides](https://docs.google.com/presentation/d/1i0SbJda_a4q5gVr4h496Yj2YzB0u4X3o960rxjnTELA/pub?start=false&loop=false&delayms=3000)).

# Getting Started #

To follow along with this demo:

1. Clone this repo
2. Install Vagrant w/ Virtualbox support; tested w/ Vagrant 1.8.5
3. run `bootstrap.sh` # will install an Ubuntu 16.04.2 Vagrant box
4. run `vagrant up`
5. follow steps in `demo.sh` #almost, but not quite runnable

Note: The Vagrant VM provider is Virtualbox. If you need to use a different provider you can:

* switch provider to, e.g. VMWare, Hyper-V
* provision an Ubuntu 16.04 host by other means and then run the commands in `provision.sh`

# Inspiration #

This presentation is inspired by these truly excellent presentations:

* Jerome Petazzoni at [DockerCon EU 2015](https://www.youtube.com/watch?v=sK5i-N34im8)
    * these exercises are a literal port of the closing demo from Jerome's talk
* Liz Rice's [Containers From Scratch (golang)](https://github.com/lizrice/containers-from-scratch)

# Resources #

* [Containers from Scratch Slides](https://docs.google.com/presentation/d/1i0SbJda_a4q5gVr4h496Yj2YzB0u4X3o960rxjnTELA/pub?start=false&loop=false&delayms=3000)
* [Ubuntu Cloud Images](https://cloud-images.ubuntu.com/xenial/)
* [Creating and using loopback devices](https://www.computerhope.com/unix/losetup.htm)
* [Create a btrfs volume](https://www.howtoforge.com/a-beginners-guide-to-btrfs#-creating-btrfs-file-systems-raid-raid)
* [Applying mount namespaces](https://www.ibm.com/developerworks/library/l-mount-namespaces/index.html)
* [IP Route](http://linux-ip.net/html/tools-ip-route.html)
