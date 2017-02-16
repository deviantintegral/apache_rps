#!/usr/bin/env bash

# Loop to grep for stats for a given hour of the day.
hour_grep() {
  DAY=$1
  HOUR=$2
  FILE=$3

  for m in {0..59}
  do
    MINUTE=`printf "%02d" $m`
    minute_grep "$DAY:$HOUR:$MINUTE" $FILE
  done
}

# Loop to grep for stats for a given minute of an hour.
minute_grep() {
  MINUTE=$1
  FILE=$2

  for s in {0..59}
  do
    SECOND=`printf "%02d" $s`
    second_grep "$MINUTE:$SECOND" $FILE
  done
}

# Determine how many requests completed in a given second.
second_grep() {
  SECOND=$1
  FILE=$2
  COUNT=`grep $SECOND $FILE | wc -l`
  echo "$SECOND,$COUNT" >> $TMPOUT
}

DAY=$1
FILE=$2
OUT=$3
TMPOUT=`mktemp -t apache_rps_out.XXX` || exit 1

if [ -z $3 ]
then
  echo "Usage: apache_rps.sh <day> <access_log> <destination csv>"
  echo "Day should be in the format of a date in your access_log, such as:"
  echo "    01/Jun/2012"
  exit 1
fi

# Note that we use associative arrays, which are a feature of bash 4.0+.
declare -A TMPLOGS
declare -A PIDS

for h in {0..23}
do
  HOUR=`printf "%02d" $h`
  # Split the apache log file into 1-hour chunks for improved performance in
  # grep.
  TMPLOG=`mktemp -t apache_rps_${HOUR}.XXX` || exit 1
  TMPLOGS["${HOUR}"]=$TMPLOG

  grep $DAY:$HOUR $FILE > $TMPLOG

  # Note the & forking this off to a different process. 24 processes seems like
  # a large number, but at least OS X seems to handle it just fine. This could
  # be optimized to only run a specific number of processes at once.
  hour_grep $DAY $HOUR $TMPLOG&

  # Record the PID so we can wait on it and display progress.
  PIDS["$HOUR"]=$!
done

# Wait for the last process to complete.
for h in "${!PIDS[@]}"
do
  PID=${PIDS[$h]}
  wait $PID
  rm -f ${TMPLOGS[$h]}
  echo "Requests per second for hour $h have completed."
done

# Finally, sort the resulting CSV. We pipe it through sed as if we are on BSD
# wc -l inserts some spaces.
echo "date,requests_per_second" > $OUT
sort -t, $TMPOUT | sed -E 's/ +//' >> $OUT
rm -f $TMPOUT

