# Self-Written Utilities and Pipelines

A utility is a standalone code that performs some operation. A pipeline is set of utilities where the output of one serves as the input to another. In constructing a pipeline to automate your research workflow, you can combine common Linux utilities with self-written ones.

## checkquota revisited

Earlier we created an alias for checkquota. Now lets take a look at the source code:

```
$ cat /usr/local/bin/checkquota
```

These commands are not magic. You can write your own from scratch to accelerate your research workflow.

## An example of worst practices

Some users will write a data analysis script and place a copy in each directory where it is needed. This leads to unnecessary duplication. If the script needs to be changed then all copies must be modified. The approach below avoids this.

## Setup for self-written utilities

To get your own utilities to work like the standard Linux commands, you need to do the following:

+ create a directory to store them
+ give each utility execute permissions
+ update your PATH environment variable so that the utilities will be found

### Create a my-utilities directory

```
$ mkdir /tigress/<NetID>/my-utilities   # Tiger, Della, Perseus, Traverse
  or
$ mkdir /home/<NetID>/my-utilities      # if only have account on Adroit
```

Once you have some scripts stored in this directory, you should put the directory under version control using git, for example. Note that you can use another name instead of `my-utilities` such as `bin` or `programs`.

### Update PATH

Recall that the `PATH` environment variable specifies a list of directories to search for executables when a command is ran on the command line. To make your utilities callable on the command line add this line to `~/.bashrc`:

```
export PATH=$PATH:/tigress/<NetID>/my-utilities   # Tiger, Della, Perseus, Traverse
  or
export PATH=$PATH:/home/<NetID>/my-utilities      # if only gave account on Adroit
```

Be sure to run `source ~/.bashrc` so that the changes to `PATH` take effect. Make sure that it worked with:

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
$ module load rh/devtoolset/8
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
