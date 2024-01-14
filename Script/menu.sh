#!/bin/bash

# @author Yinhe Chen, Siming Lv, Haowen Zhu
# @version 2023.11.29
#
# This shell script is about the logic structure of this project.
# There all totally four menus in this script(actually five in this project, another one
# is in file.sh). These menus are related to each other and work together with different
# functions. The prompts can make user more easily to use this system.
#

# declare two global variables
export current_user
export user_group

# import other three files
source user.sh
source repository.sh
source file.sh

# Create a directory at the beginning as the work directory
  if [ -d ../VCS ]; then
    sudo chmod 777 ../VCS
    cd ../VCS
  else
    sudo mkdir ../VCS
    sudo chmod 777 ../VCS
    cd ../VCS
  fi

# This menu will be displayed at the beginning to prompt a user to login or register
function entrance_menu() {
  echo
  echo "Welcome to Version Control System!"
  echo
  echo "+---------------------------------+"
  echo "|        ENTRANCE    MENU         |"
  echo "+---------------------------------+"
  echo "1. login"
  echo "2. register"
  echo "3. exit"
  echo
  read -p "Please select an option: " option
  case $option in
  1)
    log_in
    repository_menu
    ;;
  2)
    create_user
    ;;
  3)
    echo "Good Bye!"
    exit 1
    ;;
  *)
    echo "Invalid option!"
    ;;
  esac
  entrance_menu
}

# This menu contains the operation with repository including
# create, visit, compress, depress, delete and so on
function repository_menu() {
  echo "You are in this Group: $PWD"
  echo "Current repositories are displayed as below:"
  if [ "$(ls -A)" ]; then
      ls -d ./*/
  fi

  echo
  echo "+---------------------------------+"
  echo "|      REPOSITORY    MENU         |"
  echo "+---------------------------------+"
  echo "1. create a repository"
  echo "2. visit a repository"
  echo "3. compress a repository"
  echo "4. decompress a repository"
  echo "5. delete a repository"
  echo "6. go to user menu"
  echo
  read -p "Please select an option: " option
    case $option in
    1)
      create_repository
      ;;
    2)
      visit_repository
      file_menu
      ;;
    3)
      compress
      ;;
    4)
      decompress
      ;;
    5)
      delete_repository
      ;;
    6)
      cd ..
      user_menu
      ;;
    *)
      echo "Invalid option!"
      repository_menu
      ;;
    esac
    repository_menu
}

# This menu is about the operation with files
# User can add or delete, check in or our, edit or roll back files
function file_menu() {
  echo "You are in this repository: $PWD"
  echo "Current files are displayed as below:"
  ls ./
  echo
  echo "+---------------------------------+"
  echo "|          FILE    MENU           |"
  echo "+---------------------------------+"
  echo "1. create a file"
  echo "2. view a file"
  echo "3. check out a file to edit"
  echo "4. check in a file"
  echo "5. roll back a file"
  echo "6. delete a file"
  echo "7. compare a file with its previous versions"
  echo "8. display operation history"
  echo "9. go to user menu"
  echo "10. go to repository menu"
  echo
  read -p "Please select an option: " option
    case $option in
    1)
      add_file
      ;;
    2)
      view_content
      ;;
    3)
      check_out
      ;;
    4)
      check_in
      ;;
    5)
      roll_back
      ;;
    6)
      delete_file
      ;;
    7)
      compare
      ;;
    8)
      user_action
      ;;
    9)
      cd ..
      cd ..
      pwd
      user_menu
      ;;
    10)
      cd ..
      repository_menu
      ;;
    *)
      echo "Invalid option!"
      echo
      ;;
    esac
    file_menu
}

# This menu includes what you can do with the users
# You can create users and groups and switch the current user here
function user_menu() {
  echo
  echo "+---------------------------------+"
  echo "|          USER    MENU           |"
  echo "+---------------------------------+"
  echo "1. log out and exit"
  echo "2. switch user"
  echo "3. create a new group"
  echo "4. create a new user"
  read -p "Please select an option: " option
  case $option in
  1)
    echo "Good Bye, $current_user"
    exit 0
    ;;
  2)
    log_in
    repository_menu
    ;;
  3)
    create_group
    ;;
  4)
    create_user
    ;;
  *)
    echo "Invalid option!"
    echo
    ;;
  esac
  user_menu
}

# Display the entrance menu first
entrance_menu