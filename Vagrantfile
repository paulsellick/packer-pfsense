# -*-- m mode: ruby -*-
# vi: set ft=ruby :

# Note please install vagrant-vbguest plugin
# vagrant plugin install vagrant-vbguest
# vagrant plugin install vagrant-puppet-install
# vagrant plugin install vagrant-cachier
# vagrant plugin install landrush

# You can ask for more memory and cores when creating your Vagrant machine with
# different environment variables:
#
# $ env VAGRANT_RAM_MB=2048 VAGRANT_CPU=2 vagrant up
#
# The following environment variables are available to configure the VM when it
# is provisioned:
#

# ENABLE_NFS=0 to disable NFS.  Enabled by default.
$enable_nfs = ENV['ENABLE_NFS'] || '0'

# ENABLE_PROXY=0 to disable forwarding along {HT,F}TP_PROXY environment
# variables.  Enabled by default.
$enable_proxy = ENV['ENABLE_PROXY'] || '1'

# ENABLE_SSH_AGENT=1 to enable forwarding the SSH Agent environment variables.
# Disabled by default.
$enable_ssh_agent = ENV['ENABLE_SSH_AGENT'] || '0'

# Virtual Machine name
$vm_hostname    = ENV['VM_HOSTNAME'] || 'pf2.lab.local'
$vm_box         = ENV['VM_BOX'] || 'pfsense'
$vm_guest       = ENV['VM_GUEST'] || :freebsd
$vm_group       = ENV['VM_GROUP'] || "/lab.local/core" 

# ZFS root enabled so don't decrease this value too low.
$vm_memory      = ENV['VM_MEMORY'] || '1024'

# Number of CPU cores
$vm_cpu         = ENV['VM_CPU'] || '2'

# Directory inside of the guest to share betwen your host OS and the guest.
$vm_app_dir     = ENV['VM_APP_DIR'] || "/files"

# Message to display once the VM has been spun up
$vm_post_up_message = <<MESSAGE
Name: #{$vm_hostname}
Built From: #{$vm_box}
Num cores: #{$vm_cpu}
MB RAM: #{$vm_memory}
Application directory: #{$vm_app_dir}
MESSAGE

# Configure the Provisioning Script.  The $provisioning_script provides this
# Vagrant box with an update script to bring the box up to date when the box is
# brought online via `vagrant up`.  It is very likely that a Vagrant box has
# aged since it was last used and may need to update various bits.

$provisioning_script = <<SCRIPT
echo I am provisioning...
sudo sh -c 'date > /etc/vagrant_provisioned_at'

# echo 'Update the pkg database...'
# ASSUME_ALWAYS_YES=yes pkg bootstrap

echo 'Update the package repository catalogues ...'
sudo sh -c 'cd /tmp && pkg update'

echo 'Upgrading out of date packages...'
sudo sh -c 'cd /tmp && pkg upgrade -y'

echo 'Initializing the pkg audit database...'
sudo sh -c 'cd /tmp && pkg audit -F'

sudo sh -c 'cp ~vagrant/config.xml /conf/config.xml'

# Unconditionally remove $GOPATH/pkg every upgrade in order to prevent ABI
# incompatibilities resulting from automatic upgrades from `lang/go`.
GOBIN="`which 2>&1 /dev/null go | head -1`"
if [ -n "${GOBIN}" ]; then
rm -rf "`${GOBIN} env GOPATH`/pkg"
fi

# sudo pfSsh.php playback enableallowallwan

sudo pfSsh.php playback installpkg squid
sudo pfSsh.php playback installpkg iftop
sudo pfSsh.php playback installpkg nmap

echo provisioning cycle closing.

SCRIPT

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = $vm_box
  config.vm.hostname = $vm_hostname
  config.vm.guest = $vm_guest
  # check for the pressence of the vagrant-vbguest plugin before setting these variables.
  if Vagrant.has_plugin?("vagrant-vbguest")
    # we will try to autodetect this path.
    # However, if we cannot or you have a specify one, you may pass it like:
    # config.vbguest.iso_path = "#{ENV['HOME']}/Downloads/VBoxGuestAdditions.iso"
    # or an URL:
    # config.vbguest.iso_path = "http://company.server/VirtualBox/%{version}/VBoxGuestAdditions.iso"
    # or relative to the Vagrantfile:
    # config.vbguest.iso_path = File.expand_path("../relative/path/to/VBoxGuestAdditions.iso", __FILE__)
    config.vbguest.no_install = true
    # set auto_update to false, if you do NOT want to check the correct
    config.vbguest.auto_update = false
    # do NOT download the iso file from a webserver
    config.vbguest.no_remote = true
  end
  # check for the pressence of the vagrant-cachier plugin before setting these variables.
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  # check for the pressence of the vagrant-landrush plugin before setting these variables.
  if Vagrant.has_plugin?("vagrant-landrush")
    config.landrush.enabled = true
    # config.landrush.host 'static1.example.com', '1.2.3.4'
    # config.landrush.host 'static2.example.com', '2.3.4.5'
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 80, host: 3080
  config.vm.network "forwarded_port", guest: 443, host: 30443
  # config.vm.network "forwarded_port", guest: 22, host: 2222

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "private_network", ip: "192.168.56.254", adapter: "2"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network" 

  
  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  #
  # the below block exists already in the box template
  # config.vm.synced_folder "../data", "/vagrant_data", disabled: true
  #
  # config.vm.synced_folder ".", $vm_app_dir, :id => "vagrant-root",
  #                        nfs: true, type: "nfs", nfs_udp: false,
  #                        mount_options: ['noatime'],
  #                        freebsd__nfs_options: ['nolockd'], :disable_usable_check => true
  #
  # ERROR ==> default: Automatic installation for Landrush IP not enabled
  # No guest IP was given to the Vagrant core NFS helper. This is an
  # internal error that should be reported as a bug.

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
  # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  # Customize the Name of the VM
    vb.name = $vm_hostname

  # Customize the amount of memory on the VM:
    vb.memory = $vm_memory

  # Customise Instance groups
    vb.customize [ "modifyvm", :id, "--groups", "/lab.local/core" ]
    vb.customize [ "modifyvm", :id, "--description", "pfSense Firewall 2.3.4 for lab.local domain" ]

  # Customise 1st Nic with Nat Wan
	vb.customize [ "modifyvm", :id, "--nic1", "nat" ]

  # Customise 2nd Nic with Private Lan
	vb.customize [ "modifyvm", :id, "--nic2", "hostonly" ]
	vb.customize [ "modifyvm", :id, "--hostonlyadapter2", "vboxnet0" ]

  # Enforce other hardware options.
	vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
    if $cpu.to_i > 1
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
    end
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

#   config.ssh.shell = "/bin/sh"
#   config.ssh.forward_agent = true
#   config.ssh.insert_key = false
#   if $enable_proxy.to_i != 0
#     config.ssh.forward_env << "HTTP_PROXY=$http_proxy" if !ENV.fetch('HTTP_PROXY', '').empty?
#     config.ssh.forward_env << "FTP_PROXY=$ftp_proxy"   if !ENV.fetch('FTP_PROXY', '').empty?
#   end
#   config.ssh.forward_agent = $enable_ssh_agent.to_i != 0
#   config.ssh.keep_alive = true
#   config.ssh.shell = "/bin/sh"
#   config.ssh.sudo_command = 'sudo -E -H %'

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.

    config.vm.provision "file", source: "./files/config.xml", destination: "~/config.xml"
    config.vm.provision "shell" do |s|
		s.inline = <<-SHELL
            echo 'renaming host ...'
            sed -e "s/pfSense.localdomain/$1/" /etc/hosts | sed -e "s/pfSense/$2/" > /etc/hosts.new
            mv /etc/hosts.new /etc/hosts
  		SHELL
		    s.args   = $vm_hostname, $vm_hostname.split(".").first
	end
    config.vm.provision :shell, privileged: false, inline: $provisioning_script

# 	if Vagrant.has_plugin?("vagrant-puppet-install")
#   		# config.puppet_install.puppet_version = :latest
#     	config.puppet_install.puppet_version = "3.8.7"
# 	end
# 	env = "dev"
#   	puppet_trunk = "../puppet"
#   	config.vm.synced_folder "#{puppet_trunk}", "/etc/puppet"
# 
#   	config.vm.provision "puppet" do |puppet|
# 		puppet.environment_path  = "#{puppet_trunk}/environments"
# 		puppet.manifests_path    = [ "#{puppet_trunk}/environments/#{env}/manifests",
# 									 "#{puppet_trunk}/manifests" ]
# 		puppet.module_path       = [ "#{puppet_trunk}/environments/#{env}/modules",
# 									 "#{puppet_trunk}/modules" ]
# 		puppet.hiera_config_path = "#{puppet_trunk}/hiera.yaml"
# 		puppet.environment       = "#{env}"
# 		puppet.options           = "--debug --verbose"
# 		puppet.working_directory = "/etc/puppet/environments/#{env}"
	config.vm.post_up_message = $vm_post_up_message
end

