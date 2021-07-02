#!/bin/bash

if [ -n "$1" ]; then
  grep $1 /opt/android-sdk/licenses/android-sdk-license &&
    echo -e "\n--> License already present" || (
    echo -e $1 >> /opt/android-sdk/licenses/android-sdk-license
    echo -e "\n--> Licenses accepted"
  )
fi

echo -e "\n--> Running 'sh gradlew $2'\n"

sh gradlew $2
