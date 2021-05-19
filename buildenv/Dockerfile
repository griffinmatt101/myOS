#Dockerfile for build enviornment
FROM randomdude/gcc-cross-x86_64-elf

RUN apt-get update
RUN apt-get upgrade -y

#assembly compile
RUN apt-get install -y nasm

#build final iso file
RUN apt-get install -y xorriso
RUN apt-get install -y grub-pc-bin
RUN apt-get install -y grub-common

#attach volume to dev environment
VOLUME /root/env

#set starting folder
WORKDIR /root/env