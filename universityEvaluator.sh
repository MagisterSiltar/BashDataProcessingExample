# GLOBAL VARIABLES
# ================

VERSION='0.0.1'
VERBOSE=0
ACTION='mainmenu'
CSVFILE='universities.csv'

# CONFIGURATION
# =============

# LIBRARY
# =======

# Echo with Verbose implementation
# TODO Verbose Level as Int
writeLn() {
    if [[ -z ${2+x} ]]; then
        ECHO $1
    else
        ECHO $1
# if [[ $VERBOSE -gt "$2" || "$2" == *$VERBOSE* ]]; then
#     ECHO $1
# fi
    fi
}

trim() {
    var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"

    echo "$var"
}

goto() {
    verboseArgument=""
    if [[ 1 == *$VERBOSE* ]]; then
        verboseArgument="-v"
    fi

    if [[ 2 == *$VERBOSE* ]]; then
        verboseArgument="-vv"
    fi

    if [[ 3 == *$VERBOSE* ]]; then
        verboseArgument="-vvv"
    fi

    writeLn '--- --- --- --- --- --- ---' 3
    writeLn "GOTO: $1" 3
    writeLn '--- --- --- --- --- --- ---' 3

    sh ./universityEvaluator.sh "--action=$1"
    exit;
}

splitInRowArray() {
    IFS=$'\n' # split on newline
    set -o noglob
    rows=("$1")
}

writeTable() {
    writeLn "+----------------------------------------------------+-------------------+-------+------------------+----------------------+------+"
    printf "| %50s | %17s | %5s | %15s | %20s | %4s |\n" "Name" "Location" "State" "Tuition and fees" "Undergrad Enrollment" "Rank"
    writeLn "+----------------------------------------------------+-------------------+-------+------------------+----------------------+------+"

    for row in $1
        do
            IFS=',' read -ra row <<< "$row"

            if [ "${row[0]}" == "Name" ]; then
              continue
            fi

            name=$(trim "${row[0]}")
            location=$(trim "${row[1]}")
            state=$(trim "${row[2]}")
            fees=$(trim "${row[3]}")
            enrollment=$(trim "${row[4]}")
            rank=$(trim "${row[5]}")

            printf "| %50s | %17s | %5s | %16s | %20s | %4s |\n" "$name" "$location" "$state" "$fees" "$enrollment" "$rank"
        done

    writeLn "+----------------------------------------------------+-------------------+-------+------------------+----------------------+------+"
}

writeAnyKeyForBackQuestion() {
    writeLn ''
    writeLn 'Press any key to go back to the Mainmenu...'

    # Do nothing, wait only for input
    read anyKey

    goto 'mainmenu'
}

function contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}

function findIndexByValue() {
    declare -a array=("${!1}")
    local value=${2}

    for i in "${!array[@]}"; do
       if [[ "${array[$i]}" = "${value}" ]]; then
           echo "${i}";
       fi
    done
}

# Action Configuration
# =======

actionMainMenu() {

    writeLn 'University Evaluator [Writer Jonathan Werren and Andreas Frick]'
    writeLn '====================='
    writeLn ''
    writeLn 'The University Evaluator allows you to evaluate and map university data.'
    writeLn 'Please select one of the following evaluations.'
    writeLn ''
    writeLn 'Options:'
    writeLn '1. Data preview'
    writeLn '2. Data analysis'
    writeLn '3. Proportion of colleges'
    writeLn '4. Show state universities.'
    writeLn '5. Number of universities per state'
    writeLn ''
    writeLn 'Input the Number of your option.'

    while [ true ]
        do
            read answer

            if [[ $answer -gt 0 && $answer -lt 6 ]] ;then
                writeLn 'Answer is' + answer

                case ${answer} in

                    "1")
                       goto "preview"
                    ;;

                    "2")
                        goto  "analysis"
                    ;;

                    "3")
                        goto "proportion"
                    ;;

                    "4")
                        goto "stateuniversities"
                    ;;

                    "5")
                        goto "stateuniversitiescount"
                    ;;

                esac

            else
                writeLn 'Option unknown please use a value between 1 - 5.'
            fi
        done
}

actionPreview() {
    writeLn 'actionPreview' 3
    splitInRowArray "$(head -n 6 $CSVFILE)"
    writeTable "$rows"

    writeAnyKeyForBackQuestion
}

actionUniversitiesOfAState() {
    writeLn 'actionUniversitiesOfAState' 3

    writeLn 'For searching all Universities of an USA State please input the shortcut of a State:'

    while [ true ]
        do
            read answer
            answer="$(echo "$answer" | tr '[:lower:]' '[:upper:]')"

            count=$(grep -c "$answer" $CSVFILE)
            if [[ $count -gt 0 ]] ;then
                break
            fi

            writeLn 'Sorry, no Result for this state. Try again.'

        done

    writeLn ''
    writeLn "found $count results:"

    rows=$(grep "$answer" $CSVFILE)
    splitInRowArray "$rows"
    writeTable "$rows"

    writeAnyKeyForBackQuestion
}

actionStateUniversitiesCount() {
    writeLn 'actionStateUniversitiesCount' 3
    writeLn 'Universities count of each State in USA:'

    stateIndex=0
    states=()
    countPerState=()

    #Load Line by Line

    while IFS='' read -r row || [[ -n "$row" ]]; do

        IFS=',' read -ra row <<< "$row"

        state=$(trim "${row[2]}")

        if [ "$state" == "State" ]; then
          continue;
        fi

        if [ $(contains "${states[@]}" "$state") == "y" ]; then
            index=$(findIndexByValue states[@] "$state")
            ((countPerState[$index]++))
        else
            # echo "index $stateIndex"
            # echo "$state contains not"
            states[$stateIndex]="$state"
            countPerState[$stateIndex]=1
            ((stateIndex++))
        fi
    done < "$CSVFILE"

    # Sort in Bash only possible with sort from file data.
    # Create Cache File.
    cacheFileName="actionStateUniversitiesCountCache.txt"

    if [ -f $cacheFileName ]; then
       rm "$cacheFileName"
    fi

    for (( i=1; i<${#states[@]}; i++ ));
    do
        echo "${states[$i]}, ${countPerState[$i]}" >> "$cacheFileName"
    done

    sort --key 2 --numeric-sort $cacheFileName >> "$cacheFileName"

    writeLn '+-------+-------+'
    printf "| %5s | %5s |\n" "State" "Count"
    writeLn '+-------+-------+'

    while IFS='' read -r row || [[ -n "$row" ]]; do

        IFS=',' read -ra row <<< "$row"

        state=$(trim "${row[0]}")
        count=$(trim "${row[1]}")

        printf "| %5s | %5s |\n" "$state" "$count"

    done < "$cacheFileName"

    writeLn '+-------+-------+'
}

# DEBUG ZONE
# ==========

# READ ARGUMENT
# =============

writeLn 'initialize...' 3

for i in "$@"
    do
        case $i in

            -vvv)
                VERBOSE=3
                shift
            ;;

            -vv)
                VERBOSE=2
                shift
            ;;

            -v|--verbose)
                VERBOSE=1
                shift
            ;;

            --action=*)
                ACTION="${i#*=}"
                shift
            ;;

            -h|--help|*)
                ACTION='help'
                shift
            ;;

        esac
    done

writeLn '+--------------------------' 1
writeLn "| ACTION: ${ACTION}" 1
writeLn '| VERBOSE LEVEL: V' 1
writeLn '| VERBOSE LEVEL: VV' 2
writeLn '| VERBOSE LEVEL: VVV' 3
writeLn '+--------------------------' 1

# ACTION MAPPING
# ==============

writeLn 'action mapping...' 3
writeLn '' 3

case ${ACTION} in

    version)
        writeLn "University Evaluator v. ${VERSION}"
        rsync --version
    ;;

    mainmenu)
        actionMainMenu
    ;;

    preview)
        actionPreview
    ;;

    stateuniversities)
        actionUniversitiesOfAState
    ;;

    stateuniversitiescount)
        actionStateUniversitiesCount
    ;;

    help)
        writeLn '-h, --help              Show this help (-h works with no other options)'
        writeLn '-v, --verbose           increase verbosity [-v, -vv, -vvv]'
        writeLn '    --version           Print version number'
    ;;

    *)
        writeLn 'ACTION NOT IMPLEMENTED!!!'
        writeAnyKeyForBackQuestion
    ;;

esac

writeLn 'finish!!!' 3

takes_ary_as_arg()
{
    declare -a argAry1=("${!1}")
    echo "${argAry1[@]}"

    declare -a argAry2=("${!2}")
    echo "${argAry2[@]}"
}
try_with_local_arys()
{
    # array variables could have local scope
    local descTable=(
        "sli4-iread"
        "sli4-iwrite"
        "sli3-iread"
        "sli3-iwrite"
    )
    local optsTable=(
        "--msix  --iread"
        "--msix  --iwrite"
        "--msi   --iread"
        "--msi   --iwrite"
    )
    takes_ary_as_arg descTable[@] optsTable[@]
}