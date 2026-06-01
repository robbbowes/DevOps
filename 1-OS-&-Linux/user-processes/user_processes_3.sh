#!/bin/sh


echo "Sort user processes by memory usage (m) or CPU usage (c)?"
read choice
echo "How many processes to display?"
read count

if [ "$choice" = "m" ]; then
    echo "User processes sorted by memory usage:"
    ps aux --sort -rss | grep $USER | head -n $count
elif [ "$choice" = "c" ]; then
    echo "User processes sorted by CPU usage:"
    ps aux --sort -%cpu | grep $USER | head -n $count
else
    echo "Invalid choice. Please enter 'm' for memory or 'c' for CPU."
fi
