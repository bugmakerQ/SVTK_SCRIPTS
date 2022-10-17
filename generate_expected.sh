#!/bin/bash

source "$(
  cd "$(dirname "$0")" || exit 1
  pwd
)/common.sh"

function download_test_case_data() {
  git clone https://github.com/bugmakerQ/TEST_SVTK.git TestCase || return 1
  if [ $? -eq 1 ]; then
    echo -e "\033[1;31;1mTest case download failed,Please rerun the current script.\033[0m"
    return 1
  fi
}

function main() {
  
  is_expected_architecture x86_64 || return 1
  set_script_dir || return 1
  download_test_case_data || return 1
  conda_initialize "$2"
  source ~/.bashrc
  create_and_activate_conda_env bioconda || return 1
  local EXPECTED_DIR
  EXPECTED_DIR="${SCRIPT_DIR}/Expected"
  time  generate_execution_result_data "${EXPECTED_DIR}"
  if [[ $? -eq 0 ]]; then
    echo -e "\033[1;32;1mSuccessfully generated expected data.\033[0m"
  else
    echo -e "\033[1;31;1mFailed to generate expected data.\033[0m"
    delete_a_directory_or_file "${EXPECTED_DIR}"
  fi
}

main "$@"
