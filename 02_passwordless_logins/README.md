# SSH login without password

When connecting to an HPC cluster via `ssh` or transferring a file via `scp`, one needs to enter a password. This page explains how to use SSH keys to handle the authentication step so that logins and file transfers can happen without entering a password.

As indicated in the figure below, the first step is to create private and public "keys" on your **local machine** (e.g., laptop). These keys are nothing more than files. The public key is then appended to `~/.ssh/authorized_keys` on the desired cluster while the private key remains on your local machine. When you try to connect to that cluster, if the public and private keys match then you will be granted access without needing to provide your password.

 <p align="center"><img src="https://tigress-web.princeton.edu/~jdh4/ssh_keys_princeton_research_computing.png" align="center"></p>

## Linux and Mac

### Step 1: Create the private/public key pair

On your **local machine** (e.g., laptop), first create the RSA key pair. This is done by running the following command in a terminal (press the "Enter" key 3 times after running the command below, i.e., do not answer any of the questions):

```
$ ssh-keygen -t rsa
 [Enter] 
 [Enter] 
 [Enter] 
```

Here is an example:

```
[aturing@mylaptop ~]$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/home/aturing/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/aturing/.ssh/id_rsa.
Your public key has been saved in /home/aturing/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:WAmli4zRUQGWhIHkT4oXi1CjwNJd3KYKNe5OK8DpcZY aturing@mylaptop
The key's randomart image is:
+---[RSA 2048]----+
|+++==*=+.        |
|=+o+=..oo.       |
|+.o+...oo        |
|o.=*...+         |
|+.=++.o S        |
|.= E+            |
|..+o .           |
| .. o            |
|   .             |
+----[SHA256]-----+
```

The public key is now located in `~/.ssh/id_rsa.pub`. The private key (identification) is located in `~/.ssh/id_rsa`. **The private key is equivalent to your password so you should never share it.** However, you can share your public key and we will do that next.

### Step 2: Copy the public key to the HPC cluster

Use the `ssh-copy-id` command to copy the public key to the desired cluster (enter your password for the **HPC cluster** when prompted):

```
$ ssh-copy-id <YourNetID>@<cluster-name>.princeton.edu
# answer "yes" when asked "Are you sure you want to continue connecting (yes/no)?"
# enter your password and Duo authenticate (you may not need to Duo authenticate if you established a multiplexed session previously)
```

Note that the `ssh-copy-id` command will only transfer your public key. Your private key will remain safe on your local machine in `~/.ssh/id_rsa`.

Here is an example session:

```
[aturing@mylaptop ~]$ ssh-copy-id aturing@adroit.princeton.edu
The authenticity of host 'adroit.princeton.edu (128.112.172.210)' can't be established.
ECDSA key fingerprint is SHA256:Hc3x7Tfs3ULz49U2jmpxzOGNwm2p8mkUnZVs8X1X7g8.
ECDSA key fingerprint is MD5:15:47:21:af:6c:ac:5e:e7:88:d5:de:73:d5:ea:c4:9f.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are ...
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to ...
Password: 
Duo two-factor login for aturing

Enter a passcode or select one of the following options:

 1. Phone call to XXX-XXX-5201
 2. SMS passcodes to XXX-XXX-5201 (next code starts with: 2)

Passcode or option (1-2): 1

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'aturing@adroit.princeton.edu'"
and check to make sure that only the key(s) you wanted were added.
```

### Step 3: Connect to the HPC cluster

Try to `ssh` to the cluster (you should no longer need to enter a password):

```
$ ssh aturing@adroit.princeton.edu
```

Or if you worked through Section 1 of this repo then you should be able to use the much shorter:

```
$ ssh adroit
```

If you encounter the error `Bad owner or permissions on ~/.ssh/config` then try doing `chmod 600 ~/.ssh/config` and maybe also `chown $USER ~/.ssh/config`.

### Step 4: Return to Step 2 for additional HPC clusters

Return to Step 2 and copy the public key using `ssh-copy-id` to each cluster that you have an account on. Try connecting to that cluster as a test.

### Trouble with tigressdata

If the procedure above fails on tigressdata (i.e., you still have to enter your password) then ssh to tigressdata and run this command:

```
$ restorecon -R ~/.ssh
```

Exit from tigressdata, and the next time you connect you should not need your password.

## Windows

### Windows with PowerShell

Follow [these directions](https://www.techrepublic.com/blog/10-things/how-to-generate-ssh-keys-in-openssh-for-windows-10/) to create the keys but don't follow the "Copying the public key securely" procedure. If your public key is on your laptop in `C:\Users\aturing\.ssh\id_rsa.pub` then the following can be used to copy it to the desired HPC cluster:

```
$ cat C:\Users\aturing\.ssh\id_rsa.pub | ssh <YourNetID>@<HPC-Cluster>.princeton.edu "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >>  ~/.ssh/authorized_keys"
```

Below is specific example:

```
$ cat C:\Users\aturing\.ssh\id_rsa.pub | ssh aturing@adroit.princeton.edu "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >>  ~/.ssh/authorized_keys"
```

### Windows with MobaXterm

This [set of directions](https://vlaams-supercomputing-centrum-vscdocumentation.readthedocs-hosted.com/en/latest/access/generating_keys_with_mobaxterm.html) may be useful.


### Windows for PuTTY users

Install [PuTTY gen](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) (puttygen.exe).

[Watch this video](https://youtu.be/2nkAQ9M6ZF8) but at 2:27 do not enter a passphrase and stop watching the video around 5:22.

## Looking ahead

Once you have setup passwordless logins, you can run commands on a cluster without formally connecting. For example, the command below will create an empty file with the name `myfile` in your `/home` directory on Della:

```
# on your laptop
$ ssh aturing@della.princeton.edu "touch myfile"
```

Note that you can also use the approach above to run scripts on an HPC cluster. For instance, when you start the day, you could run a single command on your laptop that would trigger an analysis script to run. If the script generates figures and webpages as the output then that content could be viewed on `https://tigress-web.princeton.edu/~<YourNetID>/` (learn more about [tigress-web](https://researchcomputing.princeton.edu/support/knowledge-base/tigress-web)).

If you have access to the `/tigress` storage system then you can share webpages:

```
$ mkdir -p /tigress/<YourNetID>/public_html
$ cd /tigress/<YourNetID>/public_html
$ cat index.html
<html><head></head><body>
test
</body></html>
```

Note that whatever you place in your `public_html` directory will be on the internet. Also, the contents of that directory are backed-up so don't put thousands of files in it or large files unless you need to. More on this later.
