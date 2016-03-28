---
layout: "post"
date: 2015-06-05
hasCode: true
title: "Provisioning a Development Box with Vagrant"
---

I try to automate just about every repetitive thing that I do on a computer.
Seriously, it’s bordering on being a disorder. I just hate spending hours doing
the same thing over and over again that a computer can do in minutes while I go
make a cup of coffee.

Vagrant is perfect for me then, because it allows me to set up a consistent,
repeatable development environment once and then boot into a clean version
whenever I want within minutes. It’s a little more work up front, but it really
pays off in the long run.

### What are we doing here?

I’m going to walk through the process of creating the necessary files to
automatically provision fresh development environments using Vagrant. For this
example, I’m going to set up a LAMP stack along with a bunch of development
tooling. It will be called, rather unimaginatively, vagrant-lamp-dev. You can
find all of the files in my [github repo](https://github.com/wlbrough/vagrant-lamp-dev).

### Prerequisites

In order to follow along, you’ll need a few things. If you don’t already have
this stuff installed on your system, follow the instructions at the provided
links to get it installed.

* Virtualbox ([download](https://www.virtualbox.org/wiki/Downloads))
* Vagrant ([download](http://www.vagrantup.com/downloads))
* Vagrant-HostsUpdater ([github](https://github.com/cogitatio/vagrant-hostsupdater)) (**optional**)

### Vagrantfile

The Vagrantfile is where you set up the basic aspects of the virtual machine.
This is where you define things such as what base box to use, the system
resources for the VM, host name, etc.

The basic structure of the Vagrantfile will (almost) always be

```ruby
Vagrant.configure(“2”) do |config|
  # Config goes here
end
```

The only exception to that is if you are trying to do some configuration that
needs to be compatible with early versions of Vagrant in which case you would
need a “1” instead of the “2”. This is just a block that contains your
configuration settings.

The first thing that I will do is specify the base box that my environment will
be provisioned on top of. In this case, I will specify Ubuntu 14.04 Server
64-bit. You can find a list of available boxes on the [Hashi Corp website](https://atlas.hashicorp.com/boxes/search).

```ruby
config.vm.box = "ubuntu/trusty64"
```

Next we’ll set up the hostname and networking for the VM.

```ruby
config.vm.hostname = "vagrant-lamp-dev"
config.vm.network :private_network, ip: "192.168.40.7"
config.hostsupdater.aliases = %w(lamp.dev)
config.hostsupdater.remove_on_suspend = true
```

The first line in this block just sets the hostname to “vagrant-lamp-dev”. The
next line configures a private network IP address. Why did I choose
“192.168.40.7”? Because there’s nothing else on my network with that IP address.
Your mileage may vary. It is possible to configure a public network IP address
that would allow access from other devices on your network, but I’ll assume
that’s not a desired behavior here.

If you have Vagrant-HostsUpdater installed, the next two lines configure an
entry to your local machine’s hosts file so that when you enter vagrant.wp into
a browser, you will be directed to the configured IP address. The
remove_on_suspend setting removes the hosts file entry each time you exit the
VM.

Next, we’ll configure some settings for the VM.

```ruby
config.vm.provider :virtualbox do |v|
  v.customize ["modifyvm", :id, "--memory", 1024]
  v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
end
```

The first line here just sets up the block for the Virtualbox specific config
settings. The first line inside the block specifies a memory allocation of 1Gb.
The next two lines in the config are used to resolve slow network issues and are
pretty much boilerplate in Vagrantfiles.

Finally, lets specify where to look for the provisioning file that will do the
rest of the work. I will be using the shell provisioning method, but you can get
more advanced and use Puppet or Chef also. For this exercise I will add a file
called bootstrap.sh to the same directory as the Vagrantfile.

```ruby
config.vm.provision :shell, :path => "bootstrap.sh"
```

That’s it! Now you have a fully functioning Vagrantfile. Next up is the
interesting stuff.

### bootstrap.sh

To borrow an expression from the MTV masterpiece “Cribs”, this is where the
magic happens. This is just a shell script that gets run after the VM is set up.
I’m going to keep it relatively simple here, but it would be wise to use
conditionals throughout to skip redundant operations if you re-provision at some
point after you first build the VM.

The first thing I want to do is install a bunch of packages to provide the
functionality that I need.

```bash
apt_package_list = (
 # lots of packages — see [github](https://github.com/wlbrough/vagrant-lamp-dev)
)
apt-get update --assume-yes
apt-get install --assume-yes ${apt_package_list[@]}
apt-get clean
```

First we build an array of all of the packages that we want to install. It’s a
pretty extensive list, so I’ve left it out from this article. Next we update the
package lists, install all of the packages in the array, then clean up the apt
cache.

Make sure npm is up to date and install the npm update checker.

```bash
npm install -g npm
npm install -g npm-check-updates
```

I use Bower, so that’s next up on the list.

```bash
npm install -g bower
```

I’m a recent Gulp convert, so Gulp and all of the typical plugins I use are
coming up next.

```bash
npm install -g gulp
npm install -g gulp-util
npm install -g gulp-sass
npm install -g gulp-autoprefixer
npm install -g gulp-coffee
...(continues)
```

That’s it! Now everything is in place to launch the VM.

### Launch

Now `cd` into the directory with the Vagrantfile and run

```bash
vagrant up
```

This would be a good time to go get a coffee and a snack or deal with your email
backlog. There is a lot of downloading and installing to be done, so it will
take a while.

When everything is done, you will be able to navigate to `http://lamp.dev/` and
see the Apache default page in your browser. You can ssh into the VM with the
command

```bash
vagrant ssh
```

### Fin

There’s a lot more to Vagrant than what was covered here. I would recommend
looking through the docs on the [Vagrant website](http://www.vagrantup.com/) and
playing around with other features. Happy coding!
