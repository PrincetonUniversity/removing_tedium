# Aliases and Shell Functions

While carrying out computational research you will probably find yourself entering the same commands over and over again. Typing or copying the same command repeatedly reduces your productivity.

You can save yourself time by creating aliases for common commands. Aliases are like custom shortcuts used to represent a command. Shell functions are similar to aliases but they provide more flexibility. Here is a common alias:

```
alias qq='squeue -u <NetID>'
```

After defining this alias, one can type `qq` instead of the much longer `squeue -u <NetID>`.

## Store permanent aliases and shell functions in .bashrc

Here is the contents of `.bashrc` for a new account:

```
$ cat ~/.bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
```

The last line is telling us where to add our custom aliases and shell functions. A new account on Springdale Linux will come with certain aliases. To see your aliases use the `alias` command:

```
$ alias
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l.='ls -d .* --color=auto'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias vi='vim'
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
```

The above is saying that if with run the `l.` command, for example, the shell is really running `ls -d .* --color=auto`. Take a look at the examples below to see how aliases can save you time.

## squeue

Let's illustrate the process of creating an alias using this popular command:

```
$ squeue -u <NetID>
```

In the above command you should replace `<NetID>` with your actual NetID (e.g., ceisgrub). Instead of typing this every time, we will use the much shorter alias of `qq` (or call it `sq` if you prefer). Open your `.bashrc` file using a text editor and add the following line:

```
# User specific aliases and functions
alias qq='squeue -u <NetID>'
```

After saving the file, refresh your shell with the changes in `~/.bashrc` by running this command:

`$ source ~/.bashrc`

*IMPORTANT*: Your new aliases and shell functions will not be active until you run the command above.

Now the `qq` command can be used instead of `squeue -u <NetID>`. To view the expected start times of queued jobs use `alias qqs='squeue -u <NetID> --start'`.

## What if I have access to multiple HPC clusters?

Perseus, Della, Tiger and Traverse all mount the tigress file system. If you have an account on one or more of these clusters it is recommended that you store your aliases and shell functions in a file on tigress and `source` this from each `.bashrc` file on the clusters that you have accounts on.

For example, make the file `/tigress/<NetID>/my_aliases.bash` and put your aliases and functions there. Then add this line to each of your `.bashrc` files:

```
# User specific aliases and functions
source /tigress/<NetID>/my_aliases.bash
```

This approach eliminates redundancy. Changes made to `my_aliases.bash` are propagated to all the clusters that you have access to. Unfortunately, this will not work for Adroit or Nobel since these clusters do not mount tigress.

*Exercise*: SSH to one of the HPC clusters and add the `qq` alias to `~/.bashrc` (Adroit) or `/tigress/<NetID>/my_aliases.bash` (all clusters except Adroit).

## A word of caution

Be sure not to name an alias after an existing command. If your shell is not behaving as expected if may be because you created an alias using the name of a pre-existing command. Try running your proposed alias name on the command line to see if it is already a command before creating a new alias.

Aliases take precedence over commands loaded via modules. This is illustrated below with the `intel` module:

```
$ module load intel
$ icc
$ module purge
$ alias icc='ps -u $USER'
$ module load intel
$ icc
```

If you run the commands above, `icc` will not be the Intel C compiler as one may expect. Be careful of this and put some effort into choosing alias names. Note that in the above session because the alias was not stored in `~/.bashrc` it will expire when the session ends (i.e., the terminal is closed).

## Connecting to a cluster

On your **local machine** (e.g., laptop), add the aliases below for the clusters that you have access to. For Linux see `~/.bashrc` for Mac see `~/.bash_profile`.

```
myid=<NetID>
alias nobel='ssh $myid@nobel.princeton.edu'
alias adroit='ssh $myid@adroit.princeton.edu'
alias perseus='ssh $myid@perseus.princeton.edu'
alias della='ssh $myid@della.princeton.edu'
alias tcpu='ssh $myid@tigercpu.princeton.edu'
alias tgpu='ssh $myid@tigergpu.princeton.edu'
alias tra='ssh $myid@traverse.princeton.edu'

# enable X11 forwarding to use graphics
alias nobelX='ssh -X $myid@nobel.princeton.edu'
alias adroitX='ssh -X $myid@adroit.princeton.edu'
alias perseusX='ssh -X $myid@perseus.princeton.edu'
alias dellaX='ssh -X $myid@della.princeton.edu'
alias tcpuX='ssh -X $myid@tigercpu.princeton.edu'
alias tgpuX='ssh -X $myid@tigergpu.princeton.edu'
alias traX='ssh -X $myid@traverse.princeton.edu'
```

## Watching your jobs in the queue

Watch the list of jobs:

```
alias wq='watch -n 1 squeue -u <NetID>'
```

This will create an alias which will display the result of the squeue command for a given user and update the output every second. This is very useful for monitoring short test jobs. To end the command hold down [Ctrl] and press [c].

## The home keys system: Working with recent files

On a QWERTY keyboard the home keys are A, S, D, F, J, K, L and the semicolon. Since your fingers typically rest on these keys they make great alias names.

![home_keys](https://upload.wikimedia.org/wikipedia/commons/0/0d/QWERTY-home-keys-position.svg)

Most supercomputing sites will provide a default alias for `ll`:

```
alias ll='ls -ltrh'
```

This alias lists the files in the current directory in long format and sorts them by modification time with the newest at the bottom.

Consider the system below based on the home keys:

```
export EDITOR=/usr/bin/vim   # or emacs or nano
alias jj='cat -- "$(ls -t | head -n 1)"'
alias kk='cat -- "$(ls -t | head -n 2 | tail -n 1)"'
alias ff='$EDITOR -- "$(ls -t | head -n 1)"'
alias dd='$EDITOR -- "$(ls -t | head -n 2 | tail -n 1)"'
```

Let's break down each one. The `jj` command prints the contents of the newest file in the current working directory to the terminal while `kk` prints out the second newest file. `jj` **is arguably the most useful alias on this entire page. Start using it**! The `ff` command loads the newest file in your specified text editor while `dd` loads the second newest file. The routine use of `ll`, `jj` and `ff` can save you lots of time. Note that `dd` overwrites an existing command. Because the original `dd` is obscure, this can be overlooked. If you are left-handed then you may consider transposing the aliases.

Note that `aa` and `ss` are waiting to be defined. While `ss` is a pre-existing command, it is obscure and can be overwritten. `gg` and `hh` are also available.

## Common shell functions

Combine make directory and change directory into a single command:

```
mk() { mkdir -p $1 && cd $1; }
```

Example usage:

```
$ pwd
/home/ceisgrub
$ mk myproj
$ pwd
/home/ceisgrub/myproj
```

Combine change directory and list files into a single command:

```
cdl() { cd $1 && ls -ltrh }
```

## Navigating the filesystem

```
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
```

The first alias above allows us to type 2 keys instead of 5 to go up a level.

## Viewing your aliases and selectively turning them off

To see the aliases that you are using run this command:

```
$ alias
```

To turn off a specific alias for the current shell session:

```
$ unalias <alias>
```

Or for a single command:

```
$ \<alias>
```

Return to the **Word of caution** section above and try running `\icc` at the very end.

## sbatch

If you submit a lot of jobs with commands like `sbatch job.slurm` or `sbatch submit.sh`. You may try calling all your Slurm scripts by the same name (e.g., `job.slurm`) and then introducing this alias:

```
SLURMSCRIPT='job.slurm'
alias sb='sbatch $SLURMSCRIPT'
```

You can distinguish different jobs by setting the job name in the Slurm script:

```
#SBATCH --job-name=multivar      # create a short name for your job
```

This alias submits the job then launches watch:

```
alias sw='sbatch $SLURMSCRIPT && watch -n 1 squeue -u $USER'
```

## salloc

For a 5-minute interactive allocation on a CPU or GPU node:

```
alias cpu5='salloc -N 1 -n 1 -t 5'
alias gpu5='salloc -N 1 -n 1 -t 5 --gres=gpu:1'
```

## checkquota

The `checkquota` command provides information about available storage space and number of files. While it's only 10 characters, given its frequent use you may consider reducing it to 2:

```
alias cq='checkquota'
```

Another tip is to put the following in your `~/.bashrc` file to see your remaining space each time you login:

```bash
if [ ! -z "$PS1" ]; then
        checkquota
fi
```

To list the size of each directory:

```
alias dirsize='du -h --max-depth=1 | sort -hr'
```

## Jupyter notebooks

On your laptop:

```
alias jn='jupyter notebook'
```

## Environment modules

Here are three aliases for purging, showing and listing modules:

```
alias mp='module purge'
alias ma='module avail'
alias ml='module list'
```

## Listing, activating and removing Conda environments

Python programmers may benefit from:

```
alias mla='module load anaconda3'
```

If you are a Python user with many Conda environments then the following can be used to print out your environments:

```
alias myenvs='module load anaconda3 && conda info --envs | grep . | grep -v "#" | cat -n'
```

The above alias uses two commands. The `&&` operator ensures that the command on the right is only executed if the command on the left is successful. Can you think of an alias involving the modules you use?

To activate an environment by its number:

```
actenv() { conda activate $(conda info --envs | grep -v "#" | awk 'NR=="'$1'"' | tr -s ' ' | cut -d ' ' -f 1); }
```

A session using the two aliases above might look like this:

```bash
[ceisgrub@tigergpu ~]$ myenvs
     1	tf2-gpu                  /home/jdh4/.conda/envs/tf2-gpu
     2	torch-env                /home/jdh4/.conda/envs/torch-env
     3	base                  *  /usr/licensed/anaconda3/2019.10
[ceisgrub@tigergpu ~]$ actenv 2
(torch-env) [ceisgrub@tigergpu ~]$
```

Note that aliases do not work in Slurm scripts. You will need to explicitly load your modules in these scripts.

Below is a shell function to remove an environment by name (e.g., `$ rmenv torch-env`):

```
rmenv() { conda remove --name "$1" --all; }
```

## CPU and memory efficiency of a completed job

If you set `#SBATCH --mail-user` in your Slurm script then you will receive an efficiency report by email. The following command can also be used from the directory containing the slurm output file (e.g., `slurm-3741530.out`):

```
eff() { seff $(ls -t slurm-*.out | head -n 1 | tr -dc '0-9'); }
```

Note that the Slurm database is purged every so often so your results may not be available. 

## Go to compute node where most recent job is running

It is often useful to SSH to the compute node where you job is running. From there one can inspect memory usage, whether threads are performing properly and examine GPU utilization, for instance. The following function will connect you to the compute node that your most recent job is on:

```
goto() { ssh $(squeue -u $USER | tail -1 | tr -s [:blank:] | cut -d' ' --fields=9); }
```

This method will not work when multiple nodes are used to run the job.

## Canceling the most recently submitted job

```
mycancel() { scancel $(squeue -u $USER | tail -1 | tr -s [:blank:] | cut -d' ' --fields=2); }
```

## A better squeue for pending jobs: Combining squeue with sprio

The following alias combines the output of squeue and sprio to explicitly show your job priority and expected start time for queued jobs:

```
alias pending='join -j 1 -o 1.1,1.3,1.4,1.5,1.6,1.7,2.3 <(squeue -u $USER --start | sort) <(sprio | sort) | sort -g'
```

## Getting your fairshare value

Your fairshare value plays a key role in determining your job priority. The more jobs you or members of your group run in a given period of time the lower your fairshare value. The maximum value is 1.

```
alias fair='echo "Fairshare: " && sshare | cut -c 84- | sort -g | uniq | tail -1'
```

To learn more about job priority see [this post](https://askrc.princeton.edu/question/238/what-determines-my-jobs-priority-under-slurm/).

## Template files

There are often cases where you want a default version of a file. There is where template files can be used. First create a directory for these files:

```
mkdir ~/.template-files
```

Create file in that directory called `job.slurm` with the following contents:

```
#!/bin/bash
#SBATCH --job-name=cxx_serial    # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multithread tasks)
#SBATCH --mem-per-cpu=1G         # memory per cpu-core (4G is default)
#SBATCH --time=00:00:10          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=begin        # send mail when process begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=<YourNetID>@princeton.edu

module purge
module load intel

srun ./hello_world
```

Then create this alias:

```
SLURMSCRIPT='job.slurm'
alias slr='cp -i ~/.template-files/$SLURMSCRIPT . && echo "Wrote job.script"'
```

After sourcing your `.bashrc` file, when you run `slr` it will place a copy of `job.slurm` in the current directory. Can you think of other files that could serve as a template?

If you have accounts of more than one HPC cluster then you should create the `.template-files` directory on tigress. This will allow you to have all these files in one place. Of course, your aliases should also be saved in `my_aliases.bash` in your tigress directory.

You may consider removing write permission on template files with chmod 600.

## TurboVNC

While X11 forwarding (via `ssh -X`) is usually sufficient to work with graphics on the HPC clusters, TurboVNC is a faster alternative. See the bottom of [this page](https://researchcomputing.princeton.edu/faq/how-do-i-use-vnc-on-tigre) for shells function to ease the setup.

## Weather

Get a weather report for Princeton, NJ:

```
alias wthr='/usr/bin/clear && date && curl -s wttr.in/princeton'
```

This alias was contributed by T. Comi.

```
$ wthr
Tuesday, October 08, 2019  12:30:44 PM
Weather report: princeton

               Overcast
      .--.     57 °F          
   .-(    ).   ↓ 8 mph        
  (___.__)__)  9 mi           
               0.0 in         
                                                       ┌─────────────┐                                                       
┌──────────────────────────────┬───────────────────────┤  Tue 08 Oct ├───────────────────────┬──────────────────────────────┐
│            Morning           │             Noon      └──────┬──────┘     Evening           │             Night            │
├──────────────────────────────┼──────────────────────────────┼──────────────────────────────┼──────────────────────────────┤
│               Overcast       │    \  /       Partly cloudy  │    \  /       Partly cloudy  │    \  /       Partly cloudy  │
│      .--.     57..59 °F      │  _ /"".-.     62 °F          │  _ /"".-.     64 °F          │  _ /"".-.     60 °F          │
│   .-(    ).   ↙ 7-10 mph     │    \_(   ).   ↙ 8-10 mph     │    \_(   ).   ↙ 8-11 mph     │    \_(   ).   ↓ 8-13 mph     │
│  (___.__)__)  6 mi           │    /(___(__)  6 mi           │    /(___(__)  6 mi           │    /(___(__)  6 mi           │
│               0.0 in | 0%    │               0.0 in | 0%    │               0.0 in | 0%    │               0.0 in | 0%    │
└──────────────────────────────┴──────────────────────────────┴──────────────────────────────┴──────────────────────────────┘
                                                       ┌─────────────┐                                                       
┌──────────────────────────────┬───────────────────────┤  Wed 09 Oct ├───────────────────────┬──────────────────────────────┐
│            Morning           │             Noon      └──────┬──────┘     Evening           │             Night            │
├──────────────────────────────┼──────────────────────────────┼──────────────────────────────┼──────────────────────────────┤
│      .-.      Light rain     │               Overcast       │               Overcast       │      .-.      Light drizzle  │
│     (   ).    51..55 °F      │      .--.     50..53 °F      │      .--.     50..53 °F      │     (   ).    48..53 °F      │
│    (___(__)   ↙ 11-17 mph    │   .-(    ).   ↙ 11-16 mph    │   .-(    ).   ↓ 11-18 mph    │    (___(__)   ↓ 11-17 mph    │
│     ‘ ‘ ‘ ‘   6 mi           │  (___.__)__)  5 mi           │  (___.__)__)  3 mi           │     ‘ ‘ ‘ ‘   4 mi           │
│    ‘ ‘ ‘ ‘    0.0 in | 27%   │               0.0 in | 54%   │               0.0 in | 57%   │    ‘ ‘ ‘ ‘    0.0 in | 30%   │
└──────────────────────────────┴──────────────────────────────┴──────────────────────────────┴──────────────────────────────┘
                                                       ┌─────────────┐                                                       
┌──────────────────────────────┬───────────────────────┤  Thu 10 Oct ├───────────────────────┬──────────────────────────────┐
│            Morning           │             Noon      └──────┬──────┘     Evening           │             Night            │
├──────────────────────────────┼──────────────────────────────┼──────────────────────────────┼──────────────────────────────┤
│               Overcast       │               Overcast       │               Overcast       │               Overcast       │
│      .--.     50..53 °F      │      .--.     51..55 °F      │      .--.     50..53 °F      │      .--.     48..53 °F      │
│   .-(    ).   ↓ 11-16 mph    │   .-(    ).   ↓ 12-14 mph    │   .-(    ).   ↓ 11-16 mph    │   .-(    ).   ↓ 11-16 mph    │
│  (___.__)__)  6 mi           │  (___.__)__)  6 mi           │  (___.__)__)  6 mi           │  (___.__)__)  6 mi           │
│               0.0 in | 0%    │               0.0 in | 0%    │               0.0 in | 0%    │               0.0 in | 0%    │
└──────────────────────────────┴──────────────────────────────┴──────────────────────────────┴──────────────────────────────┘
Location: Princeton, Mercer County, New Jersey, United States of America [40.3492744,-74.6592957]

Follow @igor_chubin for wttr.in updates
```

## Calling applications and better commands

```
alias myddt='/usr/licensed/bin/ddt'
alias mystata='/usr/licensed/bin/stata-15.0'
alias vi='vim'
alias top='htop'
alias cmake='cmake3'
```

## Watch anything

Use this alias to watch anything:

```
alias wa='watch -n 1'
```

Use it as follows:

```
$ wa free
$ wa date
$ wa squeue -u $USER
```

## Make Mac more like Linux

Add this alias to `~/.bash_profile` on your Mac:

```
alias wget='curl -O'
```

This will allow you call `wget` as you would on a Linux machine. The `wget` command can be used to download files from the internet.

## Checking for AVX-512

```
alias has512='lscpu | grep -E --color=always "avx512"'
```

## Our minimal recommendation

We suggest that Princeton HPC users use the following aliases and shell functions at a minimum:

```
# User specific aliases and functions
export EDITOR=/usr/bin/vim   # or emacs or nano
SLURMSCRIPT='job.slurm'

alias ll='ls -ltrh'
alias sq='squeue -u $USER'
alias wq='watch -n 1 squeue -u $USER'
alias jj='cat -- "$(ls -t | head -n 1)"'
alias kk='cat -- "$(ls -t | head -n 2 | tail -n 1)"'
alias ff='$EDITOR -- "$(ls -t | head -n 1)"'
alias ..='cd ..'
alias myos='cat /etc/os-release'
alias cq='checkquota'
alias sb='sbatch $SLURMSCRIPT'
alias top='htop'

mk() { mkdir -p $1 && cd $1 }
cdl() { cd $1 && ls -ltrh }
```

## Examine your history for commands to be aliased

Try running the following command on your history to look for common commands to create an alias for:

```
history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n10
```

## More ideas

See [this page](https://www.digitalocean.com/community/tutorials/an-introduction-to-useful-bash-aliases-and-functions) for more aliases and shell functions. To see aliases used by other users on the cluster, run this command:

```
find /home -maxdepth 2 -type f -name '.bashrc' 2>/dev/null | xargs grep 'alias' | grep -v 'User specific aliases and functions' | sed 's/^.*\(alias\)/\1/' | sort | uniq | cat -n
```

## How to contribute?

If you create an alias that you think would be useful for the Princeton HPC community then please modify this page and submit a pull request.
