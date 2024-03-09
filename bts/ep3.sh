#!/bin/bash

set -e

U="http://localhost:8080/endpoint?data="
P="<img src=1 onerror=\"javascript:alert('Session compromised')\">"
#echo "$P"


xdotool() {
  env LD_LIBRARY_PATH=~/xdotool ~/xdotool/xdotool "$@"
}

BROWSER="Mozilla Firefox"
CONSOLE="log injection demo"

browser() {
printf "%b" "$@" | xdotool search "$BROWSER" type --delay 200 -file -
}

browsern() {
printf "%b" "$@" | xdotool search "$BROWSER" type --args 1 --delay 200 -file - "" sleep 0.7 key Return
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
osd.py -d 2   -x 640 -y 370 "Ep.3 \"JavaScript\"" 
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

osd.py -x 640 -y 150 "sending a malicious request<br/>containing JavaScript" &
sleep 1.5

xdotool search "$BROWSER" windowactivate --sync key --clearmodifiers ctrl+l type "$U"
sleep 0.5
browser "$P" 
enterb

sleep 1

osd.py -d 3   -x 640 -y 550 "So far so good" &
sleep 0.5
osd.py -d 2.5 -x 640 -y 615 "Now opening a log dashboard" &

cat ~/log-injection-demo/app.log >> ~/elk/input.log
#sleep 1

xdotool search "$CONSOLE" windowminimize
xdotool search "$BROWSER" windowactivate --sync key --clearmodifiers ctrl+t
browsern "localhost:5601"


sleep 3

osd.py -d 5.5 -x 640 -y 210 "Result:" &
sleep 0.5
osd.py -d 5   -x 640 -y 300 "The log entry exploits an XSS<br/>lurking in the dashboard"

osd.py -d 5.5 -x 640 -y 280 "Prevent log injection — encode logged data" &
sleep 0.5
osd.py -d 5   -x 640 -y 350 "https://github.com/vlkl-sap/log-injection-demo" 
sleep 0.5
