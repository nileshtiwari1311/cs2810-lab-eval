# CONFIGS
# =======
LAB_NO=5 # Lab Number
NUM_Qs=2 # Should be less than 10. Else the code needs modification.
INFL_MARK=1 # incorrect filename penalty

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
rm -rf incorrect_filename_penalty.txt 
touch incorrect_filename_penalty.txt
for i in `seq 1 $NUM_Qs`
do
    touch incorrect_filename_penalty_Q${i}.txt
done

showFlag=0 # show penalty result

# Check for incorrect filename
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
        
        # QNo directory does not exist
        if ! [ -d "Q${i}" ]
        then
            echo "${rollNum} : $penalty" >> ../../incorrect_filename_penalty_Q${i}.txt
            echo -e "${Bold}${dir}-Q${i}${NC} - ${Red}Error: 'Q${i}' directory not found.${NC}"
            continue
        fi

        cd "Q${i}"
        program="${dir}-Q${i}.cpp"
        # Main code file RollNum-LabX-QY.cpp does not exist
        if ! [ -f $program ]
        then
            cd ..
            let penalty-=$INFL_MARK
            echo "${rollNum} : $penalty" >> ../../incorrect_filename_penalty_Q${i}.txt
            echo -e "${Bold}${dir}-Q${i}${NC} - ${Red}Error: '${program}' not found.${NC} Incorrect main filename."
            continue
        fi

        cd ..
        echo "${rollNum} : $penalty" >> ../../incorrect_filename_penalty_Q${i}.txt
        echo -e "${Bold}${dir}-Q${i}${NC} - ${Green}Correct filename!${NC}"
    done

    echo "********************************************************************************"
    cd ../
done

cd ..
echo
echo -e "${Yellow}Filename check completed!!!${NC}"
echo

if [ $showFlag -ne 0 ]
then
    echo "================"
    echo -e "${Cyan}Filename Penalty${NC}"
    echo "================"
    for i in `seq 1 $NUM_Qs`
    do
        echo "Q${i}" >> incorrect_filename_penalty.txt
        echo "--" >> incorrect_filename_penalty.txt
        cat incorrect_filename_penalty_Q${i}.txt >> incorrect_filename_penalty.txt
    done

    cat incorrect_filename_penalty.txt
    echo
else
    rm -rf incorrect_filename_penalty.txt
fi

for i in `seq 1 $NUM_Qs`
do
    rm -rf incorrect_filename_penalty_Q${i}.txt
done