#!/bin/bash

set -e

BASEURL="http://data.lambda3.org/indra/dumps"

if [ ! $1 ]; then
	echo ".........................................................."
	echo "Load Indra models from $BASEURL."
	echo "Usage: downloader.sh <name_of_the_model>"
	echo "Example to load the public Word2Vec model of Google News"
	echo " downloader.sh w2v-en-googlenews300neg"
	echo ".........................................................."
	exit 0
fi


if [ $1 == w2v* ] || [ $1 == glove* ] || [ $1 == lsa* ]; then
	MODELFILE="$1.annoy.tar.gz"
	MD5FILE="$1.annoy.tar.gz.md5"
	$ISANNOY = 1;
	mkdir -p annoy/data
	cd annoy
else

	loaded=`docker exec -it indramongo mongo $1 --quiet --eval "db.getCollectionNames().length"`
	loaded=$(echo -n "${loaded//[[:space:]]/}")

	if [ "$loaded" != "0" ] ; then
		echo "$1 already loaded."
		exit 0
	fi

	MODELFILE="$1.tar.gz"
	MD5FILE="$1.tar.gz.md5"
	$ISANNOY = 0;
	mkdir -p mongo/data
	cd mongo
fi

MODELURL="$BASEURL/$MODELFILE"
MD5URL="$BASEURL/$MD5FILE"

if [ ! -d "./$1" ]; then
	echo "Downloading $MODELURL .."
	wget -nc $MODELURL && wget -nc $MD5URL && md5sum -c $MD5FILE 
	echo "Extracting $MODELFILE"
	tar -C ./data -xf $MODELFILE --totals
	rm $MODELFILE $MD5FILE
fi

if [! $ISANNOY]; then
	docker exec -it indramongo mongorestore /dumps/data/$1 -d $1 --stopOnError
fi

echo "Finished."

