September 24, 2024  

### If you only have an account on Adroit ...

On Adroit, make your aliases and shell functions permanent by adding them to your `~/.bashrc` file and then sourcing the file. For instance, use a text editor like vim or emacs to add the `sq` alias:

```
$ nano ~/.bashrc  # or vim, emacs, micro, MyAdroit, etc.
```

Add this line:

```bash
# User specific aliases and functions
alias sq='squeue -u <YourNetID>'
```

Save the changes and then return to the command line. Make the new alias available in the current shell by "sourcing" your `~/.bashrc` file:

```bash
$ source ~/.bashrc
```

Now try out the alias:

```
$ sq
```

You only need to source your `~/.bashrc` file when you add an alias in the current session. When you first log in all aliases will be available. Once you have built up your `~/.bashrc` file it will contain aliases and shell functions like those in the example [myshortcuts.sh](https://github.com/PrincetonUniversity/removing_tedium/blob/master/03_aliases_and_shell_functions/myshortcuts.sh) file in this repo.

### If you have an account on Della, Stellar, Tiger, Tigressdata and maybe Traverse ...

The large clusters and Tigressdata all mount the  `/projects2` storage system. If you have an account on one or more of these clusters it is recommended that you store your aliases and shell functions in a file on `/projects2` and `source` this from each `~/.bashrc` file for each account. This approach ensures that your shortcuts remain in sync across all of your accounts. Here is the three-step procedure for this:

(Recommended) If you have access to `/projects2`:

![shortcuts](https://tigress-web.princeton.edu/~jdh4/myshortcuts_diagram_projects.png)
<br/><br/>

As explained above, the idea is to make the file `/projects2/<ResearchGroup>/<YourDirectory>/myshortcuts.sh` or `/projects2/<letter>/<YourNetID>/myshortcuts.sh` and put your aliases and functions there. Then add one of the following snippets to each of your `~/.bashrc` files:

```bash
# User specific aliases and functions
if [ -f /projects2/<ResearchGroup>/<YourDirectory>/myshortcuts.sh ] && [ ! -z "$PS1" ]; then
  source /projects/<ResearchGroup>/<YourDirectory>/myshortcuts.sh
fi
```

OR

```bash
# User specific aliases and functions
if [ -f /projects2/<letter>/<YourNetID>/myshortcuts.sh ] && [ ! -z "$PS1" ]; then
  source /projects/<letter>/<YourNetID>/myshortcuts.sh
fi
```


The condition of `[ ! -z "$PS1" ]` disables the shortcuts for non-interactive shells. For instance, if you are using `scp` then you do not want the shortcuts applied so they are turned off.

Unfortunately, this will not work for Adroit or Nobel since those clusters do not mount `/projects2`. You will have to manually update the `~/.bashrc` files for those systems. One way to do this is to scp `myshortcuts.sh` from `/projects2` to those machines.

Once the setup is complete, begin adding aliases and shell functions to `myshortcuts.sh` (see the examples below as well as an [example myshortcuts.sh file](https://github.com/PrincetonUniversity/removing_tedium/blob/master/03_aliases_and_shell_functions/myshortcuts.sh)).

If you make new additions to `myshortcuts.sh` then activate them in the current shell by sourcing your `~/.bashrc` file which will in turn source `myshortcuts.sh`:

```bash
$ source ~/.bashrc
```
