#!/bin/bash
#to scp file from tiangong supercomputer into local directory
#"$3" should included in "" to make "~" a string
if [ $1 = "dir" ];then
     if [ $2 = "come" ];then
        scp -P 4693 -r sypeng@159.226.35.226:$3 $4
     elif [ $2 = "go" ];then
        scp -P 4693 -r $3 sypeng@159.226.35.226:$4
     fi
elif [ $1 = "file" ];then
     if [ $2 = "come" ];then
        scp -P 4693 sypeng@159.226.35.226:$3 $4
     elif [ $2 = "go" ];then
        scp -P 4693 $3 sypeng@159.226.35.226:$4
     fi
elif [ $1 = "show" ];then
    echo "scpfile dir/file come/go "path" "path""
fi    
