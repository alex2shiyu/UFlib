#!/bin/bash

if [ $# -eq 2 ];then
    sed -n "$1 p"  $2
elif [ $# -eq 3 ];then
    sed -n "$1,$2 p"  $3
else
    echo "wrong number of input parameters and check again!"
fi
