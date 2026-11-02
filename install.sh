#!/bin/bash
set -euo pipefail
c=0
user=${SUDO_USER:-$USER}
re="Stop"
if [[ -z $(command -v fswebcam) ]]; then
	printf "Don't exist of fswebcam for correctly work.\nInstall..\n"
	if [ -d "/etc/apt/" ]; then
		sudo apt update && sudo apt install fswebcam -y
	fi
	if [ -d "/etc/dnf/" ]; then
		sudo dnf update && sudo dnf install fswebcam -y
	fi
fi
printf "Before you start to install WhoIsEntered you will create .env file with variables: CAM_DIR CAM_DIR_SERVER USERSERVER IPSERVER PORTSERVER TIMES\n"
printf "Where: \n\tCAM_DIR - Directory your localhost, where will saving photos.\n\tCAM_DIR_SERVER - Directory, where your server will saving photos.\n\tUSERSERVER - User of your Server.\n\tIPSERVER - IP your server.\n\tPORTSERVER - Port SSH of your server.\n\tTIMES - period in seconds takes a photo from webcam.\n"
if [ ! -f ".env" ]; then
	CAM_DIR=""
	CAM_DIR_SERVER=""
	USERSERVER=""
	IPSERVER=""
	PORTSERVER=""
	TIMES=120
	read -rp "Enter the CAM_DIR: " CAM_DIR
	read -rp "Enter the CAM_DIR_SERVER: " CAM_DIR_SERVER
    	read -rp "Enter the USERSERVER: " USERSERVER
   	read -rp "Enter the IPSERVER: " IPSERVER
  	read -rp "Enter the PORTSERVER: " PORTSERVER
	read -rp "Enter the TIMES (default: 120): " TIMES
	if [ -z "$TIMES" ]; then
		TIMES=120
	fi
	touch .env
	cat <<EOF > .env
CAM_DIR="$CAM_DIR"
CAM_DIR_SERVER="$CAM_DIR_SERVER"
USERSERVER="$USERSERVER"
IPSERVER="$IPSERVER"
PORTSERVER="$PORTSERVER"
TIMES="$TIMES"
EOF
fi
printf "\n\nChoice your variant setup whoisentered:\n\t1 - Unix variant (crontab)\n\t2 - systemd serice (Recommended)\n\t3 - Exit\n"
while [ "$re" == "Stop" ]; do
read -r c
if [ "$c" != "1" ] && [ "$c" != "2" ] && [ "$c" != "3" ]; then
	printf "Please chooce the correct variant setup.\n"
else
	re="Cont"
fi
done
if [ "$c" = "1" ]; then
	TARGET_SCRIPT="whoisentered.sh"
	LOG_FILE="crontab.log"
	INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	TARGET_PATH="$INSTALL_DIR/$TARGET_SCRIPT"
	LOG_PATH="$INSTALL_DIR/$LOG_FILE"
	printf "Install auto start with crontab for $TARGET_SCRIPT\n"
	if [ ! -f "$TARGET_PATH" ]; then
		printf "File $TARGET_PATH doesn't exist. Please check your files scripts.\nRepository for help: \thttps://github.com/Godlakes/WhoIsEntered\n"
		exit 1
	fi
	chmod +x "$TARGET_PATH"
	CRON_CMD="@reboot /bin/bash $TARGET_PATH >> $LOG_PATH 2>&1"
	if crontab -l 2>/dev/null | grep -Fq "$TARGET_PATH"; then
		printf "Proccess is already exist in CRONTAB. \n\tSKIP\n"
	else
		printf "Add proccess in crontab."
		(crontab -l 2>/dev/null; echo "$CRON_CMD" ) | crontab -
		printf "Proccess is already NOW exist in CRONTAB how to reboot mode.\n"
	fi
	printf "Install has been finished.\n"
fi

if [ "$c" = "2" ]; then
	INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	TARGET_SCRIPT="$INSTALL_DIR/whoisentered.sh"
	SERVICE_NAME="whoisenter"
	if [ ! -f "$TARGET_SCRIPT" ]; then
		printf "File $TARGET_SCRIPT doesn't exist. Please check your files scripts.\nRepository for help: \thttps://github.com/Godlakes/WhoIsEntered\n"
		exit 1
	fi
	chmod +x "$TARGET_SCRIPT"
	SERVICE_FILE="/tmp/${SERVICE_NAME}.service"
	cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Who Is Entered to system service, which do take photo from WEBCAM, save photo on localhost and server with SSH.
After=network-online.target
Wants=network-online.target
[Service]
Type=simple
User=$user
Group=$user
WorkingDirectory=$INSTALL_DIR
ExecStart=/bin/bash $TARGET_SCRIPT
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
[Install]
WantedBy=multi-user.target
EOF
	
	printf "Install systemd unit.\n"
	sudo cp "$SERVICE_FILE" "/etc/systemd/system/${SERVICE_NAME}.service"
	sudo systemctl daemon-reload
	sudo systemctl enable "${SERVICE_NAME}.service"
	sudo systemctl start "${SERVICE_NAME}.service"
	printf "Service: ${SERVICE_NAME}.service - has been started.\n"
	printf "You may check your service with that commands:\n\t systemctl status ${SERVICE_NAME}\n\t systemctl start ${SERVICE_NAME}\n\t systemctl enable ${SERVICE_NAME}\n\t journalctl -u ${SERVICE_NAME}\n\t journalctl -u ${SERVICE_NAME} -f\n"
fi
if [ "$c" = "3" ]; then
	exit 0
fi
