if status --is-interactive
    # Safe Actions
    abbr -a -g cp cp -i
    abbr -a -g mv mv -i
    abbr -a -g rm rm -i

    # QoL shell aliases
    abbr -a -g ll ls -lh
    abbr -a -g ack ag
    abbr -a -g .. cd ..
    abbr -a -g ... cd ../..
    abbr -a -g .... cd ../../..
    abbr -a -g dev cd ~/dev

    # IP Addresses
    abbr -a -g remoteip dig +short myip.opendns.com @resolver1.opendns.com
end