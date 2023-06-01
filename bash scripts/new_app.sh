#!/bin/bash

# CHECK if the container is running 
# if it is ask the user do they want to reinstall the container
# if yes then first rm -f the running container and then run the remaining container
#

containers=("redis" "new_vote" "worker" "result" "postgres")
counter=0 
#if counter value is zero then no application is not running if greater than zero then it is
#  also check if the output is empty or not var=$(docker ps --filter "name=$i" --format={{.Names}}) [[ -n $var ]]; then


for c in "${containers[@]}"; do
    var=$(docker ps --filter "name=$c" --format={{.Names}})
    #if the output of the variable is not null then the counter will increment 
    if [[ -n $var ]]; then
        counter+=1
        echo "$counter is increased since contianer $c is running "

    fi
# check if the counter value is greater than zero then break
    if [[ $counter>0 ]]; then
      break
    fi 
    
done

read -p "do you want reinstall the container  then type 'yes' or Stop the entire application then type 'stop' " task

if [[ "$task" == "yes" ]]; then
# loop in the list again and remove the containers which are running
    for i in "${containers[@]}"; do 

        var=$(docker ps --filter "name=$i" --format={{.Names}})

        if [[ -n $var ]]; then
            echo "text para"
            docker rm -f $i

        fi

    done

    docker run -d -h redis -p 6379:6379 --name redis1 redis:latest
    # postgres container
    docker run -d -h db --name postgres1 -e POSTGRES_DB=db -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:15-alpine
    # vote container
    docker run -d -p 5000:80 --link redis1 --name new_vote new_vote:1.0
    # worker container
    docker run -d --link postgres1 --link redis1 --name worker1 worker:1.0
    # result container
    docker run -d -p 5001:80 --link postgres1 --name result1 result:1.0

# by the input we are removing the running containers 
elif [[ "$task" == stop ]]; then
    for i in "${containers[@]}"; do 
        # inside the loop finding the running containers and then removing them
        var=$(docker ps --filter "name=$i" --format={{.Names}})
        # checking if the output is empty or not
        if [[ -n $var ]]; then
            docker rm -f $i
        
        fi

    done

else 
    echo "please provide with a proper input 'yes' or 'stop'"


fi