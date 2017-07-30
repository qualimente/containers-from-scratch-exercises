#!/usr/bin/env bash
sudo apt-get -y update
sudo apt-get -y upgrade

# Ensure Ubuntu can install over https
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common

# Install Docker, Inc signing key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker apt repo and fetch package info
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update

# Install packages relevant to demo
sudo apt-get install -y btrfs-tools docker-ce
