# Automated Data Analysis

Many Research Computing users start their day by (1) downloading data from the clusters to their local machine (e.g., laptop), (2) running analysis scripts and then (3) examining the resulting output and figures. This page shows you how to automate the first two of these operations.

## Overview

The idea is to create an alias on your local machine called, e.g., `myplots` which uses ssh to run a script on `tigressdata`:

<center><img src="https://tigress-web.princeton.edu/~jdh4/automatic_data_analysis_tigressweb.png"></center>

Note that the techniques presented here only work if one has followed the previous steps in this workshop to suppress Duo and enable password-less logins.

If you only have an account on Adroit then the procedure described on this page will still work but you will need to run your scripts on Adroit and download the resulting output to your local machine instead of moving it to [tigress-web](https://researchcomputing.princeton.edu/support/knowledge-base/tigress-web).

## Implementation

The first step is to create an alias on your local machine (e.g., laptop) which will use ssh to run a script on tigressdata. On a Mac edit `~/.bash_profile` while on Linux use `~/.bashrc`. Make this alias:

```
alias myplots='ssh aturing@tigressdata "/scratch/gpfs/aturing/scripts/myplots.sh"'
```

Next we create the script on `tigressdata`.

```
$ ssh tigressdata
$ cat /scratch/gpfs/aturing/scripts/myplots.sh
#!/bin/bash
NETID=aturing
JOBNAME=myjob
JOBPATH=/home/$NETID/$JOBNAME
TGR=/tigress/$NETID/public_html/$JOBNAME
PATH=$HOME/software/my-utilities:$PATH

scp $NETID@tiger.princeton.edu:$JOBPATH/fluid.dat .
calc -f fluid.dat --plot   # generates pressure.jpg, temperature.jpg and index.html
scp pressure.jpg temperature.jpg index.html $NETID@tiger.princeton.edu:$JOBPATH
ssh $NETID@tiger.princeton.edu "cd $JOBPATH; mkdir -p $TGR; mv *.jpg index.html $TGR;"

echo "Point your browser to https://tigress-web.princeton.edu/~$NETID/$JOBNAME"
```

Step 3: Point your browser at the webpage

## More details

In this case we will hardcode a specific job directory but you could read in one or more job directories from file or devise a why to generate the job directories of actively running and recently completed jobs. For instance:

```
$ sacct -u aturing -S 12/21 -o jobid,start,workdir%75
```






<center><img src="https://tigress-web.princeton.edu/~jdh4/laptop_clock.png"></center>

## Running scripts just before you start the day using cron

so that when you arrive in the morning the figures will have been generated just a few minutes earlier.


`cron` is a scheduler used to run commands at specific times. It is not available on the cluster head nodes. However, we can use it on our **local machine**. Below shows the format of an entry in `crontab`:

```
* * * * * command
* - minute (0-59)
* - hour (0-23)
* - day of the month (1-31)
* - month (1-12)
* - day of the week (0-6, 0 is Sunday)
command - command to execute
(from left-to-right)
```

Make an entry with `crontab -e`. To view the entries:

```
$ crontab -l
0 9 * * 1-5 cd ~/research/automate && ./auto_single.sh > /dev/null
```

The entry above will run `auto_single.sh` Monday thru Friday at 9 am. If `cron` is not available then consider `at`. One can also simply run the script manually when arriving.

## Pipeline example script

The contents of the Bash script `auto_single.sh` are shown below:

```bash
#!/bin/bash
NETID=aturing
JOBNAME=myjob
JOBPATH=/home/$NETID/$JOBNAME
TGR=/tigress/$NETID/public_html/$JOBNAME
PATH=$HOME/software/my-utilities:$PATH

scp $NETID@tiger.princeton.edu:$JOBPATH/fluid.dat .
calc -f fluid.dat --plot   # generates pressure.jpg, temperature.jpg and index.html
scp pressure.jpg temperature.jpg index.html $NETID@tiger.princeton.edu:$JOBPATH
ssh $NETID@tiger.princeton.edu "cd $JOBPATH; mkdir -p $TGR; mv *.jpg index.html $TGR;"

echo "Point your browser to https://tigress-web.princeton.edu/~$NETID/$JOBNAME"
```

After defining some variables the script downloads data from Tiger. It then runs a self-written utility called `calc` on that data to generate two figures and an HTML page. The figures and HTML page are then uploaded to Tiger where they are moved onto `tigress-web` ([learn more](https://researchcomputing.princeton.edu/tigress-web)). One can then view the figures in a web browser. Keep in mind that `cron`, `auto_single.sh` and `calc` all exist on your local machine (i.e., laptop or workstation).

In this example we focused on a single job but this approach can be extended to multiple jobs. Furthermore, in addition to generating figures, the script could also take actions based on the new data like launching new jobs or canceling queued jobs. And all this would occur before you arrive in the morning.

The `index.html` file is simply this:

```html
<html><head></head><body>
<img src="pressure.jpg"><p>
<img src="temperature.jpg">
</body></html>
```

If you only have an account on Adroit then you will not be able to use `tigress-web`. In this case simply view the generated plots on your local machine.

Mac users can add the following line to `auto_single.sh` to load the web page automatically in Safari:

```
open -a Safari https://tigress-web.princeton.edu/~$NETID/$JOBNAME
```
