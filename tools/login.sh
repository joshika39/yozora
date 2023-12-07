#!/bin/bash

if [ "$EUID" -ne 0 ]
	then echo "Root is required!"
		exit

fi

cp /etc/issue /etc/issue.bak
cp ../files/custom-login.txt /etc/issue
