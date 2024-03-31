# IP Address Functions

# Get IP Address of ethernet interface
function eip() {
  ip addr show label 'enp*' | grep 'inet' | grep -v 'inet6' | awk '{print $2}' $argv;
}

# Get IP Address of wireless interface
function wip() {
  ip addr show label 'wlp*' | grep 'inet' | grep -v 'inet6' | awk '{print $2}' $argv;
}

# Get Primary Remote IP
function remoteip() {
  dig +short myip.opendns.com @resolver1.opendns.com
}
