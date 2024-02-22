# Self-Written Utilities and Pipelines

A utility is a standalone code that performs some operation. A pipeline is set of utilities where the output of one serves as the input to another. In constructing a pipeline to automate your research workflow, you can combine common Linux commands with self-written utilities.

## checkquota revisited

Earlier we created an alias for checkquota. Now let's take a look at the source code:

```
$ cat $(which checkquota)
```

`checkquota` and the standard Linux commands are nothing more than comptuer programs that were written by people. You can write your own commands from scratch to accelerate your research workflow.

## An example of worst practices

Some users will write a data analysis script and place a copy in each directory where it is needed. This leads to unnecessary and problematic duplication. For instance, if the script needs to be changed then all copies must be modified. The correct approach is to store the script in a single location and call it from the different directories while using command-line input parameters to customize the analysis for each directory. This is how the standard Linux commands work. For instance, the `ls` command is stored in `/usr/bin` and it can be called from anywhere. When you want the long listing you include the option `-l` as in `ls -l`. Next, we show how to write your own commands.

## Setup for self-written utilities

To get your own utilities to work like the standard Linux commands, you need to do the following:

+ create a directory to store them
+ give each utility execute permissions
+ update your PATH environment variable so that the utilities are found

### Create a my-utilities directory

```
$ mkdir /projects/<ResearchGroup>/<YourNetID>/my-utilities   # Della, Stellar, Tiger, Traverse
  or
$ mkdir /tigress/<YourNetID>/my-utilities   # Della, Stellar, Tiger, Traverse
  or
$ mkdir /home/<YourNetID>/my-utilities      # if only have account on Adroit
```

Once you have some scripts stored in this directory, you should put the directory under version control using git, for example. Note that you can use another name instead of `my-utilities` such as `bin` or `programs`. We suggest using `/projects` or `/tigress` since those storage systems can be reached from multiple clusters.

### Update PATH

Recall that the `PATH` environment variable specifies a list of directories to search for executables when a command is ran on the command line. To make your utilities callable on the command line add this line to `~/.bashrc`:

```
export PATH=$PATH:/projects/<ResearchGroup>/<YourNetID>/my-utilities   # Della, Stellar, Tiger, Traverse
  or
export PATH=$PATH:/tigress/<YourNetID>/my-utilities   # Della, Stellar, Tiger, Traverse
  or
export PATH=$PATH:/home/<YourNetID>/my-utilities      # if only have account on Adroit
```

Be sure to run `$ source ~/.bashrc` so that the changes to `PATH` take effect (only needed once). Make sure that it worked with:

```
$ echo $PATH
```

You should see the path to your `my-utilities` directory as the last path in the output.

## Your first utility: Generate a custom Slurm script

Below is a utility called `slr` which will generate a custom Slurm script in the current working directory. Follow the directions for either the Python or R version.

### Python source code

```python
#!/usr/licensed/anaconda3/2023.9/bin/python

import argparse
import os

parser = argparse.ArgumentParser()
parser.add_argument('-j', '--job-name', type=str, action='store', dest='jobname',
                    default='myjob', help='Job name')
parser.add_argument('-n', '--ntasks', type=str, action='store', dest='ntasks',
                    default='1', help='Total number of tasks')
parser.add_argument('-t', '--time', type=str, action='store', dest='walltime',
                    default='1', help='Required time (in hours)')
parser.add_argument('-g', '--gpu', type=str, action='store', dest='gpu',
                    default=None, help='GPUs per node')
args = parser.parse_args()

def fmt(directive, value, comment):
    comment_start_col = 34
    spaces = " " * abs(comment_start_col - (len(directive) + len(value) + 12))
    comment = f"# {comment}" if comment else ""
    s = f"#SBATCH --{directive}={value}{spaces}{comment}\n" 
    return s

with open('job.slurm', 'w') as f:
    f.write("#!/bin/bash\n")
    f.write(fmt("job-name", args.jobname, "create a short name for your job"))
    f.write(fmt("nodes", "1", "node count"))
    f.write(fmt("ntasks", args.ntasks, "total number of tasks across all nodes"))
    f.write(fmt("cpus-per-task", "1", "cpu-cores per task (>1 if multi-threaded tasks)"))
    f.write(fmt("mem-per-cpu", "4G", "memory per cpu-core (4G per cpu-core is default)"))
    f.write(fmt("time", f"{args.walltime}:00:00", "total run time limit (HH:MM:SS)"))
    if (args.gpu):
        f.write(fmt("gres", "gpu:" + args.gpu, "number of gpus per node"))
    f.write(fmt("mail-type", "begin", "send email when job begins"))
    f.write(fmt("mail-type", "end", "send email when job ends"))
    f.write(fmt("mail-user", f"{os.environ['USER']}@princeton.edu", ""))
    f.write("\n")
    f.write("module purge\n")
    f.write("module load anaconda3/2020.11\n")
    f.write("conda activate myenv\n")
    f.write("\n")
    f.write("python myscript.py\n")

print("Wrote job.slurm")
```

Use `wget` to get a copy of `slr` in `my-utilities`:

```
$ cd <path/to>/my-utilities/
$ wget https://raw.githubusercontent.com/PrincetonUniversity/removing_tedium/master/07_self_written_utilities/slr-python/slr
$ chmod u+x slr
```

The `chmod` command above makes the script executable by changing the permissions. Now try it out:

```
$ cd ~
$ mkdir test && cd test   # or use mk as defined in 03_aliases_and_shell_functions
$ slr -h
usage: slr [-h] [-j JOBNAME] [-n NTASKS] [-t WALLTIME] [-g GPU]

optional arguments:
  -h, --help            show this help message and exit
  -j JOBNAME, --job-name JOBNAME
                        Job name
  -n NTASKS, --ntasks NTASKS
                        Total number of tasks
  -t WALLTIME, --time WALLTIME
                        Required time (in hours)
  -g GPU, --gpu GPU     GPUs per node
```

Try these options:

```
$ slr -j test -t 72
$ cat job.slurm   # or use jj as defined in 03_aliases_and_shell_functions
$ slr -g 4
$ cat job.slurm
# customize the slr source code for your work using a text editor
```

If you encounter a `Permission denied` error then you probably failed to add execute permission to `slr`. A `command not found` error suggests that the `PATH` was not set correctly.

### R source code

```R
#!/usr/bin/env Rscript
suppressPackageStartupMessages(library("argparse"))

# create parser object
parser <- ArgumentParser()

# specify our desired options
# by default ArgumentParser will add a help option
parser$add_argument("--noGPU", action="store_true", default=TRUE,
    help="Do not write GPU line")
parser$add_argument("-g", "--gpu", action="store_false",
    dest="noGPU", help="Write the GPU line")
parser$add_argument("-t", "--time", type="integer", default=24, 
    help="Number of hours to run", metavar="number")
parser$add_argument("-n", "--ntasks", type="integer", default=1, 
    help="Number of tasks across all nodes", metavar="number")

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults, 
args <- parser$parse_args()

hours <- trimws(toString(args$time))
ntasks <- trimws(toString(args$ntasks))

sink("job.slurm")
cat("#!/bin/bash\n")
cat("#SBATCH --job-name=myjob         # create a short name for your job\n")
cat("#SBATCH --nodes=1                # node count\n")
cat(paste("#SBATCH --ntasks=", ntasks, "               # total number of tasks across all nodes\n", sep=""))
cat("#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multithread tasks)\n")
cat("#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)\n")
if ( !args$noGPU ) { cat("#SBATCH --gpus=gres:1            # number of gpus per node\n") }
cat(paste("#SBATCH --time=", hours, ":00:00          # total run time limit (HH:MM:SS)\n", sep=""))
cat("#SBATCH --mail-type=begin        # send mail when process begins\n")
cat("#SBATCH --mail-type=end          # send email when job ends\n")
cat("#SBATCH --mail-user=<YourNetID>@princeton.edu\n")
cat("\n")
cat("module purge\n")
cat("Rscript myscript.R\n")
sink()
```

Use `wget` to get a copy of `slr` in `my-utilities`:

```
$ cd <path/to>/my-utilities/
$ wget https://raw.githubusercontent.com/PrincetonUniversity/removing_tedium/master/07_self_written_utilities/slr-R/slr
$ chmod u+x slr
```

The `chmod` command above makes the script executable by changing the permissions. Next install the `argparse` package:

```
$ R
> install.packages("argparse")
> q()
```

Now try it out:

```
$ cd ~
$ mkdir test && cd test   # or use mk as defined in 03_aliases_and_shell_functions
$ slr
$ cat job.slurm   # or use jj as defined in 03_aliases_and_shell_functions
$ slr -t 72 -n 4 -g
$ cat job.slurm
# customize the slr source code for your work using a text editor like vim or nano
```

If you encounter a `Permission denied` error then you probably failed to add execute permission to `slr`. A `command not found` error suggests that the `PATH` was not set correctly.

## pycancel is a Python implementation of mycancel

Earlier we learned how to cancel the most recently submitted job using `mycancel`:

```bash
mycancel() { scancel $(squeue -u $USER -o "%i" -S i -h | tail -n 1); }
```

The shell function above is written in Bash. Below is `pycancel` which performs the same function as `mycancel` except it is written in Python which is a language that most people prefer over Bash:

```python
#!/usr/licensed/anaconda3/2023.9/bin/python

import os
import subprocess

netid = os.environ["USER"]
cmd = f"squeue -u {netid} -o \"%i\" -S i -h | tail -n 1"
output = subprocess.run(cmd, capture_output=True, shell=True, timeout=5)
line = output.stdout.decode("utf-8").split('\n')
if line == ['']:
    print("There are no running or pending jobs.")
else:
    jobid = line[0]
    cmd = f"scancel {jobid}"
    _ = subprocess.run(cmd, shell=True, timeout=5)
    print(f"Canceled job {jobid}")
```

Copy the source code above and paste it into a file called `pycancel` in the directory `<path/to>/my-utilities`. Then give it execute permissions:

```
$ chmod 744 pycancel
```

Try it out by submitting a test job:

```
$ sbatch job.slurm   # or the alias sb as defined in 03_aliases_and_shell_functions
$ squeue -u <YourNetID>   # or use sq as defined in 03_aliases_and_shell_functions
$ pycancel
$ squeue -u <YourNetID>
```

We see that the Bash implementation is more concise and maintainable than the Python one.

## cppcancel is a C++ implementation of mycancel

This is kind of a joke but it illustrates a few principles.

```c++
#include <cstdio>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <string>
#include <array>

std::string exec(const char* cmd) {
  // function taken from https://bit.ly/3jrKs4K
  std::array<char, 128> buffer;
  std::string result;
  std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd, "r"), pclose);
  if (!pipe) {
    throw std::runtime_error("popen() failed!");
  }
  while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
    result += buffer.data();
  }
  return result;
}

int main() {
  const char* user = std::getenv("USER");
  std::string netid(user);
  std::string cmd = "squeue -u " + netid + " -o \"%i\" -S i -h | tail -n 1";

  std::string sq = exec(&(cmd[0]));
  if (sq == "")
    std::cout << "There are no running or pending jobs." << std::endl;
  else {
    cmd = "scancel " + sq;
    std::string error = exec(&(cmd[0]));
    std::cout << "Canceled job " + sq;
  }
}
```

After saving the code above in a file called `cppcancel.cpp` in the directory `<path/to>/my-utilities`, compile it with this command:

```
$ g++ -std=c++11 -o cppcancel cppcancel.cpp
```

Then you can call `cppcancel` on the command line. We see that the C++ implementation requires much more coding than what was required by Bash or Python. This example exists to illustrate how compiled codes can be used to make a custom command. In some cases it the extra work of writing a C++ command is worth the effort given the much performance of C++ over Python. Common Linux commands like `ls`, `cd` and `grep` are written in C.

## Bash scripts

The script below is a reduced version of the `shistory` command. You should use `shistory` but the script below nicely illustrates how to write a Bash command:

```bash
#!/bin/bash
#
# This script prints your job history using sacct. One can specify the
# number of days to go back in time and whether or not to show the
# individual job steps.
#
# Example usage:
#
#   $ myjobs
#   $ myjobs -d 14
#   $ myjobs -d 2 -a
#   $ myjobs --days 10 --all

print_help() {
  echo -e "\nNAME"
  echo -e "\tmyjobs - show Slurm job history\n"
  echo -e "USAGE"
  echo -e "\tmyjobs [-d days | -a] [-h]\n"
  echo -e "OPTIONS"
  echo -e "\t-a,--all"
  echo -e "\t\tShow all intermediate job steps"
  echo -e "\t-d,--days"
  echo -e "\t\tShow jobs over this many previous days from now (default: 7)"
}

# defaults
days=7
show_all_steps=false

# parse command-line arguments
while [[ "$#" -gt 0 ]]
do
  case $1 in
    -h|--help)
      print_help
      exit
      ;;
    -d|--days)
      days="$2";
      shift;
      ;;
    -a|--all)
      show_all_steps=true;
      ;;
  esac
  shift
done

startdate=$(date -d"${days} days ago" +%D);
FMT=jobid%12,state,start,elapsed,timelimit,ncpus%5,nnodes%6,reqmem%10,alloctres%50,partition,jobname%8;
if $show_all_steps; then
    sacct -u $USER -S $startdate -o $FMT;
else
    sacct -u $USER -S $startdate -o $FMT -X;
fi
```

To use the Bash script above as a program, run these commands:

```
$ cd <path/to>/my-utilities/
$ wget https://raw.githubusercontent.com/PrincetonUniversity/removing_tedium/master/07_self_written_utilities/bash/myjobs
$ chmod u+x myjobs
```

The `myjobs` command can then be used as:

```
$ myjobs
$ myjobs -d 14
$ myjobs -d 2 -a
$ myjobs --days 10 --all
```

For more on using named command-line arguments with Bash scripts see [this post](https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash) on StackOverflow.

## Pipelines

In Linux, the pipe operator lets you send the output of one command as the input to another as in this example:

```
$ sort records.txt | uniq
```

Piping, as the term suggests, can redirect the standard output, input or error of one command to another for further processing. Here we demostrate how to use pipes with standard Linux commands and your own self-written commands.

The goal here is to identify the number of lines in a data file where the sine of the value is greater than zero. Below are the contents of data.txt:

```
1.0
2.0
3.0
4.0
5.0
6.0
```

Ultimately we want to run this pipeline where `myfilter` is a command that you wrote:

```
$ cat data.txt | myfilter | wc -l
```

Below is the Python code called `myfilter`:

```python
#!/usr/licensed/anaconda3/2023.9/bin/python
import sys
from math import sin
for line in sys.stdin:
    x = float(line.rstrip())
    if sin(x) > 0: print(x)
```

The code above reads from `stdin`, applies the filter and outputs to `stdout`. This is precisely how Linux pipes work.

Place `myfilter` in `<path/to>/my-utilities` and make it executable:

```
$ chmod u+x myfilter
```

Then run the pipeline:

```
$ cat data.txt | myfilter | wc -l
3
```

Note that `myfilter` was written in Python for demonstration purposes here. In practice it would probably be best done in `awk`.

The example above is quite simple but much more can be done. For instance, one could create a pipeline where a stage corresponds to a batch job submitted to the Slurm scheduler.
