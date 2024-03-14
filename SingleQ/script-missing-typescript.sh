# CONFIGS
# =======
LAB_NO=5 # Lab Number
NUM_Qs=1 # Should be less than 10. Else the code needs modification.
TYP_MARK=1 # incorrect filename penalty

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
rm -rf missing_typescript_penalty.txt 
touch missing_typescript_penalty.txt
for i in `seq 1 $NUM_Qs`
do
    touch missing_typescript_penalty_Q${i}.txt
done

showFlag=0 # show penalty result

# Check for typescript
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
        
        typfl=$(ls | grep "typescript$")
        # Typescript file does not exist
        if [ -z $typfl ]
        then
            let penalty-=$TYP_MARK
            echo "${rollNum} : $penalty" >> ../../missing_typescript_penalty_Q${i}.txt
            echo -e "${Bold}${dir}-Q${i}${NC} - ${Red}Error: 'Typescript' not found.${NC} Typescript file missing."
            continue
        fi

        echo "${rollNum} : $penalty" >> ../../missing_typescript_penalty_Q${i}.txt
        echo -e "${Bold}${dir}-Q${i}${NC} - ${Green}Typescript file present!${NC}"
    done

    echo "********************************************************************************"
    cd ../
done

cd ..
echo
echo -e "${Yellow}Typescript check completed!!!${NC}"
echo

if [ $showFlag -ne 0 ]
then
    echo "=================="
    echo -e "${Cyan}Typescript Penalty${NC}"
    echo "=================="
    for i in `seq 1 $NUM_Qs`
    do
        echo "Q${i}" >> missing_typescript_penalty.txt
        echo "--" >> missing_typescript_penalty.txt
        cat missing_typescript_penalty_Q${i}.txt >> missing_typescript_penalty.txt
    done

    cat missing_typescript_penalty.txt
    echo
else
    rm -rf missing_typescript_penalty.txt
fi

for i in `seq 1 $NUM_Qs`
do
    rm -rf missing_typescript_penalty_Q${i}.txt
done