#!/bin/bash

# @author Yinhe Chen, Siming Lv, Haowen Zhu
# @version 2023.11.29
#
# This shell script is about the operation to users.
# User can be created in groups. Groups can also be created.
# This system can support multiple users and each user's actions will be recorded
# into a log file.
#


# Create a new group as a directory
function create_group() {
  read -p "Enter the name of the new group: " groupname

  # check if the group exists
  if grep -q "^$groupname:" /etc/group; then
      echo "Group '$groupname' already exists."
  else
      # create new group
      sudo groupadd "$groupname"
      echo "Group '$groupname' created successfully."
      mkdir ./"$groupname"
  fi
}

# Create a new user into a group. If the group existed, add in directly, if not, create
# a new one and add.
function create_user() {
    read -p "Enter username: " username
    read -p "Enter password: " password
    read -p "Enter group name: " groupname

    # check whether the user exists
    if id "$username" &>/dev/null; then
        echo "User '$username' already exists."
        echo
        read -p "Do you want to overwrite the existing user? (y for yes, n for no): " overwrite
        if [ "$overwrite" != "y" ]; then
            echo "User registration canceled."
            return
        else
            # delete the existing user
            echo "Deleting the existing user..."
            sudo userdel -r "$username"
            echo "User '$username' deleted successfully."
        fi
    fi

    # check whether the user group exists
    if grep -q "^$groupname:" /etc/group; then
            echo "Group '$groupname' exists."
        else
            echo "Group '$groupname' does not exist. Creating group..."
            sudo groupadd "$groupname"
    	      mkdir -p ./"$groupname"
            echo "Group '$groupname' created successfully."
        fi

    # register a new user
    sudo useradd -m -g "$groupname" "$username"
    echo "$username:$password" | sudo chpasswd

    echo "User '$username' registered successfully."

}

# Make a user to log in this system. Prompt the user to enter the name, password
# and then check.
function log_in() {
read -p "Enter your username: " username
read -s -p "Enter your password: " password

# Check whether the user exists
if id "$username" &>/dev/null; then
          echo "User '$username' found."
      else
          echo "User '$username' not found."
          entrance_menu
      fi

# Check the password
if echo "$password" | su - "$username" -c "exit" &> /dev/null;  then
    echo "Password is correct."
    echo
    current_user=$username
    user_group=$(id -ng "$username")
    cd ./"$user_group"
    echo "Welcome, $username"
else
    echo "Password is incorrect."
    entrance_menu
fi
}

# This function is to print what the user did to files, it can also show the time that
# the user did.
function user_action(){
  for FILE in *
  do
    ATIME=$(stat -c %x "$FILE")
    MTIME=$(stat -c %y "$FILE")
    CTIME=$(stat -c %z "$FILE")

    echo "$current_user accessed $FILE，at $ATIME."
    echo "$current_user modified $FILE，at $MTIME."
    echo "$current_user changed $FILE，at $CTIME."
    echo "------------------------"
  done
}