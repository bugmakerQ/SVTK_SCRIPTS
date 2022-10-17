function is_expected_architecture() {
  if [ $(uname -m) != "$1" ]; then
    echo -e "\033[1;31;1mThe current script only supports execution on $1 architecture.\033[0m"
    return 1
  fi
}

function set_script_dir() {
  local REL_SCRIPT_DIR
  REL_SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")" || return 1
  SCRIPT_DIR="$(cd "${REL_SCRIPT_DIR}" && pwd)" || return 1
}

function delete_a_directory_or_file() {
  if [ -e "$1" ]; then
    rm -rf "$1" || return 1
  fi
}

function safely_create_a_directory() {
  delete_a_directory_or_file "$1"
  mkdir "$1" || return 1
}

function conda_initialize() {
  __conda_setup="$("$1/bin/conda" 'shell.bash' 'hook' 2>/dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  else
    if [ -f "$1/etc/profile.d/conda.sh" ]; then
      . "$1/etc/profile.d/conda.sh"
    else
      export PATH="$1/bin:$PATH"
    fi
  fi
  unset __conda_setup
}

function create_and_activate_conda_env() {
  source ~/.bashrc
  conda deactivate 
  conda env remove -n test_svtk -y || return 1
  conda create -n test_svtk -c "$1" svtk=0.0.20190615 -y || return 1
  conda activate test_svtk || return 1
  echo environment is built successfully
}

function generate_execution_result_data() {
  EXPECTED_DIR="${SCRIPT_DIR}/Expected"
  safely_create_a_directory "$1" || return 1
  cd "${SCRIPT_DIR}/TestCase"  || return 1
  mkdir $1/pe_count
  mkdir $1/count
  mkdir $1/split_count
  svtk count-svtypes example.vcf |tee $1/svtk_out.txt
  svtk collect-pesr sample.bam $1/split_count/sample_0.txt $1/pe_count/sample.txt $1/count/sample_1.txt
  cat  $1/count/sample_1.txt
}

function print_execution_result() {
  if [ "$1" -eq 0 ]; then
    echo -e "\033[1;32;1m'$2' executed successfully.\n\033[0m"
  else
    echo -e "\033[1;31;1m'$2' execution result does not match expected result.\n\033[0m"
    return "$1"
  fi
}

function compare_file_content_by_diff() {
  diff "$1" "$2" >/dev/null
  print_execution_result "$?" "$3" || return 1
}

function compare_file_content_by_cmp() {
  cmp "$1" "$2" >/dev/null
  print_execution_result "$?" "$3" || return 1
}
