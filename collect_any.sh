#!/bin/sh
#
# Collect ANY queries, if they are edns0 buf added.
# rotate the tcpdump files every N minutes.
#
# Sample command-line:
# tcpdump -Nni eth0 -s0 -G 300 -w /prod/logs/caps/any_edns-%Y-%m-%d-%H:%M:%S \
#                       dst port 53 and \
#                       'ip[((ip[2:2]) - 14):1] = 0xff' and \
#                       'ether[0x35] = 1'  
#
# author: chris@as701.net
# gplv2-ish
#
RUNNING=$(ps -ef | grep [t]cpdump | grep 'port 53' > /dev/null)
if [ $? -eq 0 ] ; then
  echo "Already running tcpdump, not restarting."
  exit
fi

# Set defaults for interface and log stash.
CAP_INT=$1
CAP_LOC=/prod/logs/caps

# Process command-line options
while getopts ":l:i:" opt; do
  case ${opt} in
    l)
      CAP_LOC=${OPTARG}
      ;;
    i)
      CAP_INT=${OPTARG}
      ;;
    *)
      echo "Usage: $0 -i <interface> -l <log-location>"
      exit
      ;;
  esac
done

CAP_LEN=300
CAP_FILE=${CAP_LOC}/any_dns-%Y-%m-%d-%H:%M:%S
#
# Shell escaping proved to hard for today, this could have
# gone into a -F file.txt as well, but expedience won out.
CAP_EXPR1='dst port 53 and '
CAP_EXPR2="ip[((ip[2:2])-14):1]=0xff and ether[0x35]=1"
CAP_EXPR="${CAP_EXPR1} ${CAP_EXPR2}"

# Construct the whole of the tcpdump command
TCPDUMP="/usr/sbin/tcpdump -Nni ${CAP_INT} -G ${CAP_LEN} -w ${CAP_FILE} ${CAP_EXPR}"

# Check to see if the storage location exists, make it if not.
if [ ! -d ${CAP_LOC} ] ; then
  /bin/mkdir -p ${CAP_LOC}
fi

# run tcpdump, background it and then let this shell script exit.
$(${TCPDUMP}) > /dev/null 2>&1 &
