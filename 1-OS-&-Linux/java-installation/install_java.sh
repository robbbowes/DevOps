#!/bin/sh

# Install Java
sudo apt update
sudo apt install -y default-jre

# Verify Java installation
java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')

major_version=$(echo "$java_version" | awk -F. '{print ($1 == 1 ? $2 : $1)}')

if [ -z "$major_version" ]; then
    echo "Java installation failed."
elif [ "$major_version" -lt 11 ]; then
    echo "Java $major_version is installed, but Java 11+ is required."
else
    echo "Java $major_version is installed and meets the requirements."
fi

