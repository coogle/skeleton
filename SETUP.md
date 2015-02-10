# Code Base Setup

This document serves as instructions for setting up the code base on a local virtual environment.

## Getting Started

To get started running the code base you will need to download a few tools for your host platform:

  - [VirtualBox](http://www.virtualbox.org/)
  - [Vagrant](http://www.vagrantup.com/)
  - [Git](http://git-scm.com/downloads) (To download this project to your computer)
  
Please download and install each of the above software packages before continuing. There is nothing
odd about their installation procedures, simply install them with defaults for any questions asked
and you should be fine.

### Getting the Code base

You will need to checkout / clone a local copy of this code base by using the Git tools you installed.
Please refer to the right column of this page to determine the Git clone URI and use it as the source
to clone in your Git client. If you are using the command-line client, you can use something like the following:

```
$ git clone git@github.com:coogle/project
```

### Configuring the Code base

Once you have cloned the code base you will need to create a `VagrantConfig.json` file in the root directory of the project.
There is a provided `VagrantConfig.example.json` file you can open, edit, and save as `VagrantConfig.json`. Most of the
values in this config can be left as-is. An example of this config is below:

```
{
    "ipAddress" : "192.168.42.70",
    "vmMemory" : "512",
    "siteDomain" : "dev.example.com",
    "phpVersion" : "5.4",
    "aws" : {
        "accessKey" : "",
        "secretKey" : "",
        "instanceType" : "t1.micro",
        "region" : "us-east-1",
        "elasticIP" : "",
        "name" : "Skeleton",
        "ami" : "ami-d0f89fb9",
        "keyPair" : "example",
        "securityGroups" : []
    }
}
```

The one thing that should be changed for sure is the `siteDomain` value, by changing `dev.example.com` to the local domain
you would like to access the code base by. This can be anything you choose (`dev.mycoolwebsite.com`), and it is what you will
type into a browser to access the site. The second, optional, value you could change is the `ipAddress` value, which you shouldn't
need to touch unless you are running multiple VMs, or multiple copies of the code base.

Once you have made the changes you need to, make sure you save the file as `VagrantConfig.json` (case sensitive)

Now you will need to edit your local host machine's `hosts` file to add a DNS reference to the IP address of your virtual machine (the value you have for `ipAddress` in the `VagrantConfig.json` file)
and the domain name you mapped it to (the `siteDomain` configuration value).

***IMPORTANT*** Regardless of operating system editing the `hosts` file will require admin permissions. On Mac OS X this
means using something like `sudo` if editing from the terminal.

A typical `hosts` file looks as follows:

```
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1	localhost
255.255.255.255	broadcasthost
::1             localhost
```

#### Editing `hosts` on Mac OS 

Editing the hosts file on Mac OS X can be done by opening it (located at `/etc/hosts`) in a text editor and adding a line as shown:

```
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1	localhost
255.255.255.255	broadcasthost
::1             localhost
192.168.42.70   dev.mycoolsite.com # <-- Add this line
```

#### Editing `hosts` on Windows

Typically, you can find the `hosts` file on a modern Windows machine in `\Windows\system32\drivers\etc\hosts`, although
it's possible it's located elsewhere. Please check (this reference)[http://en.wikipedia.org/wiki/Hosts_%28file%29#Location_in_the_file_system] if you can't find it.

Like Mac OS X, open the file in a text editor and add the same line as shown:

```
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1	localhost
255.255.255.255	broadcasthost
::1             localhost
192.168.42.70   dev.mycoolsite.com # <-- Add this line
```

### Booting the code base

At this point, you should be able to boot the Virtual Machine for the application by simply running the `vagrant up` command
from a terminal window:

```
$ cd /path/to/my/cloned/code/base
$ vagrant up
```

(in a Windows environment you will probably use the `cmd` command to open a terminal window by going to Start->Run and typing `cmd`)

When you run this command it will download a virtual machine and begin booting, looking something like this:

```
$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'precise64'...
==> default: Matching MAC address for NAT networking...
==> default: Setting the name of the VM: dummy-test_default_1423528234992_3464
...
```

At one point in the booting process it may request admin permissions to deal with file sharing things, please either enter
your admin password or otherwise grant permissions for the code base to function properly.

This process, especially the first time, will take *many minutes* to complete. Please be patient. Once it is done the last of
the output should look something like this (likely to be mixed in with other lines):

```
==> default: Notice: Finished catalog run in 1112.59 seconds
```

***Note*** It's expected to see an occasional warning, and perhaps even an error -- it doesn't necessarily mean things didn't work. If you see warnings or errors and at the end of this process it doesn't work, then we should take a look at them.

### Logging in / Completing Install

Once Vagrant is done you should be able to log into it by typing the following into the terminal from the root of the project directory:

```
$ vagrant ssh
Welcome to Ubuntu 12.04 LTS (GNU/Linux 3.2.0-23-generic x86_64)

 * Documentation:  https://help.ubuntu.com/
New release '14.04.1 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Welcome to your Vagrant-built virtual machine.
Last login: Fri Sep 14 06:23:18 2012 from 10.0.2.2
vagrant@precise64:~$
```

Now that we are logged into the terminal, we need to run a few more commands before we can complete our setup of the local environment. Firstly, we need to update the `composer` dependencies by changing into the `/vagrant` directory (this is the shared folder where the code is) and running `composer update` as shown:

```
$ cd /vagrant
$ composer update -vvv
```
***Note*** This command will likely take awhile to run, good time for coffee.

Once composer finishes, now we need to finish initializing the database schema and seed data for the site. This can be done by executing the following commands:

```
$ php artisan migrate
$ php artisan db:seed
```

# That's it!

That's it! At this point you can exit the virtual machine's terminal by typing `exit` to return to your host machine's terminal. 

Open a browser to the site domain you entered earlier into the `hosts` file (i.e. dev.mycoolsite.com) and you should see the project up and running!

# Bringing down the VM

When you are done using the VM, you can halt the VM (without having to repeat this installation process) by simply typing `vagrant halt` in the project directory. Likewise, if you would like to open the VM back up 

