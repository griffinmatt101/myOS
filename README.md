# myOS
Simple 64-bit Operating System

# Docker Commands
`sudo docker ps`
View currently running Docker containers

`sudo docker build buildenv -t myos-buildenv`
Build Docker container

`sudo docker run --rm -it -v $PWD:/root/env myos-buildenv`
Run built Docker containers