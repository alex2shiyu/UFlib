#!/bin/bash

# 拷贝文件而不拷贝目录，保留时间戳和权限
# 使用方法: copy_files_only.sh 源目录 目标目录

if [ "$#" -ne 2 ]; then
    echo "用法: $0 <源目录> <目标目录>"
    exit 1
fi

SRC="$1"
DST="$2"

if [ ! -d "$SRC" ]; then
    echo "错误：源目录不存在：$SRC"
    exit 1
fi

if [ ! -d "$DST" ]; then
    echo "错误：目标目录不存在：$DST"
    exit 1
fi

find "$SRC" -maxdepth 1 \( -type f -o -type l \)  -print0 | xargs -0 -I{} cp -a "{}" "$DST"

echo "文件已从 $SRC 拷贝到 $DST（不包括子目录）。"
