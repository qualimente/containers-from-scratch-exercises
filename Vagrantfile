Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/16.04.2-20170727"
  config.vm.hostname = "containers.demo"
  config.vm.network :private_network, ip: "192.168.0.42"

  config.vm.provider :virtualbox do |vb|
    vb.customize [
      "modifyvm", :id,
      "--cpuexecutioncap", "50",
      "--memory", "1024",
    ]
  end

  config.vm.provision "shell", path: "provision.sh"
end

