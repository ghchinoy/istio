#!/bin/bash

# Copyright 2017 Istio Authors

#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at

#       http://www.apache.org/licenses/LICENSE-2.0

#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# Local vars
ROOT=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
ARGS=(-alsologtostderr -test.v -v 2)

function error_exit() {
    # ${BASH_SOURCE[1]} is the file name of the caller.
    echo "${BASH_SOURCE[1]}: line ${BASH_LINENO[0]}: ${1:-Unknown Error.} (exit ${2:-1})" 1>&2
    exit ${2:-1}
}

. ${ROOT}/istio.VERSION || error_exit "Could not source versions"

TESTS_TARGETS=($(bazel query 'tests(//tests/e2e/tests/...)'))
FAILURE_COUNT=0
SUMMARY='Tests Summary'


for T in ${TESTS_TARGETS[@]}; do
  echo '****************************************************'
  echo "Running ${T}"
  echo '****************************************************'
  bazel ${BAZEL_STARTUP_ARGS} run ${BAZEL_RUN_ARGS} ${T} -- ${ARGS[@]} ${@}
  RET=${?}
  echo '****************************************************'
  if [[ ${RET} -eq 0 ]]; then
    SUMMARY+="\nPASSED: ${T} "
  else
    SUMMARY+="\nFAILED: ${T} "
    ((FAILURE_COUNT++))
  fi
done
echo
printf "${SUMMARY}\n"
exit ${FAILURE_COUNT}
