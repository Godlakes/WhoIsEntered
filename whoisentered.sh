#!/bin/bash
#set -euo pipefail
times=120 #in seconds
CAM_DIR="$HOME/cam/.photos"
CAM_DIR_SERV="YOUR_REALLY_DIRECTORY_ON_SERVER"
userserv="SERVER_USER"
ipserver="SERVER_IP"
portserv="SERVER_PORT_SSH"
mkdir -p "$CAM_DIR"
cd "$CAM_DIR" || exit 1
if [[ -z $(command -v fswebcam) ]]; then
	printf "Don't exist of fswebcam for correctly work.\nInstall.." && sudo apt install fswebcam -y || exit 1
fi
function doScreen(){
data=$(date '+%Y-%m-%d_%H:%M:%S')
namescreenshot="_screenshotWEBCAM.jpg"
fswebcam -r 1280x720 --jpeg 85 -D 1 "$data$namescreenshot"
sleep 1
echo "Sending to Server.."
scp -P $portserv "$CAM_DIR/$data$namescreenshot" $userserv@$ipserver:/home/$userserv/$CAM_DIR_SERV/ || printf "Server can't got save photo.\n\tPlease check to connect with your server.\nOr try to do this:\n\t ssh-copy-id -p $portserv $userserv@$ipserver" | exit 1
echo "Operations Send is ended."
}

function doDieScreen(){
data=$(date '+%Y-%m-%d_%H:%M:%S')
namescreenshot="_screenshotWEBCAMD.jpg"
fswebcam -r 1280x720 --jpeg 85 -D 1 "$data$namescreenshot" #D is death
scp -P $portserv "$CAM_DIR/$data$namescreenshot" $userserv@$ipserver:/home/$userserv/$CAM_DIR_SERV/ || printf "Server can't got save photo.\n\tPlease check to connect with your server.\nOr try to do this:\n\t ssh-copy-id -p $portserv $userserv@$ipserver" | exit 1
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
