Vagrant.configure("2") do |config|
  config.ssh.shell = "sh"
  config.ssh.username = "docker"
  config.ssh.password = "test01"

  config.vm.synced_folder ".", "/vagrant", disabled: false

  # Expose the Docker port
  config.vm.network "forwarded_port", guest: 2376, host: 2376,
    host_ip: "127.0.0.1", auto_correct: true, id: "docker"

  # greenbox doesn't support NFS
  config.nfs.functional = false

  # greenbox doesn't persist filesystem between reboots
  #if config.ssh.respond_to?(:insert_key)
  #  config.ssh.insert_key = false
  #end

  # Attach the ISO
  config.vm.provider "virtualbox" do |v|
    v.customize "pre-boot", [
      "storageattach", :id,
      "--storagectl", "IDE Controller",
      "--port", "0",
      "--device", "1",
      "--type", "dvddrive",
      "--medium", File.expand_path("../greenbox.iso", __FILE__),
    ]

    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in TinyCore Linux, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = true
    v.functional_vboxsf     = true
  end

end
