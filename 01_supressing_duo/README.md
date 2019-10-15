# Suppressing DUO

DUO enhances security. It can also be annoying and disruptive. Here are two approaches to suppressing DUO. We recommend using the first approach below due to its simplicity.

## The VPN approach

Install a VPN client. Connect via the VPN client. Start you work. You will only need to DUO authenticate once per session.

To install a VPN client on your laptop follow this [OIT KnowledgeBase article](https://princeton.service-now.com/snap?id=kb_article&sys_id=ce2a27064f9ca20018ddd48e5210c745) (see "How to configure a Secure Remote Access (SRA) connection" near the bottom).

> Secure Remote Access (SRA) is a service for Princeton faculty, staff, and students who are off-campus and need to access restricted campus resources through a Virtual Private Network (VPN). After authenticating, remote computers function as if they were on campus, and as long as your SRA connection is active, all Internet activity from your computer is routed through Princeton servers and your computer is giving a Princeton IP address.

#### What if VPN is too slow from off-campus?

It is true that a VPN may reduce your transfer speeds. If this is the case then do not use it. Instead, ssh to `tigressgateway.princeton.edu` and then from 
there, ssh to your desired cluster. If you are transferring many files you will want to use multiplexing to avoid DUO authentication as described below.

## The multiplexing approach

The following solution is from Bill Wichser of Research Computing. It is reproduced here from [this post](https://askrc.princeton.edu/question/331/how-do-i-avoid-having-to-authenticate-with-duo-every-time/).

Q: *How do I avoid having to authenticate with DUO every time?*

A: Yes this is painful! But there are a few things one can do. I will explain one approach using ssh multiplexing which uses a single ssh connection and channels all communication over that channel. This means that only once will you need to DUO authenticate.

But do be aware of why DUO is being used in the first place. It is to protect our systems. As a member or affiliate of Princeton University, you are a part of that "our systems" group. The reason I mention this is because you do have options with the method I am going to provide with respect to time limits on how long the multiplexed functionality remains operational. Set too low and the next ssh/scp will require DUO authentication again. But set too high, protection could be bypassed which makes us all vulnerable.

To make this work, on your Linux or macOS machine, edit the file `~/.ssh/config` and add a machine stanza which looks like this:

```
Host mcmillan
        HostName mcmillan.princeton.edu
        ControlPath ~/.ssh/controlmasters/%r@%h:%p
        ControlMaster auto
        ControlPersist 10m
```        

Then do a `mkdir ~/.ssh/controlmasters` to create the directory for telling ssh how to use this multiplexed session.

The very first login to mcmillan would now start the multiplexing option.

```
ssh mcmillan
```

It will DUO authenticate. But any other sessions will now use that connection and not require it. The multiplexer remains active for ControlPersist time, as defined in your `~/.ssh/config` file, for the time limit once the last ssh session has terminated.

Some handy commands from your desktop:

```
ssh -O check mcmillan    -- this checks whether a multiplexed session is already open
ssh -O stop mcmillan     -- kills the multiplexed session
```

As if that wasn't enough information, there is yet another option which can use a proxy server. See `man ssh_config` in the section for ProxyJump. In your local .ssh/config you'll continue using the multiplexer as stated above but with a different config. You'll need to do a `mkdir ~/.ssh/sockets` in order to use this approach.

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

From my local machine I can `ssh perseus` which says to use the proxyjump server called tigressgateway. It first goes to tigressgateway, Duo authenticates, then hops to perseus. In the process it sets up some port forwarding for the given ports in case you require VNC access or other processes to tunnel through.

You should be able to `scp localfile bill@perseus.princeton.edu` without incurring extra Duo authentications since the connection is established and multiplexed.
