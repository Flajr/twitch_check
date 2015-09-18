# twitch_check
Shell script to check if stream is online or not (with notification).

#Requirements
Install 'curl' and (optional) 'libnotify-bin'

#Usage
twitch_check [OPTIONS] [FILE NAME]
*	-h | --help  show usage
*	-n           show notification
*	-o           show online notify only (this use option -n too)
*	-u=[user]    check (one) user name (surpass file)
*	-w=[seconds] wait seconds (>=10) to check status again, if only -w specified wait 4minutes (default)

#Example
```bash
$ ./twitch_check.sh -u=fattypillow -w=60
Checking stream of fattypillow ... offline 16:38:44
Waiting 60 seconds to check again
Checking stream of fattypillow ... offline 16:39:45
Waiting 60 seconds to check again
Checking stream of fattypillow ... offline 16:40:47
```
```bash
$ ./twitch_check.sh -n favorite_twitch_users.txt #check users from file and show notification (require libnotify-bin)
Checking stream of fattypillow ... offline 16:55:34
Checking stream of flyguncz ... offline 16:55:35
Checking stream of gogomantv ... offline 16:55:37
Checking stream of warcraft ... offline 16:55:38
Checking stream of nightblue3 ... online 16:55:39
Checking stream of esl_joindotared ... online 16:55:41
Checking stream of test_username ... error 16:55:42 #this user do not exist!
```

#Example file with users
####Just one user per line!

fattypillow\n
flyguncz\n
gogomantv\n
warcraft\n
nightblue3\n
esl_joindotared\n
test_username
