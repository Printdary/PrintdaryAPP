if [[ `ps -A | grep sample` ]]; then
    echo "already running"
else
    echo "not running"
    cd /home/ubuntu/service/service/examples/sample
    ./sample &>> /home/ubuntu/service/service/examples/sample/ono.txt
fi
