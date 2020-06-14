#!/bin/bash

TRASH_DIR=$HOME/.Trash
rmpath=$HOME/func_myself/xxyrm.sh

if [ $# -lt 2 ]; then
        echo "usage: sypcp.sh path/file path" >&2
        exit 2;
fi

#num_file=$#-1
args=("$@")
lastinput=${args[$#-1]%*/}
firstinput=${args[0]}
#echo $lastfile
if [ "$firstinput" = '-r' ];then
#    for ((i=2; i<$#; i++))
#    do
#        file=${args[$i-1]}
#        echo $file
#        destfile="`basename \"$file\"`"
#        destfile2="$lastinput/$destfile"
#        echo $destfile2
#        if [ -d $destfile2 ];then
#            bash $rmpath $destfile2
#        fi
        cp $@
#    done
else
    if [ -f $lastinput -a $# -eq 2 ];then
        for ((i=1; i<$#; i++))
        do
            file=${args[$i-1]}
            destfile="`basename \"$file\"`"
#            destfile2="$lastinput/$destfile"
#            echo $destfile2
            if [ -e $lastinput ];then
                bash $rmpath $lastinput
            fi
            cp $file $lastinput
        done
    elif [ -d $lastinput ];then
        for ((i=1; i<$#; i++))
        do
            file=${args[$i-1]}
#            echo $file
            destfile="`basename \"$file\"`"
            destfile2="$lastinput/$destfile"
#            echo $destfile2
            if [ -e $destfile2 ];then
                bash $rmpath $destfile2
            fi
            cp $file $lastinput
        done
    else
        exit 3;
    fi
fi

#for file in "$@"; do
#    STAMP=`date +%Y%m%d`.`date +%H%M%S`
#
#    # get just file name

 #   mv -vi "$file" "$TRASH_DIR/$STAMP.${destfile}"
#done
