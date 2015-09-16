#!/bin/bash

[[ `id -u` -eq 0 ]] && echo "Do not run as root!" && exit

function usage()
{
	echo "twitch_check [OPTIONS] [FILE NAME]"
	echo "-h | --help  show usage"
	echo "-n           show notification"
	echo "-o           show online notify only (this use option -n too)"
	echo "-u=[user]    check (one) user name (surpass file)"
	echo "-w=[seconds] wait to check status again (without -w check just one time)(use 10s and more)" 
}

#Send notification to desktop with "notify-send" part of libnotify-bin
function notify()
{
	if [[ $notify_var -eq 1 ]]; then
		if [[ $1 == "offline" && $notify_online -eq 1 ]]; then
			stream_object=
		elif [[ $1 == "error" && $notify_online -eq 1 ]]; then
			stream_object=
		else
			#-t 10000 to show notification for 10s, print $user_name and status (online,offline,error)
			notify-send -t 10000 "$user_name $1"
		fi
	fi
}

#main function
function check_stream_of_user()
{
	#read user_name
	user_name=$1

	echo -n "Checking stream of $user_name ..."

	#Returns a stream object if live
	#from https://github.com/justintv/Twitch-API/blob/master/v3_resources/streams.md
	stream_object=`curl -s -H 'Accept: application/vnd.twitchtv.v3+json' \
	-X GET https://api.twitch.tv/kraken/streams/$user_name`

	#parsing output
	user_check=`echo "$stream_object" |grep -o "\"stream\":null"`
	user_error=`echo "$stream_object" |grep "\"error\":"`

	if [[ $user_check == "\"stream\":null" ]]; then
		echo " offline"
		#first argument of notify func is status!
		notify "offline"
	else
		if [[ -z $user_error ]]; then
			echo " online"
			notify "online"
		else
			echo " error"
			notify "error"
		fi
	fi
}

#show usage if no arguments and exit
if [[ $# -eq 0 ]]; then
	usage
	exit
fi

for arg in $@
do
	case $arg in
		-n)
		#create notifications as specified in usage
		notify_var=1
		;;

		-h|--help)
		#usage of program specified in usage func
		usage
		exit
		;;

		-o)
		#create notifications for online users only, automatic use argument -n
		notify_online=1
		notify_var=1
		;;

		-w=[1-9][0-9]*)
		#parsing just seconds (numbers) from variable $arg
		wait_to_check=${arg/-w=}
		;;

		-u=*)
		user=${arg/-u=}
		no_file="u_arg"
		;;

		*)
		#check if $arg is readablefile
		#if yes use for it variable file_name
		if [[ $no_file == "u_arg" ]]; then
			continue
		elif [[ -r $arg ]]; then
			file_name=$arg
			no_file=0
		else
			no_file=1
		fi
		;;
	esac

done

#no file specified
if [[ $no_file -eq 1 ]]; then
	exit 1
fi

#loop if -w is specified
while :
do
	if [[ $no_file == "u_arg" ]]; then
		check_stream_of_user "$user"
	elif [[ $(cat $file_name) == "" ]]; then
		echo "Nothing to check in file!"
		exit 1
	else
	#check stream of all users from file ($file_name)
		for user in $(cat $file_name)
		do
			check_stream_of_user "$user"
		done
	fi
	
	#-w is not specified (empty)
	if [[ -z $wait_to_check ]]; then
		exit	
	else
		echo "Waiting $wait_to_check seconds to check again"
		sleep $wait_to_check
	fi
done