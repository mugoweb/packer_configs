# Building Machine Images With Packer

HarshiCorp's **Packer** automates building machine images. Using Packer, you can use a single set of [provisioners](https://www.packer.io/docs/provisioners) to build images for multiple [builders](https://www.packer.io/docs/builders) (such as VirtualBox, Digital Ocean, and Google Cloud).

# Building Vagrant Boxes

Vagrant boxes are machine images that have been packaged for use with Vagrant. [By convention](https://www.vagrantup.com/docs/boxes/base.html#default-user-settings), this means they have a ```vagrant``` user, are configured for passwordless sudo, and may even have the VirtualBox Guest Additions installed. The [Vagrant cloud](https://app.vagrantup.com/boxes/search?sort=downloads&provider=virtualbox) is a repository of such boxes. 

While many boxes include additional software (for instance, a fully configured LAMP stack), [base boxes](https://www.vagrantup.com/docs/boxes/base.html) include a bare operating system and are meant to be configured and repackaged for your specific needs (for instance, a custom stack for your web application). 


# Using Packer To Build Vagrant Boxes

For many use cases, it is enough to repackage an existing Vagrant box. 

But let's say you're planning a project that requires a local development environment, a staging environment, and a production environment. You have a distributed team using different operating systems so your development environment must be reproducible and virtualized. Due to external constraints, the staging environment must be hosted on Cloud Provider A and the production environment must be deployed to Cloud Provider B. You're expecting a lot of traffic and need a load balancer in front of several servers. You've done this before and have a very specific stack in mind.

Enter Packer. 

Packer allows you to build machine images for multiple platforms using a single point of provisioning. You define a set of **builders**, which are the platforms you want to export images to, and a set of **provisioners**, which can range from shell to Ansible, Chef, and Puppet. Packer creates machines on each platform, provisions on each such machine, shuts down the machines, exports platform-specific images, and destroys the machines. What's left is a set of platform-specific images that can be used to create multiple instances on each platform.

Here is a typical packer project structure:

```
.
├── README.md
├── ansible
│   ├── main.yml
│   └── requirements.yml
├── http
│   └── preseed.cfg
├── iso
│   └── ubuntu-18.04.1-server-amd64.iso
├── scripts
│   ├── ansible.sh
│   ├── cleanup.sh
│   ├── init.sh
│   └── init_vagrant.sh
├── secrets
│   ├── do.json
│   └── gcloud.json
├── ubuntu18041.json
└── vagrant
    └── Vagrantfile
```

Almost everything in the above layout is optional except the main Packer configuration file, (named **ubuntu18041.json** in the example above). This file defines the set of **builders** and **provisioners**. Unless instructed otherwise, Packer will run all **provisioners** will against all builders.

To validate your Packer configuration, run

```
packer validate -var-file=secrets/do.json ubuntu18041.json
```

To build your images, run

```
packer build -var-file=secrets/do.json ubuntu18041.json
```

To build images only for a specific builder -- for instance, VirtualBox -- run

```
packer build -only virtualbox-iso -var-file=secrets/do.json ubuntu18041.json
```

Once built, to add an image to Vagrant, run

```
vagrant box add packer-ubuntu-18041-amd64 vagrant/packer-ubuntu-18041-amd64.box
```

And then to use it in a Vagrantfile you can simply do

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "packer-ubuntu-18041-amd64"
end
```
