# first function to check the containers are running or not
# passing the list as an input 

containers=("redis" "vote" "worker" "result" "postgres")

check_running () {
    counter=0
    local list=("${@}")
    for c in "${list[@]}"; do
        var=$(docker ps --filter "name=$c" --format={{.Names}})
        #if the output of the variable is not null then the counter will increment 
        if [[ -n $var ]]; then
            counter+=1
            #echo "$counter is increased since contianer $c is running "

        fi
    done
    # check if the counter value is greater than zero then break
    if [[ $counter>0 ]]; then
            #echo " Application is already installed."
            echo "1"
    else
            #echo " seems application is not running"
            echo "0"
    fi 
     
    
}

docker_run() {

    docker run -d -h redis -p 6379:6379 --name redis redis:latest
    # postgres container
    docker run -d -h db --name postgres -e POSTGRES_DB=db -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:15-alpine
    # vote container
    docker run -d -p 5000:80 --link redis --name vote vote:1.0
    # worker container
    docker run -d --link postgres --link redis --name worker worker:1.0
    # result container
    docker run -d -p 5001:80 --link postgres --name result result:1.0
}

start_application () {
    local list=("${@}")
    for i in "${list[@]}"; do 

        var=$(docker ps --filter "name=$i" --format={{.Names}})

        if [[ -n $var ]]; then
            echo "text para"
            docker rm -f $i

        fi

    done

    docker_run 
}

    


stop_application () {
    local list=("${@}")
    for i in "${list[@]}"; do 

        var=$(docker ps --filter "name=$i" --format={{.Names}})

        if [[ -n $var ]]; then
            docker rm -f $i

        fi

    done

}


reinstall(){
    read -p "do you want to install the application(yes/no) " install

    if [[ $install == yes ]]; then
        start_application "$var"

    elif [[ $install == no ]]; then
        echo "your application will not reinstall and will remain as is it "
    else 
        echo "provide proper input"

    fi

}

uninstall(){
    read -p "do you want to uninstall the application(yes/no) " in

    if [[ $in == yes ]]; then
        stop_application "$var"

    elif [[ $in == no ]]; then 
        echo "okay your application will remain as it is"

    else
        echo "please provide with a proper input"

    fi


}

# start_application "${containers[@]}"
# check_running "${containers[@]}"


var="${containers[@]}"

echo "welcome to voting application"

read -p "To check the status of your application(yes/no): " input

if [[ $input == yes ]]; then
    status=$(check_running "$var")
    echo $status
    ret_value=$?
    if [[ "$status" == "0" ]]; then
        echo "your application is not running"
        reinstall
    else
        echo "your application is running"
        uninstall
    fi
fi
