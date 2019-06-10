#!/bin/bash

test_dir="./test_dir"

function usage(){
	echo "Usage:"
	echo "	$0 <image>"
	echo 
	exit 1
}

function chkdir(){

	td=${1}
	if [ -d ${td} ]; then
		echo "${td} exists"
  	else
		echo "creating ${td}"
		mkdir -p ${td}
	fi

}

for mp in ${test_dir}/*
do
	echo ${mp}
	umount ${mp}
done

losetup | cut -f1 -d\ | grep -i loop | while read ldev
do
	echo ${ldev}
	losetup -d ${ldev}
done
