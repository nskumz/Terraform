#!/bin/bash

sudo su - root
yum update -y
yum install httpd -y
systemctl start httpd
systemctl enable httpd
yum install git -y
git clone https://github.com/nskumz/ecomm.git /var/www/html

