#!/usr/bin/expect

set timeout -1

set ip [lindex $argv 0]
set port [lindex $argv 1]
set username [lindex $argv 2]
set password [lindex $argv 3]
set path [lindex $argv 4]
set command [lindex $argv 5]

spawn ssh -p $port $username@$ip
expect {
        "(yes/no)?"
                {
                        send "yes\n"
                        expect "*password:" {send "$password\n"}
                }
        "*password:"
                {
                        send "$password\n"
                }
}
expect "#*"
send "cd $path\n"
expect "#*"
send "ls *.jar\n"
expect "#*"
send "sh shell.sh $command\n"
expect eof