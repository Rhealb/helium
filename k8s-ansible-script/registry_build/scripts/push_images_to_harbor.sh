#!/bin/bash
#IMAGE_LIST_FILE=${1:-image_list}
IMAGE=$1
IMAGE_REPO=$2

docker pull $IMAGE > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo $IMAGE  not found
	exit 1;
fi


docker tag $IMAGE $IMAGE_REPO > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo $IMAGE  not found
    exit 1;
fi

docker push $IMAGE_REPO > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo $IMAGE  not found
    exit 1;
fi
echo $IMAGE_REPO  pushed success

