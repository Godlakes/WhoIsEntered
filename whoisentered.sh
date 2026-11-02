#!/bin/bash
set -euo pipefail
set -a
source "$(dirname "$0")/.env"
set +a
export CAM_DIR CAM_DIR_SERVER USERSERVER IPSERVER PORTSERVER TIMES
mkdir -p "$CAM_DIR"
cd "$CAM_DIR" || exit 1
function doScreen(){
data=$(date '+%Y-%m-%d_%H_%M_%S')
namescreenshot="_screenshotWEBCAM$1.jpg"
fswebcam -r 1280x720 --jpeg 85 -D 1 "$data$namescreenshot"
printf "Sending to Server..\n"
if ! scp -P "$PORTSERVER" "$CAM_DIR/$data$namescreenshot" "$USERSERVER@$IPSERVER:/home/$USERSERVER/$CAM_DIR_SERVER/"; then
	printf "Server can't got save photo.\n\tPlease check to connect with your server.\nOr try to do this:\n\t ssh-copy-id -p $PORTSERVER $USERSERVER@$IPSERVER\n"
fi
printf "Operations Send is ended.\n"
if [ "$1" = "D" ]; then
	printf "Something try to kill whoisentered at $data.\n"
	exit 1
fi
}
#D - Death
trap 'doScreen "D"' SIGINT
trap 'doScreen "D"' SIGQUIT
trap 'doScreen "D"' SIGTERM
trap 'doScreen "D"' SIGABRT

while true; do
doScreen "W" #Working
sleep $TIMES #in seconds
done
