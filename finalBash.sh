#!/bin/bash
#run centOS
#a script to nc and ping a server


GW=`/sbin/ip route | awk '/default/ { print $3 }'` #awk 
checkDNS=`cat /etc/resolv.conf | awk '/nameserver/ {print $2}' | awk 'NR == 1 {print; exit}'`
checkdomain=yahoo.com

#arg: allow a script to receove input from a command line
#functions that scan ports, ping a servers avaiable on a network. 

function portscan
{
  tput setaf 6; echo "Starting port scan of $checkdomain port 80"; tput sgr0;
  if nc -zw1 $checkdomain  80; then
    tput setaf 2; echo "Port scan good, $checkdomain port 80 available"; tput sgr0;
  else
    echo "Port scan of $checkdomain port 80 failed."
  fi
}
#function to ping the targeted server
function pingnet
{
#yahoo has the most reliable host name.
  tput setaf 6; echo "Pinging $checkdomain to check for internet connection." && echo; tput sgr0; #setaf: set up to 256 colors
  ping $checkdomain -c 4

  if [ $? -eq 0 ] #run a command and you wish to know if it works or not use: $?
    then
      tput setaf 2; echo && echo "$checkdomain pingable. Internet connection is most probably available."&& echo ; tput sgr0;
    else
      echo && echo "Internet connection is not established. Something may be wrong here." >&2
#exit 1
  fi
}

function pingDNS
{
#Grab first DNS server from /etc/resolv.conf
  tput setaf 6; echo "Ping first DNS server in resolv.conf ($checkDNS) to check name resolution" && echo; tput sgr0;
  ping $checkDNS -c 4
    if [ $? -eq 0 ]
    then
      tput setaf 6; echo && echo "$checkDNS pingable. Proceeding with domain check."; tput sgr0;
    else
      echo && echo "Internet connection is not established to DNS. Something may be wrong here." >&2

#exit 1
  fi
}

function http
{
  tput setaf 6; echo && echo "Checking for HTTP Connectivity"; tput sgr0;
#exit 0
}

#Ping gateway first to verify connectivity with LAN
tput setaf 6; echo "Pinging gateway ($GW) to check for LAN connectivity" && echo; tput sgr0;
if [ "$GW" = "" ]; then
    tput setaf 1;echo "There is no gateway. Probably disconnected..."; tput sgr0;
#exit 1
fi

ping $GW -c 4



if [ $? -eq 0 ]
then
  tput setaf 6; echo && echo "LAN Gateway pingable. Proceeding with internet connectivity check."; tput sgr0;
       pingDNS
       pingnet
       portscan
       http

  exit 0
else
  echo && echo "Something is wrong with LAN (Gateway unreachable)"
       pingDNS
       pingnet
       portscan
       http

#exit 1
fi
