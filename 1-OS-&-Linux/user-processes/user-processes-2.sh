#!/bin/sh


echo "Sort user processes by memory usage (m) or CPU usage (c)?"
read choice

if [ "$choice" = "m" ]; then
    echo "User processes sorted by memory usage:"
    ps aux --sort -rss | grep $USER
elif [ "$choice" = "c" ]; then
    echo "User processes sorted by CPU usage:"
    ps aux --sort -%cpu | grep $USER
else
    echo "Invalid choice. Please enter 'm' for memory or 'c' for CPU."
fi
