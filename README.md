# twitch_check
Shell script to check if stream is online or not (with notification).

#Requirements
Install curl and (optional) libnotify-bin

#Usage
twitch_check [OPTIONS] [FILE NAME]
*	-h | --help  show usage
*	-n           show notification
*	-o           show online notify only (this use option -n too)
*	-u=[user]    check (one) user name (surpass file)
*	-w=[seconds] wait to check status again (without -w check just one time)(use 10s and more)
