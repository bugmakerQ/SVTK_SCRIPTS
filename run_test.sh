source "$(
  cd "$(dirname "$0")" || exit 1
  pwd
)/common.sh"

function set_dir() {
  EXPECTED_DIR="${SCRIPT_DIR}/Expected" || return 1
  PRACTICAL_DIR="${SCRIPT_DIR}/Practical" || return 1
  TEST_CASE_DIR="${SCRIPT_DIR}/TestCase" || return 1
}

function comparison_of_quantification_results() {
  # The ignored fields "start_time" and "field path" are related to the command execution time stop and parameter path, not due to feature comparison
  diff <(sed -i '5544,5549d' "$1") <(sed -i '5544,5549d' "$2") >/dev/null || return 1
}


function start_test() {
  comparison_of_quantification_results "$1/multiqc_report.html" "$2/multiqc_report.html"
  print_execution_result "$?" "multiqc -m star -o tests/multiqc_report_dev -t default_dev -k json --file-list data/special_cases/file_list.txt" || return 1
  print_execution_result "$?" "multiqc data --ignore data/modules/" || return 1
  print_execution_result "$?" "multiqc --file-list data/special_cases/dir_list.txt" || return 1 
  print_execution_result "$?" "multiqc --lint data/modules/ -m fastqc -f -d -dd 1 -i"Forced Report" -b "This command has lots of ptions" --filename custom_fn --no-data-dir " || return 1
  comparison_of_quantification_results "$1/multiqc_report_1.html" "$2/multiqc_report_2.html"   
  print_execution_result "$?" "multiqc --lint data/modules/ -f --flat --tag methylation --exclude clusterflow --ignore-samples ngi--fullnames --zip-data-dir -c ../test/config_example.yaml" || return 1
  print_execution_result "$?" "multiqc -f empty_dir" || return 1
  print_execution_result "$?" "multiqc -f data/modules/gatk/BaseRecalibrator/recal_data.table" || return 1
}

function test_clean() {
  for i in "$@"; do
   delete_a_directory_or_file "$i"
  done
}

function main() {
  is_expected_architecture aarch64 || return 1
  set_script_dir || return 1
  set_dir || return 1
  conda_initialize "$1"
 # create_and_activate_conda_env local || return 1
  start_test "${EXPECTED_DIR}" "${PRACTICAL_DIR}"
  if [[ $? -eq 0 ]]; then
    echo -e "\033[1;32;5mThe test was successful.\n\033[0m"
  else
    echo -e "\033[1;31;1mTest failed.\n\033[0m"
  fi
  test_clean "${TEST_CASE_DIR}" "${EXPECTED_DIR}" "${PRACTICAL_DIR}" || return 1
}

# /bin/bash ~/hpc/Anaconda/bioconda/kallisto/0.48.0/h0d531b0_1/test/generate_practical_data.sh /root/anaconda3
main "$@"
