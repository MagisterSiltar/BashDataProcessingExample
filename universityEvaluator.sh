# GLOBAL VARIABLES
# ================

CONFIG_FILE_NAME='rsync+.config.yml'
VERSION='0.0.1'
VERBOSE=0
ACTION='mainmenu'

# CONFIGURATION
# =============

# LIBRARY
# =======

# Echo with Verbose implementation
# TODO Verbose Level as Int
styled_echo() {
    if [[ -z ${2+x} || "$2" == *$VERBOSE* ]]; then
        ECHO $1
    fi
}

goto() {
    verboseArgument=""
    if [[ 1 == *$VERBOSE* ]]; then
        verboseArgument="v"
    fi

    if [[ 2 == *$VERBOSE* ]]; then
        verboseArgument="vv"
    fi

    if [[ 3 == *$VERBOSE* ]]; then
        verboseArgument="vvv"
    fi

    styled_echo '--- --- --- --- --- --- ---' 3
    styled_echo "GOTO: $1" 3
    styled_echo '--- --- --- --- --- --- ---' 3

    sh ./universityEvaluator.sh "--action=$1" "-$verboseArgument"
}

# Action Configuration
# =======

actionMainMenu() {

    styled_echo 'University Evaluator [Writer Jonathan Werren and Andreas Frick]'
    styled_echo '====================='
    styled_echo ''
    styled_echo 'TThe University Evaluator allows you to evaluate and map university data.'
    styled_echo 'Please select one of the following evaluations.'
    styled_echo ''
    styled_echo 'Options:'
    styled_echo '1. Data preview'
    styled_echo '2. Data analysis'
    styled_echo '3. Proportion of colleges'
    styled_echo '4. Show state universities.'
    styled_echo '5. Number of universities per state'
    styled_echo ''
    styled_echo 'Input the Number of your option.'

    while [ true ]
        do
            read answer

            if [[ $answer -gt 0 && $answer -lt 6 ]] ;then
                styled_echo 'Answer is' + answer

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
                        goto "perstate"
                    ;;

                esac

            else
                styled_echo 'Option unknown please use a value between 1 - 5.'
            fi
        done
}

# DEBUG ZONE
# ==========

# READ ARGUMENT
# =============

styled_echo 'initialize...' 3

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

        esac
    done

styled_echo "ACTION      = ${ACTION}" 3
styled_echo '' 3
styled_echo 'VERBOSE LEVEL: V' 1
styled_echo 'VERBOSE LEVEL: VV' 2
styled_echo 'VERBOSE LEVEL: VVV' 3
styled_echo '-----------------------------' 3

# ACTION MAPPING
# ==============

styled_echo 'action mapping...' 3
styled_echo '' 3

case ${ACTION} in

    version)
        styled_echo "University Evaluator v. ${VERSION}"
        rsync --version
    ;;

    mainmenu)
        actionMainMenu
    ;;

    help|*)
        styled_echo '-h, --help              Show this help (-h works with no other options)'
        styled_echo '-v, --verbose           increase verbosity [-v, -vv, -vvv]'
        styled_echo '    --version           Print version number'
        styled_echo '    --create-config     Create Config File'
        styled_echo '    --env=[ENVIRONMENT] Select a environment from config file to sync'
    ;;

esac

styled_echo 'finish!!!' 3