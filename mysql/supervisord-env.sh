#!/bin/bash

echo "In env.sh script";

# This ensures our env variables are available when we SSH 
# into this box or when other services need them
env | grep _ >> /etc/environment