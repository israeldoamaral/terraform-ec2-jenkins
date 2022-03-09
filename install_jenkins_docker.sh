#!/bin/bash

sudo apt update

sudo apt install openjdk-8-jdk -y

sudo apt install wget -y

#sudo wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
sudo wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -


sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

sudo apt update

sudo apt install jenkins -y


sudo curl -fsSL https://get.docker.com | bash

sudo usermod -aG docker jenkins

sudo systemctl restart jenkins
