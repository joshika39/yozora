# How I install Arch Linux

## Introduction

This is a guide on how I install Arch Linux. It is not the only way to install Arch Linux, but it is the way that I have found to be the most efficient and reliable. This guide assumes that you have a basic understanding of Linux and the command line. If you are new to Linux, I recommend reading the [Arch Linux Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide) before proceeding.

## Installation

### Pacstrap

I usually install the base packages for me, which is:

`pacstrap -K /mnt base linux linux-firmware linux-headers sudo git vim openssh`

### Network configs

#### hostname

echo <pchostname> >> /etc/hostname

#### The `/etc/hosts` file

Example:

```
# IPv4 and IPv6 localhost entries
127.0.0.1   localhost
::1         localhost

# Local network hosts
192.168.1.10  yozora.local  yozora

# Hostname of your machine (if needed)
127.0.1.1   yozora
```
