# CONFIGS
# =======
LAB_NO=5 # Lab Number
NUM_Qs=1 # Should be less than 10. Else the code needs modification.
MKFL_MARK=1 # makefile penalty

# COLORS
# ======
NC='\033[0m'            # No Color
Bold='\033[1m'          # Bold
# Bold High Intensity
Red='\033[1;91m'        # Red
Green='\033[1;92m'      # Green
Yellow='\033[1;93m'     # Yellow
Cyan='\033[1;96m'       # Cyan

# Safety check
mkdir -p Programs
numoffiles=`ls Programs/ | wc -l`
if [ $numoffiles -eq 0 ]
then
    echo "Nothing to evaluate!"
    exit 1
fi

# Clean required folders and files and create fresh ones
rm -rf makefile_penalty.txt 
touch makefile_penalty.txt
for i in `seq 1 $NUM_Qs`
do
    touch makefile_penalty_Q${i}.txt
done

showFlag=0 # show penalty result

# Check for working Makefile
cd Programs
for dir in *
do
    # If directory name is wrong, skip and continue
    echo
    echo "============="
    echo -e "${Cyan}$dir${NC}"
    echo "============="
    # Check if $dir matches pattern CS..B...-Lab.
    if [[ ! $dir =~ ^CS[0-9]{2}B[0-9]{3}-Lab${LAB_NO}$ ]]
    then
        echo -e "${Yellow}Skipping directory${NC} ${Bold}'$dir'${NC} because of ${Yellow}wrong name/directory/structure${NC}"
        echo -e "Valid directory name: ${Bold}CSXXBXXX-Lab${LAB_NO}${NC}"
        echo "********************************************************************************"
        continue
    fi
    
    let showFlag=1
    cd $dir
    rollNum=$(echo "${dir}" | head -c8)

    for i in `seq 1 $NUM_Qs`
    do
        penalty=0
        if [ $i -gt 1 ]
        then
            echo
        fi

        echo -e "${Bold}Q${i} Evaluation${NC}"
        echo "-------------"

        mkfl="Makefile"
        # Makefile does not exist
        if ! [ -f $mkfl ]
        then
            let penalty-=$MKFL_MARK
            echo "${rollNum} : $penalty" >> ../../makefile_penalty_Q${i}.txt
            echo -e "${Bold}${dir}-Q${i}${NC} - ${Red}Error: '${mkfl}' not found.${NC}"
            continue
        fi

        echo "Checking Makefile"
        # make LXQY should generate executable
        # make "L${LAB_NO}Q${i}" # must use this when NUM_Qs > 1
        # make # can use this (without target name) for being flexible on target name in makefile
        target="L${LAB_NO}Q${i}"
        rm -rf *.o $target
        make ${target}
        if [ $? -ne 0 ]
        then
            rm -rf *.o
            let penalty-=$MKFL_MARK
            echo "${rollNum} : $penalty" >> ../../makefile_penalty_Q${i}.txt
            echo "-------------"
            echo -e "${Bold}${dir}-Q${i}${NC} - ${Red}Error: Makefile error / Compilation error${NC}"
            continue
        fi

        # executable generated should be named LxQY (same as target)
        if ! [ -f $target ]
        then
            rm -rf *.o
            let penalty-=$MKFL_MARK
            echo "${rollNum} : $penalty" >> ../../makefile_penalty_Q${i}.txt
            echo "-------------"
            echo -e "${Bold}${dir}-Q${i}${NC} - ${Red}Error: Executable generated is not named '$target'${NC}"
            continue
        fi

        rm -rf *.o $target
        echo "${rollNum} : $penalty" >> ../../makefile_penalty_Q${i}.txt
        echo "-------------"
        echo -e "${Bold}${dir}-Q${i}${NC} - ${Green}Makefile works. Executable '$target' generated!${NC}"
    done

    echo "********************************************************************************"
    cd ../
done

cd ..
echo
echo -e "${Yellow}Makefile check completed!!!${NC}"
echo

if [ $showFlag -ne 0 ]
then
    echo "================"
    echo -e "${Cyan}Makefile Penalty${NC}"
    echo "================"
    for i in `seq 1 $NUM_Qs`
    do
        echo "Q${i}" >> makefile_penalty.txt
        echo "--" >> makefile_penalty.txt
        cat makefile_penalty_Q${i}.txt >> makefile_penalty.txt
    done

    cat makefile_penalty.txt
    echo
else
    rm -rf makefile_penalty.txt
fi

for i in `seq 1 $NUM_Qs`
do
    rm -rf makefile_penalty_Q${i}.txt
done