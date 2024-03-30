#!/bin/bash

BASE_DIR=$(pwd)

if [[ -f $1 ]]
then
	printf "Writing in $BASE_DIR ...\n\n"
	FILENAME=$1
else
	printf "File doesn't exist!\n"
	exit 1
fi

sed -i 's/,/ /g' $FILENAME;

count=''

IFS=''
while read -r LINE;
do
	string='^'$count'.*'
	if [[ -z $count ]]
	then
		#echo ""
		cd $BASE_DIR
	elif [[ -n $(echo $LINE | grep -E $string) ]] 
	then
		LINE=$(echo $LINE | sed 's/'$count'//')
		#echo $LINE | sed -r 's/'$count'//'
	elif [[ -n $(echo $LINE | grep -E '^\s.*') ]]
	then
		while [[ -n $(echo $LINE | grep -E '^\s.*') ]]
		do
			count=$(echo $count | sed 's/..$//')
			LINE=$(echo $LINE | sed -r 's/'$count'//')
			cd ..
		done
	else
		cd $BASE_DIR
		count=''
	fi

	#echo $LINE
	#echo $count

	if [[ $LINE =~ ^"files:"* ]] 
	then
		#echo ""
		echo $LINE | awk -F ": " '{print $2}' | xargs touch
	else
		DIR=$(echo $LINE | sed 's/://g')
		mkdir -p $DIR && cd $DIR
		count=$count'\s'
	fi
done < $FILENAME

printf "Done!\n"
