#!/usr/bin/env bash

hour_grep() {
  for m in {0..59}
  do
    MINUTE=`printf "%02d" $m`
    minute_grep "$1:$2:$MINUTE"
  done
}

minute_grep() {
  for s in {0..59}
  do
    SECOND=`printf "%02d" $s`
    second_grep "$1:$SECOND"
  done
}

second_grep() {
  COUNT=`grep $1 $FILE | wc -l`
  echo "$1,$COUNT" >> rps_may31.csv
}

FILE=access_may31.log

echo "date,requests_per_second" > rps_may31.csv
for h in {0..23}
do
  hour_grep "31/May/2012" `printf "%02d" $h`&
done
wait $!

