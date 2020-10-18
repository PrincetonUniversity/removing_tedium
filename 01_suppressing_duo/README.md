# Suppressing Duo

DUO enhances security. It can also be annoying and disruptive. Here are two approaches to suppressing Duo. We recommend using the first approach below due to its simplicity. Note that by "suppressing" we mean minimizing as opposed to eliminating. You will still need to Duo authenticate but much less so.

## I. VPN Approach

Install a VPN client. Connect via the VPN client. Start you work. You will only need to DUO authenticate once per session (which typically lasts a few hours).

To install a VPN client on your laptop/workstation follow this [OIT KnowledgeBase article](https://www.princeton.edu/vpn).

> Secure Remote Access (SRA) is a service for Princeton faculty, staff, and students who are off-campus and need to access restricted campus resources through a Virtual Private Network (VPN). After authenticating, remote computers function as if they were on campus, and as long as your SRA connection is active, all Internet activity from your computer is routed through Princeton servers and your computer is giving a Princeton IP address.

OIT is responsible for the VPN so please direct any questions or problems to [them](https://princeton.service-now.com/service).

### What if the VPN is too slow?

The use of a VPN will decrease your internet connection speed. The table below was generated on 10/18/2020 at an off-campus location in Princeton with a FIOS connection using [speedtest.net](https://www.speedtest.net):

| VPN           | Download (Mbps)| Upload (Mbps)  |
| ------------- |:-------------:|:-----:|
| None          | 901           |   712 |
| None          | 912           |   660 |
| GlobalProtect | 473           |   342 |
| GlobalProtect | 511           |   290 |
| SonicWall     | 38            |    52 |
| SonicWall     | 38            |    54 |

The SonicWall VPN severely decreases transfer rates and should be avoided. If you still find poor performance with the GlobalProtect VPN then consider the multiplexing solution described below.

Another approach which does not require a VPN is to ssh to `tigressgateway.princeton.edu` and then from there, ssh to your desired cluster (e.g., della). If you are transferring many files you will want to use multiplexing to avoid Duo authentication as described below.

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

If your VPN is disconnecting too frequently (minutes instead of hours) then try adding these lines to your `~/.ssh/config` file:

```
Host *
     Compression yes
     ServerAliveInterval 30
     ServerAliveCountMax 10
```

This will cause a "ping" every 30 seconds and hopefully prevent disconnections. OIT manages the VPN. Please [contact](https://princeton.service-now.com/service) them for assistance.



## II. Multiplexing Approach (VPN free)

The following solution is from Bill Wichser of Research Computing. It is reproduced here from [this post](https://askrc.princeton.edu/question/331/how-do-i-avoid-having-to-authenticate-with-duo-every-time/).

Q: *How do I avoid having to authenticate with Duo every time?*

A: Yes this is painful! But there are a few things one can do. I will explain one approach using ssh multiplexing which uses a single ssh connection and channels all communication over that channel. This means that only once will you need to Duo authenticate.

But do be aware of why Duo is being used in the first place. It is to protect our systems. As a member or affiliate of Princeton University, you are a part of that "our systems" group. The reason I mention this is because you do have options with the method I am going to provide with respect to time limits on how long the multiplexed functionality remains operational. Set too low and the next ssh/scp will require Duo authentication again. But set too high, protection could be bypassed which makes us all vulnerable.

### On-Campus

Step 1: To make this work, on your Linux or macOS machine, edit the file `~/.ssh/config` and add a machine stanza which looks like this:

```
Host mcmillan
        HostName mcmillan.princeton.edu
        ControlPath ~/.ssh/controlmasters/%r@%h:%p
        ControlMaster auto
        ControlPersist 10m
```        

Step 2: Then do a `mkdir ~/.ssh/controlmasters` to create the directory for telling ssh how to use this multiplexed session.

The very first login to mcmillan (from on-campus since no VPN) would start the multiplexing option.

```
ssh mcmillan
```

It will Duo authenticate. But any other sessions will now use that connection and not require it. The multiplexer remains active for ControlPersist time, as defined in your `~/.ssh/config` file, for the time limit once the last ssh session has terminated.

Some handy commands from your desktop:

```
$ ssh -O check mcmillan    -- this checks whether a multiplexed session is already open
$ ssh -O stop mcmillan     -- kills the multiplexed session
```

### Off-Campus

There is another option which uses the `tigressgateway` proxy server which is needed for VPN-free access from off-campus. See `man ssh_config` in the section for ProxyJump.

Step 1: On your local machine make this directory:

```
$ mkdir ~/.ssh/sockets
```

Step 2: Modify your `.ssh/config` files as follows:

```
Host tigressgateway.princeton.edu
         ControlMaster auto
         ControlPersist yes
         ControlPath ~/.ssh/sockets/%p-%h-%r
         LocalForward 5908 perseus.princeton.edu:5908
         LocalForward 5909 perseus.princeton.edu:5909

Host perseus.princeton.edu
         ProxyJump bill@tigressgateway.princeton.edu
         ControlMaster auto
         ControlPersist yes
         ControlPath ~/.ssh/sockets/%p-%h-%r
```

From the local machine, one can then do:

```
$ ssh <YourNetID>@perseus.princeton.edu
```

The above command will use the proxyjump server `tigressgateway`. The connection first goes to tigressgateway where it Duo authenticates before hopping to perseus. In the process it sets up some port forwarding for the given ports in case you require VNC access or other processes to tunnel through.

You should be able to `scp localfile aturing@perseus.princeton.edu` without incurring extra Duo authentications since the connection is established and multiplexed.

Below is a sample file of `.ssh/config` (**replace aturing with your NetID**) for multiple clusters:

```
Host tigressgateway.princeton.edu
         ControlMaster auto
         ControlPersist yes
         ControlPath ~/.ssh/sockets/%p-%h-%r
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
         LocalForward 5920 tigressdata.princeton.edu:5920
         LocalForward 5921 tigressdata.princeton.edu:5921

Host traverse.princeton.edu
         ProxyJump aturing@tigressgateway.princeton.edu
         ControlMaster auto
         ControlPersist yes
         ControlPath ~/.ssh/sockets/%p-%h-%r

Host tigergpu.princeton.edu
         ProxyJump aturing@tigressgateway.princeton.edu
         ControlMaster auto
         ControlPersist yes
         ControlPath ~/.ssh/sockets/%p-%h-%r

Host tigercpu.princeton.edu
         ProxyJump aturing@tigressgateway.princeton.edu
         ControlMaster auto
         ControlPersist yes
         ControlPath ~/.ssh/sockets/%p-%h-%r

Host della.princeton.edu
         ProxyJump aturing@tigressgateway.princeton.edu
         ControlMaster auto
         ControlPersist yes
         ControlPath ~/.ssh/sockets/%p-%h-%r

Host perseus.princeton.edu
         ProxyJump aturing@tigressgateway.princeton.edu
         ControlMaster auto
         ControlPersist yes
         ControlPath ~/.ssh/sockets/%p-%h-%r

Host adroit.princeton.edu
         ProxyJump aturing@tigressgateway.princeton.edu
         ControlMaster auto
         ControlPersist yes
         ControlPath ~/.ssh/sockets/%p-%h-%r

Host tigressdata.princeton.edu
         ProxyJump aturing@tigressgateway.princeton.edu
         ControlMaster auto
         ControlPersist yes
         ControlPath ~/.ssh/sockets/%p-%h-%r
```
