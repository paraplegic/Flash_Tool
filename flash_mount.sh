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

##
image=$1
if [ -z "${image}" ]; then
	echo "ERROR:  you must specify an image path"
	usage
fi

##
chkdir ${test_dir}
##
fdisk -l ${image} | grep -i filesystem | while read x
do
	mount_point=$(echo ${x} | cut -f1 -d\ ) 
	mp=${test_dir}/${mount_point}

	blk=$(echo ${x}| cut -f2 -d\ ) 
	offset=$((${blk} * 512))

	sz=$(echo ${x} | cut -f3 -d\ )
	size=$(( ${sz} * 512 ))

	chkdir ${mp}

	ldev=$(losetup -f)
	losetup -o ${offset} --sizelimit ${size} ${ldev} ${image}
	err=$?
	if [ ${err} -eq 0 ] ; then
		echo "loop: ${mp} offset: ${offset} size: ${size}"
	  else
		echo "ERROR: unable to create ${ldev} for ${image}:${offset}:${size}"
		usage
	fi

	mount ${ldev} ${mp}
	err=$?
	if [ ${err} -eq 0 ] ; then
		echo "mounted: ${mp} offset: ${offset} size: ${size}"
	  else
		echo "ERROR: unable to mount ${ldev} at ${mp}"
	fi

done

