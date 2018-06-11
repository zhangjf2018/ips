#!/bin/bash

LDATE=$1

LNAME=trace
LDIR=/home/xp/test/shell

cd $LDIR

for i in {0..23}
do
	hour=`printf "%02d" $i`
	filename=$LNAME$LDATE.$hour.log 
	if [ -f "$filename" ]; then
		tar zcvf $filename.gz $filename --remove-files
	fi
done

