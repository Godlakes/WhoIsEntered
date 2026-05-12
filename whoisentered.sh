#!/bin/bash
times=120 #in seconds
CAM_DIR="$HOME/cam/.photos"
CAM_DIR_SERV="Photo"
userserv="YOUR_USER"
ipserver="YOUR_IP_SERVER"
portserv="YOUR_PORT_SERVER_SSH"
mkdir -p $CAM_DIR
cd $CAM_DIR

function doScreen(){
data=$(date '+%Y-%m-%d_%H:%M:%S')
namescreenshot="screenshotWEBCAM.jpg"
fswebcam -r 1280x720 --jpeg 85 -D 1 "$data$namescreenshot"
sleep 1
echo "Sending to Server.."
scp -P $portserv "$CAM_DIR/$data$namescreenshot" $userserv@$ipserver:/home/$userserv/$CAM_DIR_SERV/ || echo -e "Server can't got save photo.\n\tPlease check to connect with your server."
echo "Operations Send is ended."
}

function doDieScreen(){
data=$(date '+%Y-%m-%d_%H:%M:%S')
namescreenshot="screenshotWEBCAMD.jpg"
fswebcam -r 1280x720 --jpeg 85 -D 1 "$data$namescreenshot" #D is death
scp -P $portserv "$CAM_DIR/$data$namescreenshot" $userserv@$ipserver:/home/$userserv/$CAM_DIR_SERV/ || echo -e "Server can't got save photo.\n\tPlease check to connect with your server."
echo "Operations send is ended"
exit 1
}

trap doDieScreen SIGINT
trap doDieScreen SIGQUIT
trap doDieScreen SIGTERM
trap doDieScreen SIGABRT

while true; do
doScreen
sleep $times
done
