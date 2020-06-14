#!/bin/bash

TRASH_DIR=$HOME/.Trash

if [ $# -eq 0 ]; then
        echo "usage: xxyrm.sh <files...>" >&2
        exit 2;
fi

for file in "$@"; do
    STAMP=`date +%Y%m%d`.`date +%H%M%S`

    # get just file name
    destfile="`basename \"$file\"`"

    mv -vi "$file" "$TRASH_DIR/$STAMP.${destfile}"
done
