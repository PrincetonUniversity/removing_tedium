# Aliases and Shell Functions

While working on the Research Computing clusters you will probably find yourself entering the same commands over and over again. There will also be times when you will run multiple commands to get a result. These two types of actions reduce your productivity and they can be partially eliminated.

Commonly repeated commands should be replaced by an alias, which is a short name for the command. An alias can also combine multiple commands into one. Shell functions are like aliases but they are more flexible because they accept command-line parameters.

This page illustrates how to use aliases and shell functions to improve productivity. While numerous examples are given, for the greatest impact you should create new ones based on your own work.

## First Alias

Let's illustrate the process of creating an alias using this popular command:

```bash
$ squeue --me
```

Instead of typing this every time, we will use the much shorter alias of `sq`:

```bash
$ alias sq='squeue --me'
```

After defining this alias, one can type `sq` instead of the longer `squeue --me`:

```
$ sq
```

*Note that aliases defined on the command line will only be available in the current shell.* To make them permanent see the next section.

## Store your aliases and shell functions in .bashrc

To make your aliases and shell functions available each time you log in, store them in your `~/.bashrc` file. Here is the contents of `~/.bashrc` for a new account:

```bash
$ cat ~/.bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
```

Make your aliases and shell functions permanent by adding them to your `~/.bashrc` file and then sourcing the file. For instance, use a text editor like vim or emacs to add the `sq` alias:

```
$ nano ~/.bashrc  # or vim, emacs, micro, MyAdroit, etc.
```

Add this line:

```bash
# User specific aliases and functions
alias sq='squeue --me'
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

### How to synchronize your .bashrc file across multiple clusters?

Consider creating a GitHub repo containing your `.bashrc` file. Make all of your changes to that file in the repo and then pull it down to different machines. Consider making an alias for the sync:

```
alias sync="wget -O .bashrc https://raw.githubusercontent.com/aturing/shell_configs/refs/heads/main/.bashrc"
```

One can use the `hostname` command and `if` statements to deal with differences between clusters. For an example of this, see the [checkquota](#checkquota) section below.

## Checking which aliases are defined

To see your aliases use the `alias` command:

```bash
$ alias
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l.='ls -d .* --color=auto'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias sq='squeue -u aturing'
alias vi='vim'
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
```

Note that some aliases are automatically created. The above is saying that if we run the `l.` command, for example, the shell is really running `ls -d .* --color=auto`.

## A word of caution

Be sure not to name an alias after an existing command. If your shell is not behaving as expected it may be because you created an alias using the name of a pre-existing command. Try running your proposed alias name on the command line to see if it is already a command before creating a new alias.

Aliases take precedence over commands loaded via modules. This is illustrated below with the `intel` module:

```bash
$ module load intel/19.1.1.217
$ icc
$ module purge
$ alias icc='ps -u $USER'
$ module load intel/19.1.1.217
$ icc
```

If you run the commands above, `icc` will not be the Intel C compiler as one may expect. Be careful of this and put some effort into choosing alias names. When choosing a name for an alias, always make sure that it is not already in use:

```bash
$ cq
-bash: cq: command not found
```

We see that `cq` is not in use so this could be used as an alias for the `checkquota` command:

```bash
alias cq='checkquota'
```

## Viewing your aliases and selectively turning them off

To see the aliases that you are using, run this command:

```
$ alias
```

To turn off a specific alias for the current shell session:

```
$ unalias <alias>
```

To turn off for a single command:

```
$ \<alias>
```

Return to the **Word of caution** section above and try running `\icc` at the very end.

## The home keys system: Working with recent files

On a QWERTY keyboard the home keys are A, S, D, F, J, K, L and the semicolon. Since your fingers typically rest on these keys they make great alias names.

![home_keys](https://upload.wikimedia.org/wikipedia/commons/0/0d/QWERTY-home-keys-position.svg)

Consider the system below based on the home keys:

```bash
export EDITOR=/usr/bin/vim   # or emacs or nano
alias ll='ls -ltrh'
alias jj='cat -- "$(ls -t | head -n 1)"'
alias kk='cat -- "$(ls -t | head -n 2 | tail -n 1)"'
alias ff='$EDITOR -- "$(ls -t | head -n 1)"'
alias dd='$EDITOR -- "$(ls -t | head -n 2 | tail -n 1)"'
```

The `ll` alias lists the files in the current directory in long format and sorts them by modification time with the newest at the bottom.

The `jj` command prints the contents of the newest file in the current working directory to the terminal while `kk` prints out the second newest file. `jj` **is arguably the most useful alias on this entire page. Start using it**! The `ff` command loads the newest file in your specified text editor while `dd` loads the second newest file. The routine use of `ll`, `jj` and `ff` can save you lots of time. Note that `dd` overwrites an existing command but because the original `dd` is obscure, this can be overlooked. If you are left-handed then you may consider transposing the aliases (e.g., interchange `jj` with `ff`).

Note that `aa` and `ss` are waiting to be defined. While `ss` is a pre-existing command, it is obscure and can be overwritten. `gg` and `hh` are also available.

The meaning of `--` in the commands above is explained [here](https://unix.stackexchange.com/questions/510857/what-is-meaning-of-double-hyphen-in-ls-command).

## Navigation (and first shell function)

Here are some shell functions and aliases for creating directories and moving around the filesystem:

```bash
mk() { mkdir -p "$1" && cd "$1"; }
cl() { cd "$1" && ll; } # uses alias defined above
alias ..='cd .. && ll'
alias ...='cd ../.. && ll'
alias pwd='pwd -P'
```

`mk` is the first shell function that we have encountered. The existence of `$1` in the body of the function corresponds to the input paramter. The `&&` operator ensures that the command on the right is only executed if the command on the left is successful. The `mk` function makes a directory and then cd's into that directory:

```bash
$ pwd
/home/aturing
$ mk myproj
$ pwd
/home/aturing/myproj
```

The `cl` function cd's into a specified directory and runs the `ll` alias. The `..` alias above allows us to type 2 keys to go up a level and list the directory contents.

Note that there are many pre-defined functions.

## To see your shell functions

```bash
$ set | less
```

## Environment modules

Do not load environment modules in your `.bashrc` file. We make this recommendation because users forget that they have added these commands. Use aliases instead.

Here are some aliases for quickly working with modules:

```bash
alias ma='module avail'
alias mp='module purge'
alias ml='module list'
alias mla='module load anaconda3/2024.10'
alias mlc='module load cudatoolkit/12.8'
```

One could also use a shell function to load the latest version:

```
mla () 
{ 
    module load $(module avail -l anaconda3 2>&1 | grep anaconda3/202 | tail -n 1 | awk '{print $1}');
    echo && module -l list 2>&1 | tail -n +3 && echo
}
```

Another approach would be to define an alias like this:

```bash
alias modl='module load'
```

Then use it as follows:

```bash
$ modl anaconda3/2023.3
```

## Finding Files

When searching for files, one often wants to do a case-insensitive search while suppressing error messages. The shell function below does this. If only one command-line parameter is specified then it begins the search in the current directory. One can also explicitly specify the path.

```bash
myfind() {
  if [ "$#" -eq 1 ]; then
    find . -iname \*"$1"\* 2>/dev/null
  else
    [ -d "$1" ] && find "$1" -iname \*"$2"\* 2>/dev/null
  fi
}
```

Here is the example usage:

```
$ ssh <YourNetID>@della.princeton.edu
$ myfind /usr/local cublas
```

The above says "find all files in `/usr/local` and its sub-directories that contain the pattern 'cublas' (case insensitive) while suppressing error messages (typically related to file permissions)".


Or equivalently:

```
$ ssh <YourNetID>@della.princeton.edu
$ cd /usr/local
$ myfind cublas
```

## Tensorboard

This function can be added to the shell configuration file (`~/.bashrc` on Linux or `~/.bash_profile` on macOS) on your local machine (e.g., laptop) to create an SSH tunnel for using Tensorboard (see [directions for Tensorboard](https://researchcomputing.princeton.edu/support/knowledge-base/tensorflow#tensorboard)) on della-gpu:

```
board() {
  case "$#" in
    0)
      echo "Missing port. Tunnel not created."
      ;;
    1)
      ssh -N -f -L "$1":127.0.0.1:"$1" ${USER}@della-gpu.princeton.edu
      echo "Created SSH tunnel using port $1"
      ;;
    2)
      ssh -N -f -L "$1":"$2":"$1" ${USER}@della-gpu.princeton.edu
      echo "Created SSH tunnel using port $1 and host $2"
      ;;
    *)
      echo "Too many command-line arguments ("$#"). Tunnel not created."
  esac
}
```

If running Tensorboard on the head node then use:

```
$ board 9100
```

If running on a compute node then use, for example:

```
$ board 9100 della-l09g6
```

Be sure to specify the correct port and host in the commands above for your case. If the username on your local machine (where the board function is defined) is not the same as your Princeton NetID then you will need to replace `${USER}` with your NetID.

## Conda environments

The shell functions and alias below can be used to list your enumerated Conda environments (conen), activate an environment by number (conac), deactivate the current environment (conde) and remove or delete an environment (conrm):

```bash
conen() {
  if [ $(module -l list 2>&1 | grep -c anaconda3) -eq 0 ]; then
    echo "Loading anaconda3 module ..."
    module load anaconda3/2023.3
  fi 
  conda info --envs | grep . | grep -v "#" | cat -n
}

conac() {
  name=$(conda info --envs | grep -v "#" | awk 'NR=="'$1'"' | tr -s ' ' | cut -d' ' -f 1)
  conda activate $name
}

alias conde='conda deactivate'

conrm() {
  name=$(conda info --envs | grep -v "#" | awk 'NR=="'$1'"' | tr -s ' ' | cut -d' ' -f 1)
  conda remove --name $name --all -y -q
  echo; conen; echo
}
```

### conen
Display your enumerated Conda environments (and load the anaconda3 module if necessary). This is similar to `conda env list` which can also be used.

### conac
Activate an environment by number. The `conen` command enumerates your environments. This command is similar to `conda activate <name>`, which can also be used, but it takes a number instead of a name.

### conde
Deactivate the current environment.

### conrm
Remove an environment by the number given by `conen`. This command is similar to `conda remove --name <name> --all` but it works by number instead of name.

### Example

A session using the shortcuts above might look like this:

```bash
[aturing@tigergpu ~]$ conen
Loading anaconda3 module ...
     1  py36                     /home/aturing/.conda/envs/py36
     2	pytools-env              /home/aturing/.conda/envs/pytools-env
     3	tf2-gpu                  /home/aturing/.conda/envs/tf2-gpu
     4	torch-env                /home/aturing/.conda/envs/torch-env
     5	base                  *  /usr/licensed/anaconda3/2023.3
(base) [aturing@tigergpu ~]$ conac 4
(torch-env) [aturing@tigergpu ~]$
(torch-env) [aturing@tigergpu ~]$ conde
(base) [aturing@tigergpu ~]$ conrm 1
# the py36 environment would be deleted
```

Note that aliases do not work in Slurm scripts. You will need to explicitly load your modules in Slurm scripts.

## Slurm

### Submitting batch jobs

If you submit a lot of jobs with commands like `sbatch job.slurm` or `sbatch submit.sh` then you may try calling all your Slurm scripts by the same name (e.g., `job.slurm`) and then introducing this alias:

```bash
SLURMSCRIPT='job.slurm'
alias sb='sbatch $SLURMSCRIPT'
```

Jobs can then be submitted with:

```
$ sb
```

You can distinguish different jobs by setting the job name in the Slurm script:

```bash
#SBATCH --job-name=low-temp      # create a short name for your job
```

The alias below submits the job and then launches `watch`. This allows one to know when short test jobs start running:

```bash
alias sw='sbatch $SLURMSCRIPT && watch -n 1 squeue -u $USER'
```

To exit from `watch` hold down [Ctrl] and press [c].

### Enhancements to squeue

Show the state of your running and pending jobs:

```bash
alias sq='squeue -u $USER'
```

See the expected start times of pending jobs:

```bash
alias sqs='squeue -u $USER --start'
```

Watch your jobs in the queue (useful for knowing when test jobs run):

```bash
alias wq='watch -n 1 squeue -u $USER'
```

This will create an alias which will display the result of the squeue command for a given user and update the output every second. This is very useful for monitoring short test jobs. To exit from `watch` hold down [Ctrl] and press [c].

### Interactive allocations

Use the aliases below to work interactively on a compute node (with and without a GPU) for 5 minutes:

```bash
alias cpu5='salloc --nodes=1 --ntasks=1 --mem=4G --time=00:05:00'
alias gpu5='salloc --nodes=1 --ntasks=1 --mem=4G --time=00:05:00 --gres=gpu:1'
```

Note that you can modify the values of the parameters. For instance, for a 20-minute CPU allocation:

```bash
$ cpu5 -t 20
```

For more on `salloc` see [this page](https://researchcomputing.princeton.edu/slurm).

### ssh to the compute node where your last job is running without specifying the job id

It is often useful to SSH to the compute node where your job is running. From there one can inspect memory usage, thread performance and GPU utilization, for instance. The following function will connect you to the compute node that your most recent job is on:

```bash
goto() { ssh $(squeue -u $USER -o "%i %R" -S i -h | tail -n 1 | cut -d' ' -f2); }
```

The function above uses `squeue` to list all your job id's in ascending order along with the corresponding node where the job is running. It then takes the last row, extracts the node and calls `ssh` on that. This method will not work when multiple nodes are used to run the job.

### Cancel your most recently submitted job without specifying the job id

Running `mycancel` will automatically find the job id of your most recent job and cancel the job:

```bash
mycancel() { scancel $(squeue -u $USER -o "%i" -S i -h | tail -n 1); }
```

The function above uses `squeue` to list all your job id's in ascending order and then it passes the last one to `scancel`. Later in this repo we present implementations of `mycancel` in Python and C++. The implementation above is of course in Bash.

### Who's hogging all the resources?

Your job priority is in part determined by the cluster usage of other members of your Slurm group over the past 30 days. To see usage, run the command below and look at the `RawUsage` column:

```
$ sshare -la -A <your-account>
```

To see the choice(s) for `<your-account>`:

```
$ sshare | grep $USER | awk '{print $1}'
```

One can also use `sreport`. The function below can be used to see usage by user:

```bash
hog() {
  start_date=$(date -d"30 days ago" +%D);
  account=$(sshare | grep $USER | awk '{print $1}' | head -n 1);
  sreport user topusage start=${start_date} end=now TopCount=100 accounts=${account} -t hourper --tres=cpu;
}
```

A small number of users have multiple Slurm accounts. Modifications to the above function may be needed for these users.

### Generate a report on your recent job history

Previoulsy we used a lengthy shell function for this. That function helped many users so now it has been promoted to a system command:

```
$ shistory
```

Give the command above a try. To see the help menu: `$ shistory -h`.

### View Slurm efficiency reports without specifying the job id

If you set `#SBATCH --mail-user` in your Slurm script then you will receive an efficiency report by email. The following command can also be used from the directory containing the slurm output file (e.g., `slurm-3741530.out`):

```bash
eff() { jobstats $(ls -t slurm-*.out | head -n 1 | tr -dc '0-9'); }
```

The `eff` function figures out the job id and runs `jobstats` on that.

### Number of free GPUs

Della ("gpu" partition):
```
alias gpu='shownodes -p gpu | grep della- | grep -v -E "drain|down|boot" | awk '\''{print $6}'\'' | awk -F/ '\''{free+=$1; total+=$2} END {print "Free/Total: " free "/" total}'\'''
```

Della (PLI nodes):
```
alias pli='shownodes -p pli-c | grep della- | grep -v -E "drain|down|boot" | awk '\''{print $6}'\'' | awk -F/ '\''{free+=$1; total+=$2} END {print "Free/Total: " free "/" total}'\'''
```

Tiger:
```
alias gpu='shownodes -p gpu | grep tiger- | grep -v -E "drain|down|boot" | awk '\''{print $6}'\'' | awk -F/ '\''{free+=$1; total+=$2} END {print "Free/Total: " free "/" total}'\'''
```

### Get your fairshare value

Your fairshare value plays a key role in determining your job priority. The more jobs you or members of your Unix group run over the last 30 days, the lower your fairshare value. Fairshare varies between 0 and 1 with 1 corresponding to the largest job priority.

```bash
alias fair='echo "Fairshare: " && sshare | grep $USER | awk '"'"'{print $(NF)}'"'"''
```

To learn more about job priority see [this page](https://researchcomputing.princeton.edu/priority).

## GPU aliases

```bash
alias smi='nvidia-smi'
alias wsmi='watch -n 1 nvidia-smi'
```

After submitting a GPU job it is common to run `goto` followed by `wsmi` on the compute node. This allows one to examine GPU utilization. To exit from `watch` hold down [Ctrl] and press [c].

## Specific to Adroit

```bash
if [[ $(hostname) == adroit* ]]; then
  alias a100='ssh adroit-h11g1'
fi
```

If you have a job running on `adroit-h11g1` then with the alias above you can quickly connect.

## Specific to Della

To get the runtime limits for the different job partitions (QOS) on Della:

```bash
if [[ $(hostname) == della* ]]; then
    alias limits='cat /etc/slurm/job_submit.lua | egrep -v "job_desc|--" | awk '"'"'/_MINS/ \
                  {print "  "$1,"<=",$3" mins ("$3/60 " hrs)"}'"'"''
fi
```

## TurboVNC

While X11 forwarding (via `ssh -X`) is usually sufficient to work with graphics on the HPC clusters, TurboVNC is a faster alternative. See the bottom of [this page](https://researchcomputing.princeton.edu/faq/how-do-i-use-vnc-on-tigre) for shells function to ease the setup.

## checkquota

The `checkquota` command provides information about available storage space and number of files. While it's only 10 characters you may consider reducing it to 2 since it is used a lot:

```bash
alias cq='checkquota'
```

Another tip is to put the following in your `~/.bashrc` or `myshortcuts.sh` file to see your remaining space each time you log in:

```bash
if [ ! -z "$PS1" ]; then
  case $(hostname) in
    adroit?)
      echo 
      timeout 5 checkquota | head -n 3
      echo ;;
    della*.*)
      echo 
      timeout 5 checkquota | head -n 3
      echo ;;
    stellar-intel*)
      echo 
      timeout 5 checkquota | head -n 3
      echo ;;
    tiger*)
      echo
      timeout 5 checkquota | head -n 3
      echo ;;
  esac
fi
```

To learn about interactive shells and `$PS1` see [this page](https://www.gnu.org/software/bash/manual/html_node/Is-this-Shell-Interactive_003f.html). Learn about `.bashrc` and `.bash_profile` [here](https://linuxize.com/post/bashrc-vs-bash-profile/).


To list the size of each directory to know which files to delete to free space:

```bash
alias dirsize='du -h --max-depth=1 | sort -hr'
```

## Weather

Get a weather report for Princeton, NJ (UPDATE: this is sometimes not available due to overuse):

```bash
alias wthr='/usr/bin/clear && date && curl -s wttr.in/princeton'
```

This alias was contributed by T. Comi.

```
$ wthr
Tue Oct  3 14:14:37 EDT 2023
Weather report: princeton

      \   /     Sunny
       .-.      +77(80) °F
    ― (   ) ―   ↘ 2 mph
       `-’      9 mi
      /   \     0.0 in
                                                       ┌─────────────┐
┌──────────────────────────────┬───────────────────────┤  Tue 03 Oct ├───────────────────────┬──────────────────────────────┐
│            Morning           │             Noon      └──────┬──────┘     Evening           │             Night            │
├──────────────────────────────┼──────────────────────────────┼──────────────────────────────┼──────────────────────────────┤
│               Mist           │               Mist           │     \   /     Sunny          │     \   /     Clear          │
│  _ - _ - _ -  55 °F          │  _ - _ - _ -  62 °F          │      .-.      +78(82) °F     │      .-.      68 °F          │
│   _ - _ - _   ↘ 2-3 mph      │   _ - _ - _   ↘ 3 mph        │   ― (   ) ―   ↑ 1-3 mph      │   ― (   ) ―   ↑ 3-6 mph      │
│  _ - _ - _ -  6 mi           │  _ - _ - _ -  6 mi           │      `-’      6 mi           │      `-’      6 mi           │
│               0.0 in | 0%    │               0.0 in | 0%    │     /   \     0.0 in | 0%    │     /   \     0.0 in | 0%    │
└──────────────────────────────┴──────────────────────────────┴──────────────────────────────┴──────────────────────────────┘
                                                       ┌─────────────┐
┌──────────────────────────────┬───────────────────────┤  Wed 04 Oct ├───────────────────────┬──────────────────────────────┐
│            Morning           │             Noon      └──────┬──────┘     Evening           │             Night            │
├──────────────────────────────┼──────────────────────────────┼──────────────────────────────┼──────────────────────────────┤
│               Mist           │     \   /     Sunny          │     \   /     Sunny          │     \   /     Clear          │
│  _ - _ - _ -  57 °F          │      .-.      +78(84) °F     │      .-.      +75(77) °F     │      .-.      64 °F          │
│   _ - _ - _   ↗ 1 mph        │   ― (   ) ―   ↑ 3 mph        │   ― (   ) ―   ↖ 3-8 mph      │   ― (   ) ―   ↖ 6-12 mph     │
│  _ - _ - _ -  6 mi           │      `-’      6 mi           │      `-’      6 mi           │      `-’      6 mi           │
│               0.0 in | 0%    │     /   \     0.0 in | 0%    │     /   \     0.0 in | 0%    │     /   \     0.0 in | 0%    │
└──────────────────────────────┴──────────────────────────────┴──────────────────────────────┴──────────────────────────────┘
                                                       ┌─────────────┐
┌──────────────────────────────┬───────────────────────┤  Thu 05 Oct ├───────────────────────┬──────────────────────────────┐
│            Morning           │             Noon      └──────┬──────┘     Evening           │             Night            │
├──────────────────────────────┼──────────────────────────────┼──────────────────────────────┼──────────────────────────────┤
│     \   /     Sunny          │     \   /     Sunny          │     \   /     Sunny          │     \   /     Clear          │
│      .-.      62 °F          │      .-.      +73(77) °F     │      .-.      69 °F          │      .-.      60 °F          │
│   ― (   ) ―   ↖ 2-3 mph      │   ― (   ) ―   ↖ 4 mph        │   ― (   ) ―   ↖ 7-14 mph     │   ― (   ) ―   ↖ 5-11 mph     │
│      `-’      6 mi           │      `-’      6 mi           │      `-’      6 mi           │      `-’      6 mi           │
│     /   \     0.0 in | 0%    │     /   \     0.0 in | 0%    │     /   \     0.0 in | 0%    │     /   \     0.0 in | 0%    │
└──────────────────────────────┴──────────────────────────────┴──────────────────────────────┴──────────────────────────────┘
Location: Princeton, Mercer County, New Jersey, United States of America [40.3492744,-74.6592957]

Follow @igor_chubin for wttr.in updates
```

## Enhanced commands

Shadowing is the remapping of a command with different parameters:

```bash
alias vi='vim'
alias top='htop'
alias cmake='cmake3'
alias R='R --vanilla --quiet'
alias ccat='/usr/licensed/anaconda3/2023.3/bin/pygmentize'
```

The `ccat` alias is like the `cat` command but with syntax highlighting of Python files and more (e.g., `$ ccat myscript.py`).

## Watch anything

Use this alias to watch anything:

```bash
alias wa='watch -n 1'
```

Use it as follows:

```bash
$ wa nvidia-smi      # monitor GPU utilization  
$ wa ls -l           # if downloading a file
$ wa date            # see a running clock
$ wa squeue --me     # see status of jobs
$ wa free            # monitor free memory
```

## Make Mac more like Linux

Add these aliases to `~/.bash_profile` on your Mac:

```bash
alias wget='curl -O'
alias ldd='otool -L'
```

This will allow you call `wget` as you would on a Linux machine. The `wget` command can be used to download files from the internet.

## Examine your history for commands to be aliased

Try running the following command on your history to look for common commands to create an alias for:

```bash
$ history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n10
```

## More ideas

See [this page](https://www.digitalocean.com/community/tutorials/an-introduction-to-useful-bash-aliases-and-functions) for more aliases and shell functions. To see the aliases used by all users on the cluster, run this command:

```bash
$ find /home -maxdepth 2 -type f -name '.bashrc' 2>/dev/null | xargs grep 'alias' | grep -v 'User specific aliases and functions' | sed 's/^.*\(alias\)/\1/' | sort | uniq | cat -n
```

# History

Your `~/.bash_history` file stores the commands you ran. The settings below increase the number of entries allowed in this file, include a timestamp with each command and combine history from different shells.

```bash
export HISTSIZE=50000                # lines of history to keep
export HISTFILESIZE=50000            # keep extended history file
#export HISTTIMEFORMAT='%F %T '       # show date and time of past commands
PROMPT_COMMAND='history -a'          # append current session to history
```

# Shell options

Enhance your shell with these settings:

```bash
shopt -s histappend  # all shells write to same history
shopt -s checkjobs   # check if background jobs are running on exit
shopt -s cdspell     # guess misspelled cd commands
shopt -s autocd      # change directory w/o cd if entry is invalid
shopt -s extglob     # enable extended glob patterns
```

For all the possible options and their meanings see `man bash`.

With `shopt -s autocd` one can `cd` without typing `cd`:

```bash
$ pwd
/home/aturing
$ ls
myproj file.txt
$ myproj
cd myproj
$ pwd
/home/aturing/myproj
```

With `shopt -s cdspell` one can do:

```bash
$ cd mypoj
myproj
$ pwd
/home/aturing/myproj
```

This enhancement is only somewhat useful since users should be using tab completion.
