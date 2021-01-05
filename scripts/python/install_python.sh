#!/bin/bash

set nounset
set errexit

# @param {string} - command
# @return {0|1}
function has_command() {
  type $1 > /dev/null 2>&1
  return $?
}

# @param {string} - command
# @param {string} - command
# @return {void}
function check_command() {
  if ! has_command $1; then
    echo "❌ command '$1' doesn't exist. Probably the command isn't installed correctly."
    exit 1
  fi
  return 0
}

# @param {string} - package name
# @param {string?} - package location path
# @return {void}
function echo_success_message() {
  if [[ $2 ]]; then
    echo "✅ $1 has been installed successfully at '$2'!"
  else
    echo "✅ $1 has been installed successfully!"
  fi
  return 0
}

# @param {string} - package name
# @param {string?} - package location path
# @return {void}
function echo_fail_message() {
  if [[ $1 ]]; then
    echo "❌ $1 has been failed to install at '$2'."
  else
    echo "❌ $1 has been failed to install."
  fi
  exit 1
}

# @param {string} - package name
# @param {string} - package location path
# @return {void}
function echo_already_installed_message() {
  echo "✅ $1 is already installed at '$2'."
  return 0
}

# main -------------------------------------------------------------------------------

# @param None
# @return {void}
function install_pyenv() {
  local pyenv_path=~/.pyenv
  if [[ -d ${pyenv_path} ]]; then
    echo_already_installed_message "pyenv" ${pyenv_path}
    return 0
  elif [[ -e ${pyenv_path} ]]; then
    echo "❌ The other package exists at '${pyenv_path}', but the path to pyenv doesn't exist."
    exit 1
  fi

  echo "installing pyenv ..."
  git clone https://github.com/pyenv/pyenv.git ~/.pyenv
  cd ~/.pyenv && src/configure && make -C src
  ~/.pyenv/bin/pyenv init
  source ~/.bash_profile
  if ! has_command "pyenv" ${pyenv_path}; then
    echo_fail_message "pyenv" ${pyenv_path}
  fi
  echo_success_message "pyenv" ${pyenv_path}
  return 0
}

# @param None
# @return {void}
function install_build_packages() {
  # python がインストール済みの場合は不要
  if has_command "python" ; then
    return 0;
  fi

  sudo apt update
  sudo apt install --no-install-recommends -y \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev
}

# @param None
# @return {void}
function install_python() {
  check_command "pyenv"

  if has_command "python"; then
    local python_version=$(python --version | cut --delimiter " " -f 2)
    echo_already_installed_message "Python ${python_version}" "$(which python)"
    return 0
  fi

  local latest_version=$(pyenv install -l | grep -E "^\s*[0-9]{1,2}(\.[0-9]{1,2}){2}" | tail -n 1 | awk '{print $1}')
  echo "installing Python the ${latest_version} (latest version of the major release) ..."
  pyenv install ${latest_version}
  pyenv global ${latest_version}
  if ! has_command "python"; then
    echo_fail_message "Python ${latest_version}"
  fi
  echo_success_message "Python ${latest_version}" "$(which python)"
  return 0
}

# @param None
# @return {void}
function install_pip_packages() {
  check_command "pip"
  check_command "pyenv"

  echo "installing pip packages ..."
  pip install --user \
    pipenv

  # 各パッケージへのパスを通す
  pyenv rehash
  echo_success_message "A set of pip packages"
}

install_pyenv
install_build_packages
install_python
install_pip_packages
exit 0
