# Containers from Scratch #

This repo contains the exercises and demo code for a Containers from Scratch presentation.

# Getting Started #

To follow along with this demo:

1. Install Vagrant w/ Virtualbox support; tested w/ Vagrant 1.8.5
2. run `bootstrap.sh` # will install an Ubuntu 16.04.2 Vagrant box
3. run `vagrant up`
4. follow steps in `demo.sh` #almost, but not quite runnable

Note: The Vagrant VM provider is Virtualbox. If you need to use a different provider you can:

* switch provider to, e.g. VMWare, Hyper-V
* provision an Ubuntu 16.04 host by other means and then run the commands in `provision.sh`

# Inspiration #

This presentation is inspired by the truly excellent presentations done by:

* Jerome Petazzoni at [DockerCon EU 2015](https://www.youtube.com/watch?v=sK5i-N34im8)
    * these exercises are a literal port of the closing demo from Jerome's talk
* Liz Rice's [Containers From Scratch](https://github.com/lizrice/containers-from-scratch)
