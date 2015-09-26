# twitch_check
Check if your favorites streamers are online! Write names down in file and let program show notification for you if streamer came live.

#Requirements
Install 'curl' and (for notification) 'libnotify-bin'

#Usage
twitch_check [OPTIONS] [FILE NAME]
*	-f [FILE]    path to file with users names
*   -h | --help  show usage
*	-n           show notification
*	-o           show online notify only (this use option -n too)
*	-u [USER]    check (one) user name (surpass file)
*	-w [SECONDS] wait seconds (>=30) to check status again

#Example
```bash
$ ./twitch_check.sh -u fattypillow -w60
Checking stream of fattypillow ... offline 16:38:44
Waiting 60 seconds to check again
Checking stream of fattypillow ... offline 16:39:45
Waiting 60 seconds to check again
Checking stream of fattypillow ... offline 16:40:47
```
```bash
$ ./twitch_check.sh -n -f favorite_twitch_users.txt #check users from file and show notification (require libnotify-bin)
Checking stream of fattypillow ... offline 16:55:34
Checking stream of flyguncz ... offline 16:55:35
Checking stream of gogomantv ... offline 16:55:37
Checking stream of warcraft ... offline 16:55:38
Checking stream of nightblue3 ... online 16:55:39
Checking stream of esl_joindotared ... online 16:55:41
Checking stream of test_username ... error 16:55:42 #this user do not exist!
```