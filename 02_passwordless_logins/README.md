# SSH login without password

To login to an HPC cluster without entering a password, you will first create public and private "keys" on your **local machine** (e.g., laptop). These keys are nothing more than files. The public key will then be appended to `~/.ssh/authorized_keys` on the desired cluster while the private key remains on your local machine. When you try to connect to that cluster if the public and private keys match then you will be granted access without needing to type your password. The private key is equivalent to your password so you should never share it.

 <p align="center"><img src="http://itdoc.hitachi.co.jp/manuals/3021/3021335010e/GRAPHICS/ZU020130.GIF" align="center"></p>

## Linux and Mac

### Step 1: Create the private/public key pair

On your **local machine** (e.g., laptop), first create the RSA key pair. This is done with the following command (press the "Enter" key 3 times after running the command below, i.e., do not answer any of the questions):

```
$ ssh-keygen -t rsa
 [Enter] 
 [Enter] 
 [Enter] 
```

Here is an example:

```
[jdh4@notexa ~]$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/home/jdh4/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/jdh4/.ssh/id_rsa.
Your public key has been saved in /home/jdh4/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:WAmli4zRUQGWhIHkT4oXi1CjwNJd3KYKNe5OK8DpcZY jdh4@notexa.princeton.edu
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

The public key is now located in `~/.ssh/id_rsa.pub`. The private key (identification) is located in `~/.ssh/id_rsa`. Keep your private key private. Do not share it. However, you can share your public key and we will do that next.

### Step 2: Copy the public key to the HPC cluster

Copy the public key to the server's `authorized_keys` file (enter your password for the **HPC cluster** when prompted):

```
$ ssh-copy-id <YourNetID>@<hpc_cluster>.princeton.edu
# answer "yes"
# enter password and DUO authenticate
```

Here is an example session:

```
[jdh4@notexa ~]$ ssh-copy-id jdh4@tiger.princeton.edu
The authenticity of host 'tiger.princeton.edu (128.112.172.210)' can't be established.
ECDSA key fingerprint is SHA256:Hc3x7Tfs3ULz49U2jmpxzOGNwm2p8mkUnZVs8X1X7g8.
ECDSA key fingerprint is MD5:15:47:21:af:6c:ac:5e:e7:88:d5:de:73:d5:ea:c4:9f.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are ...
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to ...
Password: 
Duo two-factor login for jdh4

Enter a passcode or select one of the following options:

 1. Phone call to XXX-XXX-5201
 2. SMS passcodes to XXX-XXX-5201 (next code starts with: 2)

Passcode or option (1-2): 1

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'jdh4@tiger.princeton.edu'"
and check to make sure that only the key(s) you wanted were added.
```

### Step 3: Connect to the HPC cluster

Try to ssh to the cluster. You should no longer need to enter a password.

If you encounter the error `Bad owner or permissions on ~/.ssh/config` then try doing `chmod 600 ~/.ssh/config` and maybe also `chown $USER ~/.ssh/config`.

### Step 4: Return to step 2 for additional HPC clusters

Return to step 2 and copy the public key using `ssh-copy-id` to each cluster that you have an account on. Try connecting to that cluster as a test.

### Trouble with tigressdata

If the procedure above fails on tigressdata (i.e., you still have to enter your password) then ssh to tigressdata and run this command:

```
$ restorecon -R ~/.ssh
```

Exit from tigressdata, and the next time you connect you should not need your password.

## Windows with PowerShell

Follow [these directions](https://www.techrepublic.com/blog/10-things/how-to-generate-ssh-keys-in-openssh-for-windows-10/) to create the keys but don't follow the "Copying the public key securely" procedure. If your public key is on your laptop in `~/.ssh/id_rsa.pub` then the following can be used to copy it to the desired HPC cluster:

```
$ cat ~/.ssh/id_rsa.pub | ssh <YourNetID>@<HPC-Cluster>.princeton.edu "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >>  ~/.ssh/authorized_keys"
```

## Windows for PuTTY users

Install [PuTTY gen](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) (puttygen.exe).

[Watch this video](https://youtu.be/2nkAQ9M6ZF8) but at 2:27 do not enter a passphrase and stop watching the video around 5:22.

## Looking ahead

Once you have setup passwordless logins, you can run commands on a cluster without formally connecting. The command below will create a file on Della using the touch command:

```
# on your laptop
$ ssh aturing@della.princeton.edu "touch myfile"
```

Note that you can also use the approach above to run scripts on the HPC cluster without formally connecting. For instance, when you start the day, you could run a single command on your laptop that would trigger an analysis script on, say, Della. If the script generated webpages then the output could be viewed on `https://tigress-web.princeton.edu/~<YourNetID>/`.
