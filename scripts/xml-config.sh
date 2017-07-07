# Load our old config.xml file
cp /conf/config.xml /conf/config.xml.orig
# when you have a good running config you can place the config in the http
# directory and have it commited as the running config for nxt reboot.
#mv -f /home/vagrant/config.xml /conf/config.xml

# previous attempt to commiting native sudo playback.
# more work required.
# mv /home/vagrant/enable_vagrant_sudo /etc/phpshellsessions/
# chown root:wheel /etc/phpshellsessions/enable_vagrant_sudo
# chmod 644 /etc/phpshellsessions/enable_vagrant_sudo
# pfSsh.php playback enable_vagrant_sudo

# rm /tmp/config.cache
