packer-pfsense
===========
Packer stuff to build pfSense 2.3.4 x86_64

## Requirements
* Packer
* Vagrant
* Virtualbox and/or VMware

## About the Boxes
We start with a pfSense 2.3.4 x64 base .iso and run a few scripts on it before creating a vagrant compatible .box for Virtualbox and/or VMware.

#### packer build of pfSense 2.3.4
 - User 'vagrant' is created with password 'vagrant' and added to user group 'wheel'.
 - Enables passwordless sudo for user group 'wheel'.
 - Authorized keys for 'vagrant' user are stored in the ~/.ssh directory.
 - Enables ssh service at boot.
 - Vagrant shared folders are turned off.
 - Vagrant provisioning doesn't currently work so provision with Packer.
 - Virtualbox guest additions installed
 - Open VM Tools Installed

### Vagrant host Build 
 - variables can be overriden by Environment variables.
 - variables are gathered togther in the head of the vagrant file where possible.
 - place your config.xml file in a subfolder ./files
 - the pkg repo is updated, old packages are upgraded and audit databse initialised.
 - squid, iftop and nmap have all been installed using pfsense installpkg functions

## TODO
 - read up more on pfSense 'pre-flight install' and see if we can use it | https://doc.pfsense.org/index.php/Booting_Options#Customizing_the_boot_environment
 - if that doesn't work, try restoring from floppy using packer/floppy_files and this link https://doc.pfsense.org/index.php/Automatically_Restore_During_Install
 - see if I can install sudo as a pfsense managed package and control the config alloing vagrant sudo access within the config.xml file.
 
## Notes
 There is quite a bit of hackery to get this working. I'm also new to FreeBSD and pfSense so I'll document stuff here.
 
 - There is no 'preload' like Debian boxes, so instead we have to get certain things done in the 'boot command' step:
   - install sudo, bash, virtualbox-ose-additions
   - create our user 'vagrant' with password 'vagrant'
   - add user 'vagrant' to 'wheel' group
   - enable passwordless sudo for 'wheel' group
   - change root password to 'vagrant' -> under review

- Once that's done we upload our config.xml from out http folder to the VM
   - This config file may not be secure, I'm more focused on making things work for now.
 
 - Things that have to be in there for packer/vagrant to work:
   - group 'wheel'
   - user 'vagrant' with mitchellh authorized_key
   - choose option 14 on the console menu to enable secure shell.
   - the string ```<enablesshd/>```

 - pfSense likes to mess with /etc/passwd and other stuff on reboot so we need to reset our user 'vagrant' user stuff by using `<shellcmd>` in the imported config.xml to issue commands at boot
   - ```<shellcmd>pw usermod vagrant -s /usr/local/bin/bash</shellcmd>```
   - ```<shellcmd>pw group mod wheel -m vagrant</shellcmd>```
   - ```<shellcmd>chown -R vagrant /home/vagrant/.ssh</shellcmd>```

 - Frome here our regular scripts take over like a "normal Packer" install
   - scripts/init.sh        -   change ttyv[0] and set date.
   - scripts/rc.conf.sh     -   disabling dumpdev
   - scripts/virtualbox.sh  -   installs virtualbox-ose-additions from freebsd repos
   - scripts/vmtools.sh     -   installs PFsense maintained Open VM Tools. 
   - scripts/vagrant.sh     -   setup vagrant ssh keys
   - scripts/sshd.sh        -   check and disable sshd useDNS 
   - scripts/xml-config.sh  -   writes our /http/config.xml file to /conf/config.xml disabled for now
   - scripts/chef.sh        -   is being ignored at this time.
   - scripts/cleanup.sh     -   clean out pkg cache
   - scripts/minimize.sh    -   prepare disk for export so that it can be minimized



