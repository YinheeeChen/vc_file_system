#!/bin/bash

# @author Yinhe Chen, Siming Lv, Haowen Zhu
# @version 2023.11.29
#
# This shell script is about the operation to repository.
# It is included the functions: create and delete a repository, check the existence of
# one repository, compress all the file under the path of repository into an archive
# file and decompress it into a directory, visit the repository then operate with files.
#


# Create a repository
function create_repository(){
       read -p "Please input the name of the new repository: " nameOfrepository
       mkdir ./"$nameOfrepository"
       sudo chmod 770 "$nameOfrepository"
       touch ./"$nameOfrepository"/"$nameOfrepository".log
  }

# check if the repository exists
function check_repository(){
  if [ -d "$1"  ]; then
    echo "The file under the repository are as below: "
    ls "$1"
    echo
    return 0;
  else
    return 1;
  fi
}

# Let user visit a specific repository
function visit_repository(){
  ls -d ./*/
  read -p "Please input the repository you want to visit: " nameofvisit
  check_repository ./"$nameofvisit"
  if [ $? -eq 0 ]; then
     cd ./"$nameofvisit"
  else
     echo "Your input is not valid!"
     repository_menu
     return
  fi

}

# Compress all the file in one repository into one file
function compress(){
  #list all the directories
    ls -d ./*/
    read -p "Please select the repository: " nameOfrepository12
    check_repository ./"$nameOfrepository12"
    if [ $? -eq 0 ]; then
        echo "Compressing..."
        sudo tar -czvf ./"$nameOfrepository12".tar.gz "$nameOfrepository12"
        echo "Compressing succeed!"
    else
          echo "This repository is not exist."
          return
    fi
}

# Decompress the archive file to one directory
function decompress(){
  echo "These are the archived file: "
  ls ./*.tar.gz
  read -p "Please select (just enter the name): " nameofrepository0
  check_repository ./"$nameofrepository0"
      if [ $? -eq 0 ]; then
          archive="$nameofrepository0".tar.gz
          mkdir ./"$nameofrepository0"/"$nameofrepository0".decompress
          destination=./"$nameofrepository0"/"$nameofrepository0".decompress
          echo "Decompressing..."
          tar -xvf "$archive" -C "$destination"
          echo "Decompressing succeed!"
      else
            echo "This repository does not exist."
            return
      fi
}

# Delete one repository
function delete_repository() {
  # check whether there is no repository
  if [ -z "$(ls -d */)" ]; then
      echo "There is no repository to delete."
  else
      ls -d ./*/
      read -p "Please select the repository: " nameofselect
      check_repository ./"$nameofselect"
      if [ $? -eq 0 ]; then
      rm -r ./"$nameofselect"
      echo "Delete repository successfully."
      else
      echo "This repository does not exist."
      return
      fi
  fi  
}