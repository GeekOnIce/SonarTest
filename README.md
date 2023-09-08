# SonarTest
Test project for the Sonar issue discussed in https://community.sonarsource.com/t/large-discrepancy-between-estimated-after-merge-and-overall-coverage/96681

In main, this test project is setup with code that is fully tested, some code that is completely untested, as well as a simple Swift script that is not directly part of the project. In the PR, an additional class is added which is only partially tested. The code and script is somewhat nonsensical, but is done to give some approximations to the problematic setup.

# Analysis method

The `run_sonar.sh` script was first run on the `main` branch to setup the baseline. This cleaned up the project, built and ran the tests, then used a Fastlane script to run a main branch analysis. After this, the `pr` branch was created and a PR was setup in GitHub. From this branch, the `run_sonar.sh` script was run, which ran a pull request analysis on the branch to get the pull request sonar data. After that, from this branch again, the `run_sonar.sh` script was run again with the `-post` argument, which ran main branch analysis on this branch instead of PR, and put the results to a `release-coverage-test` long lived branch to see the results. Between each test run, the environment was cleaned up to remove any test artifacts.

Based on prior experience, if the `pr` branch were to be merged in, the `main` branch would match this `release-coverage-test` branch exactly.

# Results

The `main` branch shows [30.3%](https://sonarcloud.io/summary/overall?id=GeekOnIce_SonarTest) test coverage.

The `pr` branch shows [56.7% Estimated after merge](https://sonarcloud.io/summary/new_code?id=GeekOnIce_SonarTest&pullRequest=1), but when the `pr` branch is run as a main branch analysis, it shows only [39.5%](https://sonarcloud.io/summary/overall?id=GeekOnIce_SonarTest&branch=release-coverage-test) coverage, not the 56.7% as indicated in as the after merge estimate.

This matches the problem described in real code from the community forum. In the actual project, the script files were added to the exclusion list since they weren't really meant to be tested, and that helped get us pretty close. From the results of this test project, I'm guessing that the difference between the estimate and final result is coming from completely untested code.

There are two xml files to note in the project. `main-coverage.xml` contains a copy of the `sonarqube-generic-coverage.xml` done after the main merge analysis. `pr-coverage.xml` in the `pr` branch is a copy of the same file, but done after the pull request analysis.

# Recreate results

The following steps should be valid to recreate the results after pulling this code locally. These effectively mirror the steps taken when creating the above results.

## Prerequisites

- Mac machine with Homebrew and git installed
    - Was using Xcode 14.3.1, though not expecting the exact version to matter
- A SonarCloud project that you can hook up to this GitHub repo, or ping me to get the `SONAR_TOKEN` value for testing using the existing project

## Setup

1. Clone this repo locally
1. Open terminal to the project directory, and run `swift scripts/setup.swift`
    1. This installs `fastlane` and `sonar-scanner` using homebrew
    1. Is not necessary if those are installed already, or you can do it manually
1. Modify the `run_sonar.sh` script
    1. Fill in the `SONAR_TOKEN` variable with either the token from a DM, or a token from a test project you control
    1. Modify other variables as necessary to fit your environment
1. Modify the `fastane/Fastfile` `sonar_organization` and `GeekOnIce_SonarTest` variables if using a different project

## Test steps

1. In the main branch, `sh run_sonar.sh` on the command line to generate the baseline Main branch
1. Clean test artifacts
1. Switch to the PR branch
1. Run `sh run_sonar.sh` on the command line to generate the pull request data, with the estimated coverage after merging
1. Clean test artifacts
1. Finally, run `sh run_sonar.sh -post` on the command line to generate a main-type analysis from the `pr` branch, to the `release-coverage-test` branch name in SonarCloud

After these steps are done, take a look at the Sonar project. The "Pull Requests" section should have one pull request listed. Take note of the _Estimate after merge_ number listed under that PR. Next, look at the "Branches" section, and open the `release-coverage-test` branch, and look at the "Overall Code". These were created with the same `sonarqube-generic-coverage.xml` file and the exact same code, but the numbers are different.
