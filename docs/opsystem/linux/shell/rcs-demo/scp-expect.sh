#!/usr/bin/expect

set ip [lindex $argv 0]
set port [lindex $argv 1]
set username [lindex $argv 2]
set password [lindex $argv 3]
set source [lindex $argv 4]
set target [lindex $argv 5]

spawn scp -P $port $source $username@$ip:$target
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
expect "100%"
expect eof