#!/bin/bash

# @author Yinhe Chen, Siming Lv, Haowen Zhu
# @version 2023.11.29
#
# This shell script is about the operation to files.
# It contains the functions: check in and check out a file, add and delete a file,
# view and edit the content of a file, roll back the file, compare different versions
# of file, add user comments into log file, check the existence of a file
#


# Check in a file into the repository and ask the user to put some comments into
# the log file. This action will be recorded in the log file.
function check_in() {
  # read the file to check in
  read -p "Please enter the file you want to check in: " src_file
  check_file ./"$src_file".backup/"$src_file".txt
  if [ $? -eq 1 ]; then
      echo "File not found!"
      return
  fi
  # move the file to the repository
  mv ./"$src_file".backup/"$src_file".txt ./
  echo "$current_user check in $src_file at $(date).">>./"$(basename $(pwd))".log
  add_comments
  echo "Check in successfully."
}

# This function is to check out one file out of the repository and ask user to put some
# comments. This action will be recorded in the log file. After checking out, a backup
# file will be stored in the backup directory created before.
function check_out() {
  # read the file to check out
  read -p "Please enter the file you want to check out: " file_out
  check_repository ./"$file_out".backup
  if [ $? -eq 1 ]; then
    echo "File not found."
    return
  fi
  check_file ./"$file_out".txt
  if [ $? -eq 1 ]; then
      echo "Unable to check out because this file hasn't been check in."
      return
  fi

  # Add version number and back up. This version number is displayed as the time which is
  # precise and clear for user to do version roll-back.
  timestamp=$(date +"%Y%m%d_%H%M%S")
  touch ./"$file_out".backup/"$timestamp"
  cat ./"$file_out".txt > ./"$file_out".backup/"$timestamp"
  mv ./"$file_out".txt ./"$file_out".backup
  echo "$current_user check out $file_out at $(date) ">>./"$(basename $(pwd))".log
  echo "File check out successfully."
  edit_text ./"$file_out".backup/"$file_out".txt
}

# Add a file to a repository
function add_file(){
    # select repository and input file name
    read -p "Please input the name of the file: " nameoffile
    if [ -e "./$nameoffile" ]; then
        echo "File already exists. Would you like to replace it?"
        read -rp "Please select (1 for yes and 0 for no): " choice
        case $choice in
        1)
          ;;
        2)
          echo "You've keep the previous file. Exit add file."
          return
          ;;
        *)
          echo "Invalid input."
          return
          ;;
        esac
    fi
    touch ./"$nameoffile".txt
    sudo chmod 770 ${nameoffile}.txt
    echo "Add file successfully!"
    # each time create a file will make a backup at the same time
    mkdir ./"${nameoffile}".backup
}

# check if the file exists
function check_file(){
  if [ -e "$1" ]; then
    return 0;
  else
    return 1;
    fi
}

# This is about text editor. User can add, delete, modify lines and read the content of
# the file. Also, he can choose to use nano to realize editing nano.
function edit_text(){
  echo "You've started editing this file: $1."
  while true; do
    echo "+---------------------------------+"
    echo "|          EDIT    MENU           |"
    echo "+---------------------------------+"
    echo "1. Read File"
    echo "2. Add Line"
    echo "3. Modify Line"
    echo "4. Delete Line"
    echo "5. Use Nano Editor"
    echo "6. Exit"
    read -p "Enter your choice (1-6): " choice
    case $choice in
    1)
      cat -n "$1"
      ;;
    2)
      read -p "Enter the content to add: " new_content
      echo "$new_content" >> "$1"
      echo "Add line successfully."
      ;;
    3)
      read -p "Enter the line number to modify: " line_number
      read -p "Enter the new content: " new_content
      sed -i "${line_number}s/.*/$new_content/" "$1"
      echo "Modify line successfully."
      ;;
    4)
      read -p "Enter the line number to delete: " line_number
      sed -i "${line_number}d" "$1"
      echo "Delete line successfully."
      ;;
    5)
      nano "$1"
      ;;
    6)
      add_comments
      echo "You've exited the text editor."
      return
      ;;
    *)
      echo "Invalid option, please try again."
      ;;
    esac
    done
}

#Add comments into the log file
function add_comments(){
  echo "Would you like to add comments to the log file?"
    read -p "1 for yes, 0 for no" choice
    case $choice in
    1)
      read -rp "Please input your comments: " comments
      echo "$current_user add $comments at $(date)">>./"$(basename $(pwd))".log
      ;;
    *)
      ;;
    esac
}

# Roll back the version that the user choose. A new backup will be created and it will
# store the content of the file now and then the file's content will be covered by the
# former version.
function roll_back(){
  # read the file to roll back
  read -p "Please enter the file to roll back: " roll_file
  check_file ./"$roll_file".txt
  if [ $? -eq 1 ]; then
      echo "Your input is invalid."
      return
  fi
  ls ./"${roll_file}".backup
  read -p "Please select the version you want to roll back to： " version
  check_file ./"${roll_file}".backup/"$version"
  if [ $? -eq 1 ]; then
    echo "Your input is invalid."
      return
  fi

  # replace the old version
  timestamp=$(date +"%Y%m%d_%H%M%S")
  touch ./"$roll_file".backup/"$timestamp"
    cat ./"$roll_file".txt > ./"$roll_file".backup/"$timestamp"
    cat ./"${roll_file}".backup/"$version" > ./"$roll_file".txt
    echo "$current_user roll back $roll_file at $(date) ">>./"$(basename $(pwd))".log
    add_comments
    echo "File roll back successfully."

}

# Display the content of the file
function view_content(){
    read -p "Please enter the file to view: " view_file
    check_file ./"$view_file".txt
    if [ $? -eq 0 ]; then
    cat ./"$view_file".txt
    else
    echo "Your input is invalid."
    return
    fi
}

# Delete the file and delete. The backup will also be deleted.
function delete_file() {
      # select repository and input file name
      read -p "Please enter the file to delete: " nameoffile
      check_file ./"$nameoffile".txt
      if [ $? -eq 0 ]; then
      rm ./"$nameoffile".txt
      rm -r ./"$nameoffile".backup
      echo "$current_user delete $nameoffile at $(date)">>./"$(basename $(pwd))".log
      add_comments
      echo "Delete file successfully."
      else
        echo "Invalid input."
        return
        fi
}

# This function can compare the content of two file with different version by using diff.
function compare(){
  read -p "Please enter the file to compare：" doc_name
  if [ ! -f "$doc_name".txt ]; then
      echo "The file does not exist."
      exit 1
    fi
  ls ./"${doc_name}".backup
  read -p "Please select the version：" version1
  if [ ! -f ./"$doc_name".backup/"$version1" ]; then
    echo "This version does not exist."
    exit 2
  fi
  echo
  echo "The result is as follows："
  diff -c "$doc_name".txt ./"$doc_name".backup/"$version1"
}
