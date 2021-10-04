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
$ mkdir /tigress/<YourNetID>/my-utilities   # Della, Stellar, Tiger, Traverse
  or
$ mkdir /home/<YourNetID>/my-utilities      # if only have account on Adroit
```

Once you have some scripts stored in this directory, you should put the directory under version control using git, for example. Note that you can use another name instead of `my-utilities` such as `bin` or `programs`. We suggest using `/tigress` since it can be reached from multiple clusters.

### Update PATH

Recall that the `PATH` environment variable specifies a list of directories to search for executables when a command is ran on the command line. To make your utilities callable on the command line add this line to `~/.bashrc`:

```
export PATH=$PATH:/tigress/<YourNetID>/my-utilities   # Della, Stellar, Tiger, Traverse
  or
export PATH=$PATH:/home/<YourNetID>/my-utilities      # if only gave account on Adroit
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
#!/usr/licensed/anaconda3/2020.11/bin/python

import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-j', '--job-name', type=str, action='store', dest='jobname',
                    default='myjob', help='Job name')
parser.add_argument('-t', '--time', type=str, action='store', dest='walltime',
                    default='48', help='Required time')
parser.add_argument('-g', '--gpu', type=int, action='store', dest='gpu',
                    default=None, help='GPUs per node')
args = parser.parse_args()
name = args.jobname
time = args.walltime
gpu = args.gpu

with open('job.slurm', 'w') as f:
  f.write("#!/bin/bash\n")
  spaces = ''.join([' ' for _ in range(abs(14 - len(name)))])
  f.write("#SBATCH --job-name=" + name + spaces + "# create a short name for your job\n")
  f.write("#SBATCH --nodes=1                # node count\n")
  f.write("#SBATCH --ntasks=1               # total number of tasks across all nodes\n")
  f.write("#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)\n")
  f.write("#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)\n")
  if (gpu):
    f.write("#SBATCH --gres=gpu:" + str(gpu) + "             # number of gpus per node\n")
  f.write("#SBATCH --time=" + time + ":00:00          # total run time limit (HH:MM:SS)\n")
  f.write("#SBATCH --mail-type=begin        # send mail when process begins\n")
  f.write("#SBATCH --mail-type=end          # send email when job ends\n")
  f.write("#SBATCH --mail-user=<YourNetID>@princeton.edu\n")
  f.write("\n")
  f.write("module purge\n")
  f.write("module load anaconda3\n")
  f.write("conda activate myenv\n")
  f.write("\n")
  f.write("python myscript.py\n")
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
$ mk test   # mk is a shell function defined previously
$ slr -h
usage: slr [-h] [-j JOBNAME] [-t WALLTIME] [-g GPU]

optional arguments:
  -h, --help            show this help message and exit
  -j JOBNAME, --job-name JOBNAME
                        Job name
  -t WALLTIME, --time WALLTIME
                        Required time
  -g GPU, --gpu GPU     GPUs per node
```

Try these options:

```
$ slr -j test -t 72
$ jj   # jj is an alias defined previously
$ slr -g 4
$ jj
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
$ module load rh/devtoolset/8  # della or tiger only
$ R
> install.packages("argparse")
> q()
```

Now try it out:

```
$ cd ~
$ mk test   # mk is a shell function defined previously
$ slr
$ jj   # jj is an alias defined previously
$ slr -t 72 -n 4 -g
$ jj
# customize the slr source code for your work using a text editor 
```

If you encounter a `Permission denied` error then you probably failed to add execute permission to `slr`. A `command not found` error suggests that the `PATH` was not set correctly.

## pycancel is a Python implementation of mycancel

Earlier we learned how to cancel the most recently submitted job using `mycancel`:

```bash
mycancel() { scancel $(squeue -u $USER -o "%i" -S i -h | tail -n 1); }
```

The shell function above is written in Bash. Below is `pycancel` which performs the same function as `mycancel` except it is written in Python which is a language that most people prefer over Bash:

```python
#!/usr/licensed/anaconda3/2020.11/bin/python

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
$ sbatch job.slurm  # or the alias sb
$ sq
$ pycancel
$ sq
```

## cppcancel is a C++ implementation of mycancel

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

After saving the code in a file called `cppcancel.cpp` in the directory `<path/to>/my-utilities`, compile it with this command:

```
$ g++ -std=c++11 -o cppcancel cppcancel.cpp
```

Then you can call `cppcancel` on the command line.

## Bash scripts

We encountered the `lastweek` shell function previously. Here we present the same function but in the form of a Bash script that takes named command-line parameters:

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

# defaults
days=7
show_all_steps=false

# parse command-line arguments
while [[ "$#" -gt 0 ]]
do
  case $1 in
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

seconds=$(($days * 24 * 60 * 60));
now=$(date +%s);
minusdays=$((now - $seconds));
startdate=$(date --date=@$minusdays +'%m/%d');
# remove alloctres in next line if you do not use GPUs
FMT=jobid%12,state,start,elapsed,timelimit,ncpus%5,nnodes%6,reqmem%10,alloctres%50,partition,jobname%8;
if $show_all_steps; then
    sacct -u $USER -S $startdate -o $FMT;
else
    sacct -u $USER -S $startdate -o $FMT | egrep -v '[0-9]{4}\.(ex|ba|in)|[0-9]{4}\.[0-9]{1,} ';
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
#!/usr/licensed/anaconda3/2020.11/bin/python
import sys
from math import sin
for line in sys.stdin:
    x = float(line.rstrip())
    if sin(x) > 0: print(x)
```

The code above reads from `stdin`, applies the filter and outputs to `stdout`. This is precisely how Linux pipes are work.

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

The example above is quite simple. One can also create pipelines where a stage corresponds to a batch job submitted to the Slurm scheduler.
