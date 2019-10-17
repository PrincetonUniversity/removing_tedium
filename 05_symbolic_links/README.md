# Symbolic Links

Symbolic links are shortcuts that allow you to quickly reference various paths and move throughout the filesystem.

## Remote scratch

From your home directory you could `cd` to your `/scratch/gpfs` directory with:

```
cd /scratch/gpfs/<NetID>
```

However, with a symbolic link called `grs` you would just type:

```
cd scr
```

One could use an alias instead of a symbolic link but the symbolic link is the better choice because it is more general in that it allows for tab completion so you can easily `cd` into a subdirectory (e.g., `cd /scr/data`).

Here is how to create the link in your home directory:

```
cd
ln --symbolic /scratch/gpfs/<NetID> scr       # Tiger, Della, Perseus, Traverse
ln --symbolic /scratch/network/<NetID> ntwk   # Adroit
```

You can use different names instead of `scr` and `ntwk`. Choose something concise, representative and original (so that it doesn't conflict with an existing command).

Symbolic links can be used for any operation involving a path, for example:

```
$ cd
$ touch file1.txt
$ cp file1.txt scr
$ cd scr
$ pwd
/scratch/gpfs/jdh4
$ ll
-rw-r--r--.  1 jdh4 cses  226 Oct  5 23:50 file1.txt
```

## Tigress

Make a second symbolic link from your home directory to tigress:

```
cd
ln --symbolic /tigress/<NetID> grs   # Tiger, Della, Perseus, Traverse
```

Can you think of another symbolic link that could be used to speed-up your workflow?

*IMPORTANT*: To remove a symbolic link use, for example, `rm grs`. Do not include a trailing slash after the symbolic link name.
