Dotenv.load

Vagrant.configure("2") do |config|
  config.vm.box = "puphpet/ubuntu1204-x64"
  #config.vm.box_url = "http://box.puphpet.com/ubuntu-precise12042-x64-vbox43.box"

  config.vm.network :private_network, :ip => "192.168.100.100"
  config.vm.hostname = ENV['WP_HOST']
  config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |vm|
    vm.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vm.customize ["modifyvm", :id, "--memory", 1536]
    vm.customize ["modifyvm", :id, "--cpus", 2]
    vm.customize ["modifyvm", :id, "--name", "#{ENV['WP_HOST']}"]
  end

  # add cache plugin for vagrant in order to
  # speed up the vm generate process
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.auto_detect = true
    # If you are using VirtualBox, you might want to enable NFS for shared folders
    # config.cache.enable_nfs  = true
  end

  config.vm.synced_folder "./", "/var/www", :id => "vagrant-root", :owner => "vagrant", :group => "www-data", :mount_options => ['dmode=772','fmode=772']
  #config.vm.provision :shell, :inline => "sudo apt-get update"

  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "vagrant/manifests"
    puppet.module_path = "vagrant/modules"
    puppet.facter = {}
    ENV.each {|key, value| puppet.facter["#{key}"] = value }

    puppet.options = ['--verbose']
  end
end
