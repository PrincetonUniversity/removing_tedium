# Symbolic Links

Symbolic links allow you to quickly reference various paths and move throughout the filesystem.

## /scratch/gpfs and /scratch/network

From your home directory you could `cd` to your `/scratch/gpfs` directory with:

```
$ cd /scratch/gpfs/<YourNetID>
```

However, with a symbolic link called `scr` you would just type:

```
$ cd scr
```

With `shopt -s autocd` in your `.bashrc` file the `cd` could be omitted: `$ scr` 

Here is how to create the link in your home directory:

```
$ cd ~
$ ln --symbolic /scratch/gpfs/<YourNetID> scr       # Tiger, Della, Stellar
$ ln --symbolic /scratch/network/<YourNetID> scr    # Adroit
```

You can use a different name instead of `scr`. Choose something concise, representative and original (so that it doesn't conflict with an existing command).

Symbolic links can be used for any operation involving a path, for example:

```
$ cd ~
$ touch file1.txt
$ cp file1.txt scr
$ cd scr
$ pwd
/home/aturing/scr
$ pwd -P
/scratch/gpfs/aturing
$ ll
-rw-r--r--.  1 aturing math  226 Oct  5 23:50 file1.txt
```

One could use an alias for `scr` instead of a symbolic link but the symbolic link is in general the better choice. For instance, it allows for tab completion so you can easily `cd` into a subdirectory (e.g., `cd /scr/data`). Symbolic links can also be used in paths when `scp` is used to transfer files. One advantage of the alias is that is could be ran from any working directory. 

Consider adding the alias below so that symbolic links are always resolved (i.e., `pwd` gives `/scratch/gpfs/aturing` instead of `/home/aturing/scr` in the example above):

```
alias pwd='pwd -P'
```

## /projects (large clusters only, i.e., not adroit)

Make a second symbolic link from your home directory to `/projects`:

```
$ cd ~
$ ln --symbolic /projects/<letter>/<YourNetID> prj   # Della, Stellar, Tiger
```

Can you think of another symbolic link that could be used to speed-up your workflow? Maybe a link to the directory containing your current project.

## How to remove a symbolic link

*IMPORTANT*: To remove a symbolic link use, for example, `$ rm prj`. Do not include a trailing slash after the symbolic link name.

## Using an Alias

If you need a way to get to a specific directory from anywhere then it is best to use an alias. For example, to get to "my_project", one could use:

```
alias myproj='cd /scratch/gpfs/aturing/my_project'
```

The above works from anywhere. With the symbolic link approach, one must either be in the directory that contains the link or specifiy the path to the link.

## Dealing with Large Directories in /home

Symbolic links are useful for dealing with `.conda` and `.cache` directories. See [this example](https://researchcomputing.princeton.edu/support/knowledge-base/checkquota#How-should-I-deal-with-large-Conda-environments-) on the Research Computing webpage.
