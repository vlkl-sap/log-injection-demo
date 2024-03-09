#!/bin/bash

set -e

U="http://localhost:8080/endpoint?data="
P="event2%1B%5B2K%1B%5B1A"
#echo "$P"


xdotool() {
  env LD_LIBRARY_PATH=~/xdotool ~/xdotool/xdotool "$@"
}

BROWSER="Mozilla Firefox"
CONSOLE="log injection demo"

browser() {
printf "%b" "$@" | xdotool search "$BROWSER" type --delay 200 -file -
}

console() {
printf "%b" "$@" | xdotool search "$CONSOLE" type --delay 200 -file -
}

enterc() {
sleep 0.5
xdotool search "$CONSOLE" key Return
}

enterb() {
sleep 0.5
xdotool search "$BROWSER" key Return
}



########################################################################

xdotool search "$CONSOLE" windowactivate key ctrl+l


osd.py -d 2.5 -x 640 -y 300 "Log injection demo" &
#sleep 0.5
osd.py -d 2   -x 640 -y 370 "Ep.2 \"ANSI Sequences\"" 
sleep 1


osd.py -d 4.5 -x 640 -y 300 "Applications logging request data" &
sleep 0.5
osd.py -d 4   -x 640 -y 370 "can be vulnerable to" &
sleep 0.5
osd.py -d 3.5 -x 640 -y 440 "log injection" &


sleep 1
console "cat src/main/java/com/example/loginjection/Controller.java"
enterc

sleep 1.5
console "java -jar target/log-injection-0.0.1-SNAPSHOT.jar &"
enterc
sleep 2

console "\rtail -f app.log"
enterc
sleep 2

osd.py -x 640 -y 150 "sending a normal request" &
sleep 1

xdotool search "$BROWSER" windowactivate --sync key --clearmodifiers ctrl+l
sleep 0.5
browser "$U"
sleep 0.3
browser "event1" 
enterb
sleep 2

osd.py -x 640 -y 150 "sending a malicious request<br/>containing ANSI sequences" &
sleep 1.5

xdotool search "$BROWSER" windowactivate --sync key --clearmodifiers ctrl+l type "$U"
sleep 0.5
browser "$P" 
enterb

sleep 1

osd.py -d 4 -x 640 -y 550 "Result: the entry is in the log file<br/>but the terminal does not show it" 

sleep 1

osd.py -d 5.5 -x 640 -y 300 "Prevent log injection — encode logged data" &
sleep 0.5
osd.py -d 5   -x 640 -y 370 "https://github.com/vlkl-sap/log-injection-demo" 
sleep 0.5
