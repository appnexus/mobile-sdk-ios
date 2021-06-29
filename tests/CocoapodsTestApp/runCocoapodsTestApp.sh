#!/bin/bash
#
# runProjectUnitTests.sh
#
# Automated unit testing across iOS models, OS versions and Xcode application schemes.
#
# To choose which models, OS versions and schemes are tested,
#   sharp (#) or un-sharp the appropriate entries in the Globals section below.
#
#
# Use -dry-run option to validate that all combinations of SCHEMES, MODELS and IOS_VERSIONS will i
#   results in successful runs of xcodebuild.
#   If all are acceptable, then the dry run should iterate through all the options quickly (2-3 seconds per combination).
#   If any options is not acceptable, the dry run will stall about 15 seconds then print a somewhat useful error message.
#
# HOW-TO AUTOMATE MULTIPLE UNIT TESTS--
#
#   1) Find the project of your choice, which contains unit tests;
#   2) Copy this script into the project, at the same level as the *.xcodeproj file directory.
#   3) Run the project once, at least long enough to open the macOS simulator app;
#   4) Configure SCHEMES below to contain the schemes in the project that need to be tested;
#   5) Configure the MODELS and IOS_VERSIONS below according to need;
#   6) Run the copy of this script created in Step #2;
#   7) Look for the results in a sibling directory with the same prefix as this script.
#
#
# TBDFIX --
#       . decide on input args for...
#          + specific real devices.
#          + override internal lists
#       . use confrig file?
#       . quiet option?
#       . tee passed/failed results to log in realtime...
#   **  . clarify how Simmulator must be setup in advance -- is running?  is UI automation activated?  ...
#

#set -x

BASENAME="$(basename $0)"

USAGE="Usage: $BASENAME [-dry-run]"

IS_DRYRUN=      # Empty value means false.
DRYRUN_LABEL=




#------------------------------------------------------------ -o--
# Globals.

#----------------------------- -o-
# NB  Precede individual entries with a sharp (#) to keep them from being used.
# NB  Use underscore (_) for spaces.  These are removed automatically.
# NB  USE pipe (|) to seperate MODEL,OS_VERSION and ARCHITECTURE
#
# SCHEMES taken from mobile-sdk-ios/tests/NewTestApp.xcodeproj.
# MODELS and IOS_VERSIONS taken from Xcode 8.3.

SCHEMES="
  CocoapodsTestApp
"

#MODELS_PHONE="
#  iPhone_8|13.5|arm64
#  iPhone_8|14.4|arm64
#  iPhone_X|12.4|arm64
#"

MODELS_PHONE=""



deviceVar=$(( $RANDOM % 3 ));
echo $deviceVar

if [ $deviceVar == 0 ]
then
MODELS_PHONE="
  iPhone_11|14.4|arm64
  iPhone_8|13.5|arm64
  iPhone_11|13.5|arm64
  iPhone_X|12.1|arm64
"
elif [ $deviceVar == 1  ]
then

MODELS_PHONE="
  iPhone_12|14.4|arm64
  iPhone_8_Plus|13.5|arm64
  iPhone_8|12.1|arm64
  iPhone_11_Pro|13.5|arm64
"
else


MODELS_PHONE="
  iPhone_12_Pro|14.4|arm64
  iPhone_SE|13.5|arm64
  iPhone_8|12.1|arm64
  iPhone_11_Pro_Max|13.5|arm64
"
fi


echo $MODELS_PHONE


#MODEL|OS_VERSION_TO_TEST|ARCHITECTURE


MODELS="
  $MODELS_PHONE
"


#----------------------------- -o-
DATE=$(date '+%Y%m%d,%H%M' | tr 'A-Z' 'a-z')

TEST_RESULT_DIRECTORY="$(basename ${BASENAME} .sh)-results--${DATE}"

TEST_RESULT_LOG=$TEST_RESULT_DIRECTORY/testResultLog.txt
TEST_RESULT_TEMP="$TEST_RESULT_DIRECTORY/$(basename ${BASENAME} .sh)-temp.txt"
TEST_RESULT_CURRENT_FILE=

TOTAL_PASS=0
TOTAL_FAIL=0

TOTAL_TIME_START=
TOTAL_TIME_END=
TOTAL_TIME_DIFFERENCE=


model=
osversion=
architecture=




#------------------------------------------------------------ -o--
# Main functions.

#----------------------------- -o-
runXcodebuild()   # <scheme> <model> <osversion>
{
  local  SCHEME=$1
  local  MODEL=$2
  local  OSVERSION=$(stripTrailingDotZero $3)

  local  DESTINATION=
  local  CMD=

  local  TIME_START=
  local  TIME_END=
  local  TIME_DIFFERENCE=

  local  SUITES_PASSED=0
  local  SUITES_FAILED=0


  [ -z "$SCHEME"  -o  -z "$MODEL"  -o  -z "$OSVERSION" ] && {
    echo "runXcodeBuild(): MISSING arguments.  (SCHEME=$SCHEME MODEL=$MODEL OSVERSION=$OSVERSION)"  1>&2
    exit 1
  }


  #
  DESTINATION="$(makeDestination $MODEL $OSVERSION)"
  CMD="xcodebuild test -workspace $SCHEME.xcworkspace -scheme $SCHEME -destination \"$DESTINATION\" "
  TEST_RESULT_CURRENT_FILE="$TEST_RESULT_DIRECTORY/xcodeBuildResults--${OSVERSION},${MODEL}--${SCHEME}.txt"


  log "#-------------------------------------------------------------------- -o--"
  TIME_START=$(date '+%s')
  log "#------- START: $(dateStringFromSeconds $TIME_START)"
  log $CMD

  eval $CMD  2>&1  | tee $TEST_RESULT_CURRENT_FILE  | xcpretty -r html

  TIME_END=$(date '+%s')
  TIME_DIFFERENCE=$(expr $TIME_END - $TIME_START)
  log "#------- END: $(dateStringFromSeconds $TIME_END) -- $(daysHoursMinSecs $TIME_DIFFERENCE)"


  #
  cat $TEST_RESULT_CURRENT_FILE | egrep '^(Test Suite|[ 	]+Executed)'  >$TEST_RESULT_TEMP        # whitespace == [space + tab]

  SUITES_PASSED=$(cat $TEST_RESULT_TEMP | egrep -c -w "passed")
  SUITES_FAILED=$(cat $TEST_RESULT_TEMP | egrep -w "failures" | egrep -c -v 'with 0 failures')

  TOTAL_PASS=$(expr $TOTAL_PASS + $SUITES_PASSED)
  TOTAL_FAIL=$(expr $TOTAL_FAIL + $SUITES_FAILED)

  log ""
  log "#------- SUITES_PASSED=$SUITES_PASSED"
  log "#------- SUITES_FAILED=$SUITES_FAILED"
  log ""
  cat $TEST_RESULT_TEMP  >>$TEST_RESULT_LOG
  log ""
  log ""
  log ""
  log ""


  #
  rm $TEST_RESULT_TEMP
  return 0
}


#----------------------------- -o-
runXcodebuildDryRun()   # <scheme> <model> <osversion>
{
  local  SCHEME=$1
  local  MODEL=$2
  local  OSVERSION=$(stripTrailingDotZero $3)

  local  DESTINATION=
  local  CMD=

  local  TIME_START=
  local  TIME_END=
  local  TIME_DIFFERENCE=

  local  SUITES_PASSED=0
  local  SUITES_FAILED=0


  [ -z "$SCHEME"  -o  -z "$MODEL"  -o  -z "$OSVERSION" ] && {
    echo "runXcodebuildDryRun(): MISSING arguments.  (SCHEME=$SCHEME MODEL=$MODEL OSVERSION=$OSVERSION)"  1>&2
    exit 1
  }


  #
  DESTINATION="$(makeDestination $MODEL $OSVERSION)"
  CMD="xcodebuild -dry-run test -scheme $SCHEME -destination \"$DESTINATION\" "
  TEST_RESULT_CURRENT_FILE="$TEST_RESULT_DIRECTORY/xcodeBuildResults--${OSVERSION},${MODEL}--${SCHEME}.txt"


  log "#-------------------------------------------------------------------- -o--"
  TIME_START=$(date '+%s')
  log "#------- ${DRYRUN_LABEL}START: $(dateStringFromSeconds $TIME_START)"
  log $CMD

  eval $CMD  2>&1

  TIME_END=$(date '+%s')
  TIME_DIFFERENCE=$(expr $TIME_END - $TIME_START)
  log "#------- ${DRYRUN_LABEL}END: $(dateStringFromSeconds $TIME_END) -- $(daysHoursMinSecs $TIME_DIFFERENCE)"

  echo; echo

  return 0
}



#------------------------------------------------------------ -o--
# Helper functions.

#----------------------------- -o-
# NB  ASSUME  (for now) iOS Simulator only.
# NB  Replace underscores (_) with spaces...
#
makeDestination()   # <model> <osversion>
{
  local  MODEL=$1
  local  OSVERSION=$2

  [ -z "$MODEL"  -o  -z "$OSVERSION" ] && {
    post "makeDestination(): MISSING arguments.  (MODEL=$MODEL OSVERSION=$OSVERSION)"  1>&2
    exit 1
  }


  #
  echo "platform=iOS Simulator,name=$MODEL,OS=$OSVERSION" | sed 's/_/ /g'
}


#----------------------------- -o-
isSharped()  # <string>
{
  [ $(expr "$1" : "#") -eq 1 ]
}


#----------------------------- -o-
post()
{
  echo "${BASENAME}(): $*"
}


#----------------------------- -o-
log()
{
  [ "$IS_DRYRUN" ] && {
    echo $*
  } || {
    echo $*  | tee -a $TEST_RESULT_LOG
  }
}


#----------------------------- -o-
daysHoursMinSecs() {
  local  VALUE_IN_SECONDS=$1

  local  DAYS=$(expr $VALUE_IN_SECONDS / 60 / 60 / 24)
  local  HOURS=$(expr $VALUE_IN_SECONDS / 60 / 60 % 24)
  local  MINUTES=$(expr $VALUE_IN_SECONDS / 60 % 60)
  local  SECONDS=$(expr $VALUE_IN_SECONDS % 60)

  [ $DAYS -le 9 ]    && { DAYS="0$DAYS"; }
  [ $HOURS -le 9 ]   && { HOURS="0$HOURS"; }
  [ $MINUTES -le 9 ] && { MINUTES="0$MINUTES"; }
  [ $SECONDS -le 9 ] && { SECONDS="0$SECONDS"; }


  #
  [ $DAYS -ne 0 ] && {
    DAYS=$(expr $DAYS - 0)
    echo -n ${DAYS}+${HOURS}:${MINUTES}:${SECONDS} days
    true
  } || {
    [ $HOURS -ne 0 ] && {
      HOURS=$(expr $HOURS - 0)
      echo -n ${HOURS}:${MINUTES}:${SECONDS} hours
      true
    } || {
      [ $MINUTES -ne 0 ] && {
        MINUTES=$(expr $MINUTES - 0)
        echo -n ${MINUTES}:${SECONDS} minutes
        true
      } || {
        SECONDS=$(expr $SECONDS - 0)
        echo -n ${SECONDS} seconds
      }
    }
  }
}


#----------------------------- -o-
dateStringFromSeconds() {
  local  INPUTDATE=${1:-"$(date '+%s')"}
  echo -n $(date -j -f '%s' $INPUTDATE "$DATE_FORMAT")
}


#----------------------------- -o-
listOfUnsharpedTokens()   # <list_of_tokens>
{
  local  UNSHARPED_TOKENS=""

  for token in $*; do
    isSharped "$token"
    [ $? -eq 0 ] && continue

    UNSHARPED_TOKENS="$UNSHARPED_TOKENS $token"
  done

  echo $UNSHARPED_TOKENS
}





#----------------------------- -o-
deleteDerivedData() {
  local  DERIVEDDATADIR=~/Library/Developer/Xcode/DerivedData

  echo -n "DELETING DerivedData directory...  "

  rm -rf $DERIVEDDATADIR/*

  echo "Done."
  echo
}


#----------------------------- -o-
stripTrailingDotZero() {
  echo $1 | sed 's/\.0$//'
}




#------------------------------------------------------------ -o--
# Main.

#
case "$1" in
  -dry-run|--dry-run|-dryrun|--dryrun|dryrun|d|dr)
        IS_DRYRUN=true
        DRYRUN_LABEL="DRY RUN "         ;;

  *)    [ "$1" ] && {
          echo $USAGE 1>&2
          exit 1
        }                               ;;

esac





# Proactive warnings about potential problems with this test...
#
cat <<XCODE_SUPPORT_FOR_TESTVECTORS

    ==============================================
    ::: WARNING :::

    Be sure that the combinations of SCHEMA, MODEL AND IOS_VERSION all exist in your working version of Xcode.
    This may require downloading Simulators in Xcode via Preferences --> Components.

    Determine which ones you have by opening Xcode and looking at the active schema pulldown menu in the upper lefthand corner of the IDE.
    Validate these results by using the following command to execute a dry run of this test:

        $BASENAME --dry-run
    ==============================================

XCODE_SUPPORT_FOR_TESTVECTORS

echo -n "<CR> to continue or CONTROL-C to quit...   "
read ch


#
cat <<XCODE_IN_BACKGROUND

    ==============================================
    ::: WARNING :::

    Be sure that Xcode or the Simulator, or process that support them, are not running in the background.

    Use the following command to find and delete these processes:

        kill -HUP \$(ps auwwx | egrep -w Xcode | awk '{ print \$2 }')
    ==============================================

XCODE_IN_BACKGROUND

echo -n "<CR> to continue or CONTROL-C to quit...   "
read ch

echo; echo

#
[ -z "$IS_DRYRUN" ] && {
  mkdir $TEST_RESULT_DIRECTORY
}
log ""
log ""
log "List of available models"
instruments -s devices
log ""
log "MODELS Test run in -- $(listOfUnsharpedTokens $MODELS)"
log ""
log "SCHEMES -- $(listOfUnsharpedTokens $SCHEMES)"
log ""
log ""
log ""

TOTAL_TIME_START=$(date '+%s')
log "#------- ALL TESTS ${DRYRUN_LABEL}START: $(dateStringFromSeconds $TOTAL_TIME_START)"
log ""


for model_os_version_under_test in ${MODELS[@]}
    do
    isSharped "$model_os_version_under_test"
    [ $? -eq 0 ] && continue

    IFS=$'|' read -r model osversion architecture <<< "$model_os_version_under_test"

    for scheme in $SCHEMES;
    do
      isSharped "$scheme"
      [ $? -eq 0 ] && continue


      TEST_REPORT_DIRECTORY="$TEST_RESULT_DIRECTORY/xcpretty-${scheme}"

      [ -z "$IS_DRYRUN" ] && {
        mkdir -p $TEST_REPORT_DIRECTORY
      }

      #
      [ "$IS_DRYRUN" ] && {
        runXcodebuildDryRun $scheme $model $osversion
        continue
      }

      deleteDerivedData
      runXcodebuild $scheme $model $osversion
      mv build/reports/tests.html "$TEST_REPORT_DIRECTORY/TestResults-${model},${osversion},${architecture}.html"

      set -
    done  #SCHEMES
done  #MODELS


#
[ -z "$IS_DRYRUN" ] && {
  log ""
  log ""
  log "#------- TOTAL_PASS=$TOTAL_PASS"
  log "#------- TOTAL_FAIL=$TOTAL_FAIL"
}

TOTAL_TIME_END=$(date '+%s')
TOTAL_TIME_DIFFERENCE=$(expr $TOTAL_TIME_END - $TOTAL_TIME_START)

log ""
log "#------- ALL TESTS ${DRYRUN_LABEL}END: $(dateStringFromSeconds $TOTAL_TIME_END) -- $(daysHoursMinSecs $TOTAL_TIME_DIFFERENCE)"


#
exit 0
