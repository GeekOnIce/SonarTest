#!/bin/sh

set -e

CI_WORKSPACE="/Users/darrell.bennington/projects/SonarTest"
SONAR_TOKEN="" #Fill in with real value
CI_RESULT_BUNDLE_PATH="/Users/darrell.bennington/Library/Developer/Xcode/DerivedData/SonarTest.xcresult"
CI_DERIVED_DATA="/Users/darrell.bennington/Library/Developer/Xcode/DerivedData"
CI_PULL_REQUEST_TARGET_BRANCH="main"
CI_PULL_REQUEST_SOURCE_BRANCH="pr"
CI_PULL_REQUEST_NUMBER="1"
CI_PROJECT_FILE_PATH="/Users/darrell.bennington/projects/SonarTest/SonarTest.xcodeproj"
CI_BRANCH="main"
CI_BRANCH_FOR_PR_AS_MAIN="release-coverage-test"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ $CURRENT_BRANCH != "main" ] && [ $CURRENT_BRANCH != "pr" ]
then
    echo "Unexpected branch '$CURRENT_BRANCH'!"
    echo "This script is only expecting 'main' or 'pr'"
    exit 1
fi

rm -rf $CI_RESULT_BUNDLE_PATH

xcodebuild clean \
    -scheme SonarTest \
    -project "$CI_PROJECT_FILE_PATH" \
    -destination 'platform=iOS Simulator,name=iPhone 14 Pro' \
    -derivedDataPath "$CI_DERIVED_DATA" \

xcodebuild build-for-testing \
    -scheme SonarTest \
    -project "$CI_PROJECT_FILE_PATH" \
    -destination 'platform=iOS Simulator,name=iPhone 14 Pro' \
    -derivedDataPath "$CI_DERIVED_DATA" \
    -resultBundleVersion 3 \
    -resultBundlePath "$CI_RESULT_BUNDLE_PATH" \
    -IDEPostProgressNotifications=YES CODE_SIGN_IDENTITY=- AD_HOC_CODE_SIGNING_ALLOWED=YES COMPILER_INDEX_STORE_ENABLE=NO DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
    -hideShellScriptEnvironment

rm -rf $CI_RESULT_BUNDLE_PATH

xcodebuild test-without-building \
    -project "$CI_PROJECT_FILE_PATH" \
    -scheme "SonarTest" \
    -destination 'platform=iOS Simulator,name=iPhone 14 Pro' \
    -enableCodeCoverage YES \
    -derivedDataPath "$CI_DERIVED_DATA" \
    -resultBundlePath "$CI_RESULT_BUNDLE_PATH"

if [ "$CURRENT_BRANCH" = "pr" ]
then
    if [ "$1" == "-post" ]
    then
        echo "Executing PR request as post-merge main branch analysis"

        fastlane sonar_analysis_main_merge \
            result_path:$CI_RESULT_BUNDLE_PATH \
            workspace:$CI_WORKSPACE \
            sonar_token:$SONAR_TOKEN \
            branch:$CI_BRANCH_FOR_PR_AS_MAIN
    else
        echo "Executing PR request"

        fastlane sonar_analysis_pr \
            result_path:$CI_RESULT_BUNDLE_PATH \
            workspace:$CI_WORKSPACE \
            sonar_token:$SONAR_TOKEN \
            target_branch:$CI_PULL_REQUEST_TARGET_BRANCH \
            source_branch:$CI_PULL_REQUEST_SOURCE_BRANCH \
            pr_number:$CI_PULL_REQUEST_NUMBER
    fi

elif [ "$CURRENT_BRANCH" = "main" ]
then
    echo "Executing main branch analysis"

    fastlane sonar_analysis_main_merge \
        result_path:$CI_RESULT_BUNDLE_PATH \
        workspace:$CI_WORKSPACE \
        sonar_token:$SONAR_TOKEN \
        branch:$CI_BRANCH
fi 
