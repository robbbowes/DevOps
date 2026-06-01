#!/bin/sh

# Print user processes
echo "User processes:"
ps aux | grep $USER
