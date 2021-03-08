# Suppressing Duo

Duo enhances security. It can also be disruptive and annoying. This page presents two approaches to suppressing Duo. We recommend using the first approach below due to its simplicity. Note that by "suppressing" we mean minimizing as opposed to eliminating. That is, you will still need to Duo authenticate but much less so.

## I. VPN Approach

Install a [VPN client](https://www.princeton.edu/vpn). Connect via the VPN client. Start your work. You will only need to DUO authenticate once per session (which typically lasts a few hours).

To install a VPN client on your laptop/workstation follow this [OIT KnowledgeBase article](https://www.princeton.edu/vpn). GlobalProtect is recommended.

> Secure Remote Access (SRA) is a service for Princeton faculty, staff, and students who are off-campus and need to access restricted campus resources through a Virtual Private Network (VPN). After authenticating, remote computers function as if they were on campus, and as long as your SRA connection is active, all Internet activity from your computer is routed through Princeton servers and your computer is giving a Princeton IP address.

OIT is responsible for the VPN so please [contact them](https://princeton.service-now.com/service) with any questions or problems.

### What if the VPN is too slow?

The use of a VPN will decrease your internet connection speed. The table below was generated on 3/6/2021 at an off-campus location in Princeton with a FIOS connection using [speedtest.net](https://www.speedtest.net):

| VPN           | Download (Mbps)| Upload (Mbps)  |
| ------------- |:-------------:|:-----:|
| None          | 865           |   635 |
| None          | 888           |   598 |
| GlobalProtect | 593           |   213 |
| GlobalProtect | 688           |   220 |
| SonicWall     | 57            |    60 |
| SonicWall     | 57            |    62 |

The SonicWall VPN severely decreases transfer rates and should be avoided. If you still find poor performance with the GlobalProtect VPN then consider the multiplexing solution described below which is VPN-free.

[Another approach](https://researchcomputing.princeton.edu/ssh) which does not require a VPN is to ssh to `tigressgateway.princeton.edu` and then from there, ssh to your desired cluster (e.g., della) as shown in the figure below. You must have an account on one of the large clusters to do this. Use `nobel.princeton.edu` as the hop-through if you only have an account on Adroit and you want to connect to Adroit without using a VPN. If you are transferring many files you will want to use multiplexing to avoid Duo authentication as described below.

<p align="center"><img src="https://tigress-web.princeton.edu/~jdh4/hop_through_no_vpn_needed.png" align="center" width=70%></p>

### If the Linux VPN is not working

Try the procedure below from T. Jones of the Tech Clinic if your VPN client on Linux is not working:

```
echo "Enter your netid"
read netid
wget --user=$netid --ask-password https://web.princeton.edu/sites/oitdownloads/vpn/Linux%20x64/ConnectTunnel-Linux64.tar
tar -xvf ConnectTunnel-Linux64.tar
sudo ./install.sh
sudo apt-get install openjdk-8-jre
startctui
```

### Preventing VPN disconnects

If your VPN is disconnecting too frequently then try adding these lines to your `~/.ssh/config` file (make the file if necessary):

```
Host *
  Compression yes
  ServerAliveInterval 30
  ServerAliveCountMax 10
```

This will cause a "ping" every 30 seconds and hopefully prevent disconnections. OIT manages the VPN so please [contact them](https://princeton.service-now.com/service) for assistance.



## II. Multiplexing Approach (VPN free)

> Multiplexing involves the simultaneous transmission of several messages along a single channel of communication.

The following solution is from Bill Wichser of Research Computing.

Q: *How do I avoid having to authenticate with Duo every time?*

A: Yes this is painful! But there are a few things one can do. I will explain one approach using ssh multiplexing which uses a single ssh connection and sends all communication over that channel. This means that you will only need to Duo authenticate once.

But do be aware of why Duo is being used in the first place. It is to protect our systems. The reason I mention this is because you do have options with the method I am going to provide with respect to time limits on how long the multiplexed functionality remains operational. Set too low and your very next ssh/scp will require Duo authentication again. But set too high, the protection could be bypassed which makes us all vulnerable.

Note that a [VPN](https://www.princeton.edu/vpn) is required to use the OnDemand web portals of MyAdroit and MyDella as well as for various library services.

### On-Campus

Step 1: To make this work, on your Linux or macOS **local machine** (laptop/desktop), edit the file `~/.ssh/config` by adding a machine stanza which looks like this (**replace aturing with your NetID**):

```
Host della.princeton.edu della
  User aturing
  HostName della.princeton.edu
  ControlPath ~/.ssh/controlmasters/%r@%h:%p
  ControlMaster auto
  ControlPersist 10m
```        

Step 2: Then do a `mkdir ~/.ssh/controlmasters` to create the directory for telling ssh how to use this multiplexed session.

The very first login to `della` (from on-campus since no VPN) would start the multiplexing option:

```
$ ssh della
```

The command above will Duo authenticate but subsequent sessions will use that connection and not require Duo. The multiplexer remains active for ControlPersist time, as defined in your `~/.ssh/config` file, once the last ssh session has terminated.

Some handy commands from your local machine (laptop/desktop):

```
$ ssh -O check della    -- this checks whether a multiplexed session is already open
$ ssh -O stop della     -- kills the multiplexed session
```

The line `Host della.princeton.edu della` allows one to create aliases which explains why we can use `della` or `della.princeton.edu` in the commands above.

### Off-Campus

When off-campus and not using a VPN, **if you have an account on one of the large clusters** (not Adroit, not Nobel) then one can use `tigressgateway` as a proxyjump server.

<p align="center"><img src="https://tigress-web.princeton.edu/~jdh4/multiplexed_connection.png" align="center"></p>


Step 1: On your **local machine** (laptop/desktop) make these directories and set the permissions:

```
$ mkdir -p ~/.ssh/controlmasters
$ mkdir -p ~/.ssh/sockets
$ chmod 700 ~/.ssh/sockets
```

Step 2: Modify your `.ssh/config` file as follows (**replace aturing with your NetID**):

```
Host tigressgateway.princeton.edu tigressgateway
  HostName tigressgateway.princeton.edu
  User aturing
  ControlMaster auto
  ControlPersist yes
  ControlPath ~/.ssh/sockets/%p-%h-%r
  ServerAliveInterval 300
  LocalForward 5908 della.princeton.edu:5908
  LocalForward 5909 della.princeton.edu:5909

Host della.princeton.edu della
  User aturing
  HostName della.princeton.edu
  ProxyJump tigressgateway.princeton.edu
  ControlMaster auto
  ControlPersist yes
  ControlPath ~/.ssh/sockets/%p-%h-%r
```

You can then connect from your local machine (laptop/desktop) using the following command:

```
$ ssh della
```

The above command will use the proxyjump server `tigressgateway`. The connection first goes to `tigressgateway` where it Duo authenticates before hopping to della. In the process it sets up some port forwarding for the given ports in case you require VNC access or other processes to tunnel through. See `man ssh_config` in the section for ProxyJump.

You should be able to `scp localfile della:` without incurring extra Duo authentications since the connection is established and multiplexed.

Below is a sample file of `.ssh/config` for multiple clusters (**replace aturing with your NetID**):

```
Host tigressgateway.princeton.edu tigressgateway
  HostName tigressgateway.princeton.edu
  User aturing
  ControlMaster auto
  ControlPersist yes
  ControlPath ~/.ssh/sockets/%p-%h-%r
  ServerAliveInterval 300
  LocalForward 5908 traverse.princeton.edu:5908
  LocalForward 5909 traverse.princeton.edu:5909
  LocalForward 5910 tigergpu.princeton.edu:5910
  LocalForward 5911 tigergpu.princeton.edu:5911
  LocalForward 5912 tigercpu.princeton.edu:5912
  LocalForward 5913 tigercpu.princeton.edu:5913
  LocalForward 5914 della.princeton.edu:5914
  LocalForward 5915 della.princeton.edu:5915
  LocalForward 5916 perseus.princeton.edu:5916
  LocalForward 5917 perseus.princeton.edu:5917
  LocalForward 5918 adroit.princeton.edu:5918
  LocalForward 5919 adroit.princeton.edu:5919
  LocalForward 5920 nobel.princeton.edu:5920
  LocalForward 5921 nobel.princeton.edu:5921
  LocalForward 5922 tigressdata.princeton.edu:5922
  LocalForward 5923 tigressdata.princeton.edu:5923
  LocalForward 5924 stellar.princeton.edu:5924
  LocalForward 5925 stellar.princeton.edu:5925

Host traverse.princeton.edu traverse
  User aturing
  HostName traverse.princeton.edu
  ProxyJump tigressgateway.princeton.edu
  ControlMaster auto
  ControlPersist yes
  ControlPath ~/.ssh/sockets/%p-%h-%r

Host tigergpu.princeton.edu tigergpu
  User aturing
  HostName tigergpu.princeton.edu
  ProxyJump tigressgateway.princeton.edu
  ControlMaster auto
  ControlPersist yes
  ControlPath ~/.ssh/sockets/%p-%h-%r

Host tigercpu.princeton.edu tigercpu tiger
  User aturing
  HostName tigercpu.princeton.edu
  ProxyJump tigressgateway.princeton.edu
  ControlMaster auto
  ControlPersist yes
  ControlPath ~/.ssh/sockets/%p-%h-%r

Host della.princeton.edu della
  User aturing
  HostName della.princeton.edu
  ProxyJump tigressgateway.princeton.edu
  ControlMaster auto
  ControlPersist yes
  ControlPath ~/.ssh/sockets/%p-%h-%r

Host perseus.princeton.edu perseus
  User aturing
  HostName perseus.princeton.edu
  ProxyJump tigressgateway.princeton.edu
  ControlMaster auto
  ControlPersist yes
  ControlPath ~/.ssh/sockets/%p-%h-%r

Host adroit.princeton.edu adroit
  User aturing
  HostName adroit.princeton.edu
  ProxyJump tigressgateway.princeton.edu
  ControlMaster auto
  ControlPersist yes
  ControlPath ~/.ssh/sockets/%p-%h-%r

Host tigressdata.princeton.edu tigressdata
  User aturing
  HostName tigressdata.princeton.edu
  ProxyJump tigressgateway.princeton.edu
  ControlMaster auto
  ControlPersist yes
  ControlPath ~/.ssh/sockets/%p-%h-%r
  
Host stellar.princeton.edu stellar
  User aturing
  HostName stellar.princeton.edu
  ProxyJump tigressgateway.princeton.edu
  ControlMaster auto
  ControlPersist yes
  ControlPath ~/.ssh/sockets/%p-%h-%r
  
Host nobel.princeton.edu nobel
  User aturing
  HostName nobel.princeton.edu
```

To check if the multiplexed connection is alive (remember everything is going through tigressgateway):

```
$ ssh -O check tigressgateway.princeton.edu
```

Your connection will be killed typically every few hours. To end the connection manually:

```
$ ssh -O stop tigressgateway.princeton.edu
```

### X11 Forwarding

If you are on a Mac and you experience problems with X11 forwarding then try adding the following lines to the bottom of `~/.ssh/config`:

```
Host *
  ForwardAgent yes
  ForwardX11 yes
  XAuthLocation /opt/X11/bin/xauth
```
