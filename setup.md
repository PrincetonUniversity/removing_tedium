# Removing the Tedium from Your Research Workflow

## Setup for live workshop

### Point your browser to `https://bit.ly/2IT3q4W`

+ Connect to the eduroam wireless network

+ Install a VPN client on your laptop by following this <a href="https://princeton.service-now.com/snap?id=kb_article&sys_id=ce2a27064f9ca20018ddd48e5210c745" target="_black">OIT KnowledgeBase article</a>

+ For Windows PuTTY users (not PowerShell), to setup passwordless logins, install <a href="https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html" target="_blank">PuTTY gen</a> (puttygen.exe)

+ Connect via VPN (you will need to DUO authenticate)

+ Open a terminal (e.g., Terminal, PowerShell, PuTTY) [<a href="https://researchcomputing.princeton.edu/education/training/hardware-and-software-requirements-picscie-workshops" target="_blank">click here</a> for help]

+ Clone this repo to your local machine: `git clone https://github.com/PrincetonUniversity/removing_tedium`

+ SSH to a Princeton HPC cluster (prefer Tiger, Della, Perseus or Traverse over Adroit) [click [here](https://researchcomputing.princeton.edu/faq/why-cant-i-login-to-a-clu) for help]

+ For the live workshop, to get priority access on Adroit, add this line to your Slurm script: `#SBATCH -p class`
