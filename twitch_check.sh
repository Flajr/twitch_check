#!/bin/bash

[[ `id -u` -eq 0 ]] && echo "Do not run as root!" && exit

function usage()
{
	echo "twitch_check [OPTIONS] [FILE NAME]"
	echo "-f [FILE]    path to file with users names"
	echo "-h | --help  show usage"
	echo "-n           show notification"
	echo "-o           show online notify only (this use option -n too)"
	echo "-u [USER]    check (one) user name (surpass file)"
	echo "-w [SECONDS] wait seconds (>=30) to check status again"
	exit
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
		echo " offline `date +%T`"
		#first argument of notify func is status!
		notify "offline"
	else
		if [[ -z $user_error ]]; then
			echo " online `date +%T`"
			notify "online"
		else
			echo " error `date +%T`"
			notify "error"
		fi
	fi
}

if [[ $# -eq 0 ]]; then
	usage
fi

while getopts :now:u:f: opt; do
	case $opt in
		n)
			#create notifications as specified in usage
			notify_var=1
		;;

		o)
			#create notifications for online users only, automatic use argument -n
			notify_online=1
			notify_var=1
		;;

		w)
			if [[ $OPTARG =~ ^[3-9][0-9]+ ]]; then
				wait_to_check=$OPTARG
			else
				echo "BAD PARAMETER: seconds >= 30"
			fi
		;;

		u)
			user=$OPTARG
			no_file=3
		;;

		f)	
			#if -u flag specified surpass file (just continue)
			if [[ $no_file -eq 3 ]]; then
				continue
			#check if $arg is readablefile
			#if yes use file_name var
			elif [[ -r $OPTARG ]]; then
				file_name=$OPTARG
				no_file=0
			else
				file_name=$OPTARG
				no_file=1
			fi
		;;
		
		:)
			echo "REQUIRE ARGUMENT: -$OPTARG"
		;;

		*)
			echo "INVALID OPTION: -$OPTARG!"
			usage
		;;
	esac

done

#loop if -w is specified
while :
do
	if [[ $no_file -eq 3 ]]; then
		check_stream_of_user "$user"
	elif [[ -z $file_name ]]; then
		exit 1
	elif [[ $no_file -eq 1 ]]; then
		echo "NOT FOUND: $file_name"
		exit 2
	elif [[ -z $(cat $file_name |awk '{print $1}') ]]; then
		echo "EMPTY: $file_name"
		exit 3
	else
	#check stream of all users from file ($file_name)
		for user in $(cat $file_name |awk '{print $1}')
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