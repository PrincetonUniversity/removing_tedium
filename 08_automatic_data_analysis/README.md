# Automated Data Analysis

Many Research Computing users start their day by (1) downloading data from the clusters to their local machine (e.g., laptop/workstation), (2) running analysis scripts and then (3) examining the resulting output and figures. This page shows you how to automate the first two of these operations.

## Overview

The idea is to create an alias on your local machine called, e.g., `myplots` which uses ssh to run a script on `tigressdata`:

<center><img src="https://tigress-web.princeton.edu/~jdh4/automatic_data_analysis_tigressweb.png"></center>

Note that the techniques presented here only work if one has followed the previous steps in this workshop to suppress Duo and enable password-less logins.

If you only have an account on Adroit then the procedure described on this page will still work but you will need to run your scripts on Adroit and download the resulting output to your local machine instead of moving it to [tigress-web](https://researchcomputing.princeton.edu/support/knowledge-base/tigress-web).

## Implementation

**Step 1: Create an alias your local machine**

The first step is to create an alias on your local machine (e.g., laptop) which will use `ssh` to run a script on tigressdata. To do this, on a Mac edit `~/.bash_profile` while on Linux modify `~/.bashrc`:

```bash
alias myplots='ssh aturing@tigressdata "/scratch/gpfs/aturing/autoscripts/main.sh"'
```

It is assumed that you are suppressing Duo and using SSH keys as described earlier.

**Step 2: Create the main.sh script on tigressdata**

The `main.sh` script is called from your local machine. It calls at least one other script to carry out the analysis of the data. Below is an example:

```bash
$ ssh tigressdata
$ chmod u+x /home/aturing/autoscripts/main.sh  # make the script executable
$ cat /home/aturing/autoscripts/main.sh
#!/bin/bash
NETID=aturing
JOBNAME=myjob
JOBPATH=/della/scratch/gpfs/$NETID/$JOBNAME
WEB=/tigress/$NETID/public_html/$JOBNAME

$HOME/autoscripts/plot_temperature.py $JOBPATH  # make plot and generate HTML page
mv temperature.jpg index.html $WEB

echo "Point your browser to https://tigress-web.princeton.edu/~$NETID/$JOBNAME"
```

Below are the contents of `plot_temperature.py`:

```python
#!/usr/licensed/anaconda3/2020.11/bin/python

import sys
import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
import datetime

mpl.rcParams["figure.figsize"] = (10, 7)
mpl.rcParams["axes.titlesize"] = 20
mpl.rcParams["axes.labelsize"] = 30
mpl.rcParams["xtick.labelsize"] = 24
mpl.rcParams["ytick.labelsize"] = 24

timestamp = datetime.datetime.now()
jobpath = sys.argv[-1]
mytitle = timestamp.strftime("%m/%d/%Y %H:%M:%S") + ' ' + jobpath

array = np.loadtxt(jobpath + "/data.txt")
plt.scatter(array[:, 0], array[:, 1], marker='o', c='b', s=15)
plt.xlim(0, 10)
plt.ylim(0, 10)
plt.xlabel('Time')
plt.ylabel('Temperature')
plt.title(mytitle)
plt.tight_layout()
plt.savefig('temperature.jpg', dpi=96)

with open('index.html', 'w') as f:
  f.write("<html><head></head><body>\n")
  f.write('<img src="temperature.jpg">\n')
  f.write("</body></html>\n")
```

Be sure to make the script executable:

```
$ chmod u+x plot_temperature.py
```

**Step 3: Point your browser at the webpage*

You should be able to see the figure at:

```
https://tigress-web.princeton.edu/~aturing/myjob
```

## More details

In this case we will hardcode a specific job directory but you could read in one or more job directories from file or devise a why to generate the job directories of actively running and recently completed jobs. For instance:

```
$ sacct -u aturing -S 11/23 -o jobid,start,workdir%75
```

In the example the path to the job is hardcoded but you can pass that path as an argument to myplots which would then pass that to main.sh.

Do not abuse tigress-web.

Another approach is to pull down recent data from tigressdata and then run the processing scripts locally on your laptop or workstation.



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
NETID=jdh4
JOBNAME=myjob
JOBPATH=/della/scratch/gpfs/$NETID/$JOBNAME
WEB=/tigress/$NETID/public_html/$JOBNAME

./plot_temperature $JOBPATH  # make plot and generate HTML page
mv temperature.jpg index.html $WEB

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
