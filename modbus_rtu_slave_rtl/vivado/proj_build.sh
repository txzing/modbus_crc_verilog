#!/bin/bash

mkdir -p ip_cache
exit | source clean.sh -b
#source /opt/Xilinx/Vivado/2020.2/settings64.sh
source setenv.sh
#vivado -mode tcl -source create_and_build_proj.tcl
vivado -mode batch -source create_and_build_proj.tcl
if [ $? != 0 ]
then
    echo -e "\n"
    echo -e "\033[41;36m proj gen fail!!! Press any key to exit \033[0m"
    exit 1
else
    echo -e "\n"
    echo -e "\033[42;31m proj gen done!!! Press any key to exit \033[0m"
fi
function pause(){
    read -n 1
}
source clean.sh -b
pause
