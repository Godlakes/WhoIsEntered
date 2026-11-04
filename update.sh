#!/bin/bash
set -e
cd "$(dirname "$0")"
printf "Need root-permission for stop service and update.\n\tWARNING: YOUR LOCAL DATA, WHICH HAVE OTHER CODE WILL DELETE AND REPLACE ON THE NEW CODE FROM REPOSITORY!\n"
if [ "$EUID" -ne 0 ]; then
	printf "Run as root this script update.\n"
	exit 1
fi
systemctl stop whoisenter || exit 1
git fetch origin main
git reset --hard origin/main
if [ ! -f whoisentered.sh ] || [ ! -f install.sh ]; then
	printf "ERROR: You don't have this files or chapter of files, please check repository again, and do self clone repository:\nwhoisentered.sh\ninstall.sh\n\tRepository for check: https://github.com/Godlakes/WhoIsEntered\n"
	exit 1
fi
printf '2\n' | ./install.sh
