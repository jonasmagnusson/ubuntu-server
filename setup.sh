#!/bin/bash

# Get parameters
echo "Enter new username:"
read USERNAME

echo "Enter new password:"
read -s PASSWORD

echo "Enter hostname:"
read HOSTNAME

# Set hostname
echo $HOSTNAME > /etc/hostname
echo "127.0.0.1 $HOSTNAME localhost" > /etc/hosts

# Update and upgrade
apt-get -y update
apt-get -y upgrade

# Add user to sudoers file
useradd -m -p 12345 -s /bin/bash $USERNAME
usermod -aG sudo $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd

# Remove default user
deluser ubuntu

# Set timezone
timedatectl set-timezone Europe/Stockholm

# Install APT HTTPS
apt-get install -y apt-transport-https

# Install Net-tools
apt-get install -y net-tools

# Install OpenVPN
apt-get install -y openvpn

# Install Chkrootkit
apt-get install -y chkrootkit

# Install python2
apt-get install -y python

# Install python2 pip
apt-get install -y python-pip

# Install Python3
apt-get install -y python3

# Install Python3 PIP
apt-get install -y python3-pip

# Install Docker
curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
sh /tmp/get-docker.sh
usermod -aG docker $USERNAME

# Install Go Language
add-apt-repository -y ppa:longsleep/golang-backports
apt -y update
apt install -y golang-go

# Create motd
apt-get install -y figlet
rm /etc/update-motd.d/10-uname
touch /etc/update-motd.d/motd
chmod +x /etc/update-motd.d/motd
truncate -s 0 /etc/motd

# Motd script
cat << "EOT" > /etc/update-motd.d/motd
#!/bin/bash

printf "\033c"

# Show hostname
echo "$(hostname)" | tr a-z A-Z | figlet -w 1000

# Get load averages
IFS=" " read LOAD1 LOAD5 LOAD15 <<<$(cat /proc/loadavg | awk '{ print $1,$2,$3 }')

# Get free memory
IFS=" " read USED FREE TOTAL <<<$(free -htm | grep "Mem" | awk {'print $3,$4,$2'})

# Get processes
PROCESS=`ps -eo user=|sort|uniq -c | awk '{ print $2 " " $1 }'`
PROCESS_ALL=`echo "$PROCESS"| awk {'print $2'} | awk '{ SUM += $1} END { print SUM }'`
PROCESS_ROOT=`echo "$PROCESS"| grep root | awk {'print $2'}`
PROCESS_USER=`echo "$PROCESS"| grep -v root | awk {'print $2'} | awk '{ SUM += $1} END { print SUM }'`

# Get processors
PROCESSOR_NAME=`grep "model name" /proc/cpuinfo | cut -d ' ' -f3- | awk {'print $0'} | head -1`
PROCESSOR_COUNT=`grep -ioP 'processor\t:' /proc/cpuinfo | wc -l`

W="\e[0;39m"
G="\e[0;32m"

# System Information
echo -e "
${W}System info:
$W  Distro......: $W`cat /etc/*release | grep "PRETTY_NAME" | cut -d "=" -f 2- | sed 's/"//g'`
$W  Kernel......: $W`uname -sr`

$W  Uptime......: $W`uptime -p`
$W  Load........: $G$LOAD1$W (1m), $G$LOAD5$W (5m), $G$LOAD15$W (15m)
$W  Processes...:$W $G$PROCESS_ROOT$W (root), $G$PROCESS_USER$W (user), $G$PROCESS_ALL$W (total)

$W  CPU.........: $W$PROCESSOR_NAME ($G$PROCESSOR_COUNT$W vCPU)
$W  Memory......: $G$USED$W used, $G$FREE$W free, $G$TOTAL$W total$W"

# Config
max_usage=90
bar_width=50

# Colors
white="\e[39m"
green="\e[0;32m"
red="\e[0;31m"
dim="\e[2m"
undim="\e[0m"

# Disk usage: ignore zfs, squashfs & tmpfs
mapfile -t dfs < <(df -H -x zfs -x squashfs -x tmpfs -x devtmpfs --output=target,pcent,size | tail -n+2)
printf "\nDisk usage:\n"

for line in "${dfs[@]}"; do
    # Get disk usage
    usage=$(echo "$line" | awk '{print $2}' | sed 's/%//')
    used_width=$((($usage*$bar_width)/100))
    # Color is green if usage < max_usage, else red
    if [ "${usage}" -ge "${max_usage}" ]; then
        color=$red
    else
        color=$green
    fi
    # Print green/red bar until used_width
    bar="[${color}"
    for ((i=0; i<$used_width; i++)); do
        bar+="="
    done
    # Print dimmmed bar until end
    bar+="${white}${dim}"
    for ((i=$used_width; i<$bar_width; i++)); do
        bar+="="
    done
    bar+="${undim}]"
    # Print usage line & bar
    echo "${line}" | awk '{ printf("%-31s%+3s used out of %+4s\n", $1, $2, $3); }' | sed -e 's/^/  /'
    echo -e "${bar}" | sed -e 's/^/  /'
done
EOT

# Update and upgrade
apt-get -y update
apt-get -y upgrade

# Clean up disk space
apt-get -y autoremove
apt-get -y clean
