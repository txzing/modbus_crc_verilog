#!/bin/bash

RM_METHOD=0
RM_LVL=1
BATCH_MODE=0

while [ $# -gt 0 ] # Until you run out of parameters
do
case "$1" in
-b) #echo
#    echo "the -a option exists"
#    RM_LOG=1
    BATCH_MODE=1
    ;;
-c) #echo
#    echo "the -a option exists"
#    RM_LOG=1
    RM_LVL=1
    ;;
-w) #echo
#    echo "the -w option exists"
#    RM_WORKSPACE=1
    RM_LVL=2
    ;;
-d) #echo
#    echo "the -w option exists"
#    RM_OUTPUT=1
    RM_LVL=3
    ;;
-t) #echo
#    echo "the -t option exists"
    RM_METHOD=1
    ;;
-h|--help) echo "Usage: $0 [parameters]"
    echo "avalible parameters:"
    echo "-c: clear log files(default)"
    echo "-w: delete vivado work dir"
    echo "-d: delete ip cache"
    echo "-t: move to trash"
    echo "-b: batch mode"
    echo "-h|--help: show this help"
    exit 1
    ;;
esac
shift # Check next set of parameters.
done


if [ $RM_LVL -ge 1 ]; then
#echo "hahah1"
    if [ $RM_METHOD -eq 0 ]; then
        rm -rf ./.Xil
        rm -rf ./*.jou
        rm -rf ./*.log
        rm -rf ./Packages
    else
        gio trash ./.Xil
        gio trash ./*.jou
        gio trash ./*.log
        gio trash ./Packages
    fi
fi

if [ $RM_LVL -ge 2 ]; then
#echo "hahah2"
    if [ $RM_METHOD -eq 0 ]; then
        rm -rf ./vivado_proj
    else
        gio trash ./vivado_proj
    fi
fi

if [ $RM_LVL -ge 3 ]; then
#echo "hahah3"
    if [ $RM_METHOD -eq 0 ]; then
        rm -rf ./ip_cache
    else
        gio trash ./ip_cache
    fi
fi

function pause(){
    read -n 1
}


if [ $BATCH_MODE -eq 1 ]
then
    echo -e "\033[42;31m clean done!!! \033[0m"
    exit 0
else
    echo -e "\033[42;31m clean done!!! Press any key to exit \033[0m"
    pause
fi

