# Automatic Job Resubmission for Long Jobs

Each cluster imposes a wall clock limit on the running time of a job (e.g., on Tiger it is 6 days). If you need to run a job
for much longer than this time then you should consider using the job dependency technique described below.

To use job dependencies your application must have a way of writing a checkpoint file at the end of each job step and it must be able to figure out which checkpoint file to read at the start of each job step. If your application doesn't meet these two requirements then one can typically write scripts to deal with it.

## Job Dependencies

For the first step, run your job as usual: `$ sbatch job.slurm`. Make sure it finishes before the time limit and make
sure you write a checkpoint file. Then modify your application script to automatically read the checkpoint file at the start of each job step, for example, in pseudocode:

```
// read newest checkpoint file at start
// do work
// write checkpoint file at end
```

Modify the Slurm script by adding this line: `--dependency=singleton`

```
#!/bin/bash
#SBATCH --job-name=MyLongJob     # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --time=72:00:00          # total run time limit (HH:MM:SS)
#SBATCH --dependency=singleton   # job dependency

myprogram <args>
```

The second and additional job steps can then be submitted. The `--job-name` value must be the same for each submission. Each step will wait for the one before it since each is waiting for `MyLongJob` to finish. This is how `singleton` works. The following will produce a total of 5 jobs steps.

```
$ sbatch job.slurm   # step 2
$ sbatch job.slurm   # step 3
$ sbatch job.slurm   # step 4
$ sbatch job.slurm   # step 5
```

Of course, with our previous alias for `sbatch job.slurm` one could equivalently enter `sb` four times. Read more about job dependencies on the [Slurm](https://slurm.schedmd.com/sbatch.html) website.

## Specific example

There is a specific example for LAMMPS [here](https://github.com/jdh4/install_lammps/tree/master/job_chaining).
