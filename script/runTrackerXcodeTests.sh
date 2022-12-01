
#!/bin/bash
#
# runXcodeTests.sh
#
# Automated testing across iOS projects, schemes, versions and device models.
# Wraps functionality of xcodebuild, instruments, xcpretty.
# Expected to work on any machine supporting Xcode.
#
# See USAGE and USAGE_DETAILS below for help.  Or run script with -help.
#
#
#
# Relies upon instruments to capture current set of device models and versions supported by Xcode.
#   Use Xcode Preferences > Components to update this list.
#   instruments is installed by Xcode with other developer tools the first time it is run.
#
# To install xcpretty use "sudo gem install xcpretty".
#
#
#
# HOW DOES IT WORK?
#   * Schemes contain test suites which contain test classes which contain test methods.
#   * Schemes also support a variety of devices for each iOS version.
#
#   * The test script manages Xcode schemes, iOS Simulator devices and their versions in three different ways:
#       1) Define the target on the commandline with -scheme and -versionDevice
#       2) Skip the commandline and rely on internal hardwired lists:
#             STATIC_LIST_OF_SCHEMES
#             STATIC_LIST_OF_VERSIONS_AND_DEVICES
#       3) Skip both commandline and internal lists by asking Xcode:
#             DYNAMIC_LIST_OF_SCHEMES
#             DYNAMIC_LIST_OF_VERSIONS_AND_DEVICES
#
#     Review the help information for the different combinations in which these can be used.
#
#   * Manage which tests to run with -only-testing and -skip-testing.
#       These arguments are passed to xcodebuild.  Both can be used multiple times to define specific test coverage.
#       Both take an argument of the form, TestSuite/TestClass/TestMethod, where only the first
#         element of the tuple is required.
#
#       See the man page for xcodebuild(1) for further details.
#
#
#
# NB  Be sure Xcode is NOT RUNNING OR IN THE BACKGROUND while this script is run.
#
# NB  10% of the time it fails to generate any results under Jenkins.
#     This is an operational problem with Jenkins.  The test may not run, or may only run partially.
#



#------------------------------------------------------------ -o--
# Usage details.

BASENAME="$(basename $0)"

USAGE="
        Usage: $BASENAME [-help] [-dynamicInputs] [-showDynamicInputs]
                         project_directory
                         [-scheme scheme1 [-scheme scheme2 ...]]
                         [-versionDevice versionDevice1 [-versionDevice versionDevice2 ...]]
                         [additional_arguments_for_Xcodebuild]
  "

USAGE_DETAILS="

        -dynamicInputs  Run tests for all schemes, device models and versions offered by Xcode.
                          Ignores any inputs from -scheme and -versionDevice.

        -showDynamicInputs
                        Post Xcode config then exit.

        project_directory
                        Full path to Xcode project directory.

        -scheme         Name of scheme in which tests are run.
                          Use multiple times to name multiple schemes.

        -versionDevice  Name of device model and version.
                          Use format "version,device", where spaces in device are replaced with underscores.
                          Use multiple times to name multiple device model + version pairings.

        additional_arguments_for_Xcodebuild
                        Any additional arguments are passed directly to xcodebuild.
                          Use of -only-testing and -skip-testing span all test suites within a scheme.
                          See xcodebuild(1) manpage for further details.

        -help           Print these details.


        Only project_directory is mandatory.

        If -dynamicInputs is not given and either -scheme or -versionDevice are missing, then these values
          are taken from static lists hardcoded into the script.  See script header for details.
          Elements of these lists may be individually commented out for convenience.

        All commandline or static inputs are checked against current Xcode config (dynamic inputs), to be sure they are valid.

        Results are logged in the directory of the Xcode project file.

        SEE ALSO -- https://corpwiki.xandr-services.com/display/CT/Consistent+and+Reliable+Automated+Testing+with+Jenkins+for+iOS+Commits
  "




#------------------------------------------------------------ -o--
# Environment.

XCPRETTY=/usr/local/bin/xcpretty

export  LC_ALL=en_US.UTF-8
    # To prevent one-off errs in xcpretty.  See https://github.com/xcpretty/xcpretty/issues/190 .




#------------------------------------------------------------ -o--
# Globals.

#----------------------------- -o-
# Indices into Xcode project.

SEPARATION_CHAR=","     # Used to build tuples (without spaces) for device model + version.

SCHEMES=
VERSIONS_AND_DEVICES=
    # Later, these will contain final listing of schemes and device model + version tuples.

DYNAMIC_LIST_OF_SCHEMES=
DYNAMIC_LIST_OF_VERSIONS_AND_DEVICES=
    # Dynamic lists are created at runtime.



#----------------------------- -o-
# Static lists of Xcode options.
# NB  THESE MAY BE OUT OF DATE.  Use -dynamicInputs to see (and use) current values at startup.
#
# These lists may be cherry-picked by placing a sharp (#) immediately before an entry.
# Sharped entries are not tested.
#

#
# Hardcoded Xcode schemes.
#
STATIC_LIST_OF_SCHEMES="
    TrackerApp
    Integration
"
#
# Hardcoded Xcode device models and versios.
# See Xcode Preferences > Components to download additional entries.
#
# NB  Separate each tuple with SEPARATION_CHAR.
#
STATIC_LIST_OF_VERSIONS_AND_DEVICES="
    #11.1,iPhone_5s
    #11.1,iPhone_6
    #11.1,iPhone_6_Plus
    #11.1,iPhone_6s
    #11.1,iPhone_6s_Plus
    #11.1,iPhone_7
    #11.1,iPhone_7_Plus
    #11.1,iPhone_8
    #11.1,iPhone_8_Plus
    #11.1,iPhone_SE
    #11.1,iPhone_X
    #12.0,iPhone_6
    #13.4,iPhone_11
    #13.4,iPhone_11_Pro
    #13.4,iPhone_11_Pro_Max
    #13.4,iPhone_8
    #13.4,iPhone_8_Plus
    #13.4.1,iPhone_6s
    #13.4.1,iPhone_7
    #13.4.1,iPhone_8
    #13.4.1,iPhone_8_Plus
    #13.4.1,iPhone_SE
    #13.4.1,iPhone_11
    #13.4.1,iPhone_11_Pro
    #13.4.1,iPhone_11_Pro_Max
    #13.5,iPhone_11
    #13.5,iPhone_11_Pro
    #13.5,iPhone_11_Pro_Max
    #13.5,iPhone_8
    #13.5,iPhone_8_Plus
    #13.5,iPhone_SE
    #14.4,iPhone_11
    14.4,iPhone_12
    16.1,iPhone_14_Pro_Max
"



#----------------------------- -o-
# Internal variables.
#
# NB  All directories and filenames are updated and finalized after commandline parsing is complete and successful..

DATE=$(date '+%Y%m%d,%H%M' | tr 'A-Z' 'a-z')

PROJECT_DIRECTORY=      # NB  Defined based upon path to project directory.

TEST_RESULT_DIRECTORY="$(basename ${BASENAME} .sh)--results-${DATE}"

TEST_RESULT_DIRECTORY_PRETTY="html-summary"

TEST_RESULT_LOG="summary-of-all-tests.txt"
TEST_RESULT_TEMP="$(basename ${BASENAME} .sh)-temp.txt"

TEST_RESULT_CURRENT_FILE=
TEST_RESULT_CURRENT_FILE_PREFIX="buildAndTest--"

EXPECTED_FAILED_NUMBER=0

#
PROJECT=
PROJECT_DIRECTORY=

ADDITIONAL_XCODEBUILD_ARGUMENTS=

IS_DYNAMICINPUTS=
IS_SHOWDYNAMICINPUTS=




#------------------------------------------------------------ -o--
# Main functions.

#----------------------------- -o-
# NB  This function relies mostly on global variables.
#
# Local variables are taken from input arguments and manage internal state.
# All other variables are determined and fixed before this is run, including output files and test directories.
#
runXcodebuild()   # <scheme> <iosVersion> <deviceModel>
{
  local  SCHEME=$1
  local  IOSVERSION=$(stripTrailingDotZero $2)
  local  DEVICEMODEL=$3

  local  CMD=

  [ -z "$SCHEME"  -o  -z "$IOSVERSION"  -o  -z "$DEVICEMODEL" ] && {
    echo "runXcodeBuild(): MISSING arguments.  (SCHEME=$SCHEME IOSVERSION=$IOSVERSION DEVICEMODEL=$DEVICEMODEL)"  1>&2
    exit 1
  }


  #
  CMD="
        xcodebuild test
                -project $PROJECT
                -scheme $SCHEME
                -destination \"$(makeDestination $IOSVERSION $DEVICEMODEL)\"
                -parallel-testing-enabled NO
                -maximum-concurrent-test-simulator-destinations 1
                $ADDITIONAL_XCODEBUILD_ARGUMENTS
    "

  TEST_RESULT_CURRENT_FILE="$TEST_RESULT_DIRECTORY/${TEST_RESULT_CURRENT_FILE_PREFIX}${IOSVERSION},${DEVICEMODEL}--${SCHEME}.txt"

  eval $CMD 2>&1  | tee $TEST_RESULT_CURRENT_FILE

  cat $TEST_RESULT_CURRENT_FILE | egrep '^(Test Suite|[     ]+Executed)'  >$TEST_RESULT_TEMP
  cat $TEST_RESULT_CURRENT_FILE | egrep -v '===' | $XCPRETTY -r html -o $TEST_RESULT_DIRECTORY_PRETTY/${IOSVERSION},${DEVICEMODEL}--${SCHEME}.html

  EXPECTED_FAILED_NUMBER=$(cat $TEST_RESULT_TEMP | egrep -c "'All tests' failed")

  cat $TEST_RESULT_TEMP  >>$TEST_RESULT_LOG
  rm $TEST_RESULT_TEMP
  return 0
}




#------------------------------------------------------------ -o--
# Helper functions.

#----------------------------- -o-
# Only for iOS Simulator.
# Replace underscores (_) in device model with spaces.
#
makeDestination()   # <iosVersion> <deviceModel>
{
  local  IOSVERSION=$1
  local  DEVICEMODEL=$2

  [ -z "$IOSVERSION"  -o  -z "$DEVICEMODEL" ] && {
    post "makeDestination(): MISSING arguments.  (IOSVERSION=$IOSVERSION DEVICEMODEL=$DEVICEMODEL)"  1>&2
    exit 1
  }


  #
  echo "platform=iOS Simulator,name=$DEVICEMODEL,OS=$IOSVERSION" | sed 's/_/ /g'
}



#----------------------------- -o-
stripTrailingDotZero() {
  echo $1 | sed 's/\.0$//'
}

#----------------------------- -o-
isSharped()  # <string>
{
  [ $(expr "$1" : "#") -eq 1 ]
}

#----------------------------- -o-
isOptionTokenOrEmptyString()  # <token>
{
  local  TOKEN=$1
  local  RVAL=

  #
  [ -z "$TOKEN" ] && { return 1; }

  #
  RVAL=$(expr "$TOKEN" : "\-")
  [ "$RVAL" = "0" ]

  return  $?
}

#----------------------------- -o-
post()  # [nocr|error]
{
  local  NOCR_FLAG=
  local  ERROR_FLAG=

  #
  [ "nocr"x = "$1"x ] && {
    NOCR_FLAG=-n
    shift
  }

  [ "error"x = "$1"x ] && {
    ERROR_FLAG=true
    shift
  }

  #
  [ "$ERROR_FLAG" ] && {
    echo "${BASENAME}(): $*"  1>&2
  } || {
    echo $NOCR_FLAG "${BASENAME}(): $*"
  }
}

#----------------------------- -o-
log()
{
  {
    echo $*  | tee -a $TEST_RESULT_LOG
  }
}

#----------------------------- -o-
postUsageAndExit()  # [details]
{
  [ "details"x = "$1"x ] && {
    cat <<THIMK  1>&2
      $USAGE
      $USAGE_DETAILS
THIMK
  } || {
    echo $USAGE  1>&2
  }

  exit  1
}

#----------------------------- -o-
showDynamicInputsAndExit()
{
  echo
  echo "DYNAMIC_LIST_OF_SCHEMES --"
  echo

  cat <<THIMK           | sed 's/^/    /'
$DYNAMIC_LIST_OF_SCHEMES
THIMK

  echo
  echo "DYNAMIC_LIST_OF_VERSIONS_AND_DEVICES --"
  echo

  cat <<THIMK           | sed 's/^/    /'
$DYNAMIC_LIST_OF_VERSIONS_AND_DEVICES
THIMK

  echo

  exit  0
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
captureDynamicListOfSchemes()
{
  [ -z "$PROJECT_DIRECTORY" ] && {
    post error "captureDynamicListOfSchemes(): PROJECT_DIRECTORY is undefined."
    exit 1
  }

  post nocr "Capturing Xcode schemas...  "


  #
  pushd $PROJECT_DIRECTORY  2>&1 >/dev/null

  DYNAMIC_LIST_OF_SCHEMES=$(
        xcodebuild test -list   |

          awk '
          BEGIN                     { enableOutput = 0; }
          (enableOutput > 0)        { print $0; }
          /Schemes:$/               { enableOutput = 1; }
          '                     |           # Return schemes.

          sed 's/ //g'                      # XXX  Remove single whitespaces.
      )

  #
  popd  2>&1 >/dev/null
  echo Done.
}

#----------------------------- -o-
captureDynamicListOfVersionsAndDevices()
{
  post nocr "Capturing Xcode device models and versions...  "

  DYNAMIC_LIST_OF_VERSIONS_AND_DEVICES=$(
        instruments -s devices                                  |
            egrep -w Simulator                                  |   # Filter: Only Simulator devices.
            egrep -wv 'iPad|Watch|TV'                           |   # Filter: Only iPhone (given as, NOT other devices)

            sed 's;^\(.*\) \[.*$;\1;'                           |   # Cleanup: Discard UUID and other notations.
            sed 's;^\(.*\) (\(.*\))$;\1  \2;'                   |   # Capture device model and version number.  Separate with doublespace.

            sed 's/ /_/g'                                       |   # Convert spaces to underscores.
            sed "s;\(.*\)__\(.*\);\2${SEPARATION_CHAR}\1;"      |   # Reformat as version number + device model.

            sort -u                                                 # Sort by version number strings.
    )

  #
  echo Done.
}



#----------------------------- -o-
isValidScheme()  # <schemeInput>
{
  local  schemeInput=$1

  [ "$schemeInput" ] && {
    echo $DYNAMIC_LIST_OF_SCHEMES | egrep -w $schemeInput  >/dev/null
    return  $?
  }

  return  1
}

#----------------------------- -o-
isValidVersionDevice()  # <versionDeviceInput>
{
  local  versionDeviceInput=$1

  [ "$versionDeviceInput" ] && {
    echo $DYNAMIC_LIST_OF_VERSIONS_AND_DEVICES | egrep -w $versionDeviceInput  >/dev/null
    return  $?
  }

  return  1
}



#----------------------------- -o-
setPathToResultsDirectoryAndLogFiles()
{
  [ -z "$PROJECT_DIRECTORY" ] && {
    post error "setPathToResultsDirectoryAndLogFiles(): PROJECT_DIRECTORY is undefined."
    exit 1
  }

  #
  TEST_RESULT_DIRECTORY="$PROJECT_DIRECTORY/$TEST_RESULT_DIRECTORY"
  TEST_RESULT_DIRECTORY_PRETTY="$TEST_RESULT_DIRECTORY/$TEST_RESULT_DIRECTORY_PRETTY"
  TEST_RESULT_LOG="$TEST_RESULT_DIRECTORY/$TEST_RESULT_LOG"
  TEST_RESULT_TEMP="$TEST_RESULT_DIRECTORY/$TEST_RESULT_TEMP"


  #
  mkdir $TEST_RESULT_DIRECTORY
}




#------------------------------------------------------------ -o--
# Main.

#----------------------------- -o-
# Help first.

case "$1" in
    -help|--help|-h)
        postUsageAndExit details        ;;

    "")
        postUsageAndExit                ;;
esac



#----------------------------- -o-
# Parse inputs.
#
# NB  Unrecognized options are passed through to xcodebuild...

while [ "$1" ]; do
  case "$1" in
    -dynamicInputs|-di)
        IS_DYNAMICINPUTS=true           ;;

    -showDynamicInputs|-sdi)
        IS_SHOWDYNAMICINPUTS=true       ;;

    -scheme|-s)
        isOptionTokenOrEmptyString "$2"
        [ $? -ne 0 ] && {
          post error "Scheme is missing."
          echo
          postUsageAndExit;
        }

        SCHEMES="$SCHEMES $2"
        shift                           ;;

    -versionDevice|-vd)
        isOptionTokenOrEmptyString "$2"
        [ $? -ne 0 ] && {
          post error "Version+device tuple is missing."
          echo
          postUsageAndExit;
        }

        VERSIONS_AND_DEVICES="$VERSIONS_AND_DEVICES $2"
        shift                           ;;

    *)
        [ "$PROJECT" ] && {
          ADDITIONAL_XCODEBUILD_ARGUMENTS="$ADDITIONAL_XCODEBUILD_ARGUMENTS $1"
          shift
          continue
        }

        #
        PROJECT=$1

        [ ! -d "$PROJECT" ] && {
          post error "Project name is not a directory or does not exist.  ($PROJECT)"
          echo
          postUsageAndExit
        }

        [ "$(basename $PROJECT)" = "$(basename $PROJECT .xcodeproj)" ] && {
          post error "Project directory must end with suffix \".xcodeproj\".  ($PROJECT)"
          echo
          postUsageAndExit
        }

        PROJECT_DIRECTORY=$(dirname $PROJECT)
        PROJECT_DIRECTORY=${PROJECT_DIRECTORY:-"./"}
                                        ;;
  esac

  shift
done



#----------------------------- -o-
# Sanity check parse results.
# Query Xcode for current support.
# Finalize directory and file paths.
# Set DEFAULTS.
# Compare scheme, device and version choices against current data from Xcode.

[ -z "$PROJECT" ] && {
  post error "PROJECT is undefined."
  echo
  postUsageAndExit
}


#
captureDynamicListOfSchemes
captureDynamicListOfVersionsAndDevices

[ "$IS_SHOWDYNAMICINPUTS" ] && {
  showDynamicInputsAndExit
}


#
setPathToResultsDirectoryAndLogFiles


#
[ -z "$SCHEMES" ] && {
  SCHEMES=$STATIC_LIST_OF_SCHEMES

  post "Using static inputs for SCHEMES."
}

[ -z "$VERSIONS_AND_DEVICES" ] && {
  VERSIONS_AND_DEVICES=$STATIC_LIST_OF_VERSIONS_AND_DEVICES

  post "Using static inputs for VERSIONS_AND_DEVICES."
}


#
[ "$IS_DYNAMICINPUTS" ] && {
  SCHEMES=$DYNAMIC_LIST_OF_SCHEMES
  VERSIONS_AND_DEVICES=$DYNAMIC_LIST_OF_VERSIONS_AND_DEVICES

  post "Using dynamic inputs for SCHEMES and VERSIONS_AND_DEVICES."

} || {
  for s in $SCHEMES; do
      isSharped "$s"
      [ $? -eq 0 ] && continue

      isValidScheme $s
      [ "$?" -ne 0 ] && {
        post error "Scheme is UNRECOGNIZED by Xcode.  ($s)"
        echo
        postUsageAndExit;
      }
  done

  # for vd in $VERSIONS_AND_DEVICES; do
  #   isSharped "$vd"
  #   [ $? -eq 0 ] && continue
  #
  #   isValidVersionDevice $vd
  #   [ "$?" -ne 0 ] && {
  #     post error "Version+device tuple is UNRECOGNIZED by Xcode.  ($vd)"
  #     echo
  #     postUsageAndExit;
  #   }
  # done
}


for version_and_device  in ${VERSIONS_AND_DEVICES[@]}
do
  iosVersion=
  deviceModel=

  isSharped "$version_and_device"
  [ $? -eq 0 ] && continue

  IFS=$SEPARATION_CHAR  read -r iosVersion deviceModel <<< "$version_and_device"


  #
  for scheme in $SCHEMES;
  do
    isSharped "$scheme"
    [ $? -eq 0 ] && continue

    deleteDerivedData

    runXcodebuild $scheme $iosVersion $deviceModel

  done  #SCHEMES
done  #VERSIONS_AND_DEVICES



#
if [ "$EXPECTED_FAILED_NUMBER" -gt "0" ];then
  log "#------- FOUND FAILED TESTCASES"
  exit 1
else
  log "#------- ALL TESTCASES PASSED"
  exit 0
fi
