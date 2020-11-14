# Ubuntu Server

Setup script used to deploy Ubuntu server with my preferred settings and packages.

## Usage

The following installs some packages, creates a new user with sudo permissions and creates a pretty message of the day:

```bash
# Define variables
export HOSTNAME=hostname
export USERNAME=username
export PASSWORD=password

# Download and run script
curl -s -L https://raw.githubusercontent.com/jonasmagnusson/ubuntu-server/main/setup.sh | bash
```

## Packages

The following packages are installed:

* apt-transport-https
* chkrootkit
* docker-ce
* figlet
* golang-go
* net-tools
* openvpn
* python
* python-pip
* python3
* python3-pip
* rkhunter
