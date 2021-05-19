# myOS
Simple 64-bit Operating System

## Docker Commands
View currently running Docker containers:

`sudo docker ps`

Build Docker container:

`sudo docker build buildenv -t myos-buildenv`

Run built Docker containers:

`sudo docker run --rm -it -v $PWD:/root/env myos-buildenv`

## General Commands

Run makefile in docker container:

`make build-x86_64`

Emulate OS:

`qemu-system-x86_64 -cdrom dist/x86_64/kernel.iso`