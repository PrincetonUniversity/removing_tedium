#!/bin/bash
 
# This file contains aliases and shell functions for researchers using high-performance
# computing clusters. For details see https://github.com/PrincetonUniversity/removing_tedium

#################
# shell options #
#################
shopt -s histappend  # all shells write to same history
shopt -s checkjobs   # check if background jobs are running on exit
shopt -s cdspell     # guess misspelled cd commands
shopt -s autocd      # change directory w/o cd if entry is a valid directory
shopt -s extglob     # enable extended glob patterns
set -o physical      # cd and pwd will follow physical paths
set -o vi            # press ESC to edit command line with vi

####################
# home keys system #
####################
export EDITOR="/usr/bin/vim"
alias ll='ls -ltrh'                                       # list newest files at bottom
alias jj='cat -- "$(ls -t | head -n 1)"'                  # display newest file
alias kk='cat -- "$(ls -t | head -n 2 | tail -n 1)"'      # display 2nd newest file
alias ff='$EDITOR -- "$(ls -t | head -n 1)"'              # edit newest file
alias dd='$EDITOR -- "$(ls -t | head -n 2 | tail -n 1)"'  # edit 2nd newest file

##############
# navigation #
##############
mk() { mkdir -p "$1" && cd "$1"; }
cl() { cd "$1" && ll; }  # uses alias defined above
alias ..='cd .. && ll'
alias ...='cd ../.. && ll'
alias pwd='pwd -P'  # resolve symlinks

#######################
# environment modules #
#######################
alias ma='module avail'
alias mp='module purge'
alias ml='echo && module -l list 2>&1 | tail -n +3 && echo'
mla() { module load $(module avail -l anaconda3 2>&1 | grep anaconda3/202 | tail -n 1 | awk '{print $1}'); ml; }
mlc() { module load $(module avail -l cudatoolkit/1 2>&1 | grep cudatoolkit | tail -n 1 | awk '{print $1}'); ml; }

#########
# conda #
#########
conen() {
  if [ $(module -l list 2>&1 | grep -c anaconda3) -eq 0 ]; then
    echo "Loading anaconda3 module ..."
    mla
  fi
  conda info --envs | grep . | grep -v "#" | cat -n
}
conac() {
  name=$(conda info --envs | grep . | grep -v "#" | awk 'NR=="'$1'"' | tr -s ' ' | cut -d' ' -f 1)
  conda activate $name
}
alias conde='conda deactivate'
conrm() {
  name=$(conda info --envs | grep . | grep -v "#" | awk 'NR=="'$1'"' | tr -s ' ' | cut -d' ' -f 1)
  conda remove --name $name --all -y -q
  echo; conen; echo
}

#########
# slurm #
#########
SLURMSCRIPT="job.slurm"
alias sq='squeue --me'
alias sqs='squeue --me --start'
alias wq='watch -n 1 squeue --me'
alias sb='sbatch $SLURMSCRIPT'
alias sw='sbatch $SLURMSCRIPT && watch -n 1 squeue --me'
alias cpu5='salloc --nodes=1 --ntasks=1 --mem=4G --time=00:05:00'
alias gpu5='salloc --nodes=1 --ntasks=1 --mem=4G --time=00:05:00 --gres=gpu:1'
alias fair='echo "Fairshare: " && sshare | cut -c 84- | sort -g | uniq | tail -1'
FRMT="1.1,1.3,1.4,1.5,1.6,1.7,2.3"
alias myprio='join -j 1 -o ${FRMT} <(sqs | sort) <(sprio | sort) | sort -g'
mycancel() { scancel $(squeue --me -o "%i" -S i -h | tail -n 1); }
eff() { jobstats $(( $(echo $(ls -t slurm-*.out | head -n 1) | tr -dc '0-9' ))); }
goto() { ssh $(squeue --me -o "%i %R" -S i -h | tail -n 1 | cut -d' ' -f2); }

#######
# gpu #
#######
alias smi='nvidia-smi'
alias wsmi='watch -n 1 nvidia-smi'

#####################
# specific to della #
#####################
if [[ $(hostname) == della* ]]; then
    alias limits='cat /etc/slurm/job_submit.lua | egrep -v "job_desc|--" | awk '"'"'/_MINS/ \
                  {print "  "$1,"<=",$3" mins ("$3/60 " hrs)"}'"'"''
fi

########
# misc #
########
alias wthr='/usr/bin/clear && date && curl -s wttr.in/princeton'
alias myos='cat /etc/os-release'
alias wa='watch -n 1'
alias cq='checkquota'
alias htop='htop -u $USER'
alias R='R --vanilla --quiet'
alias dirsize='du -h --max-depth=1 | sort -h'
alias mypath='readlink -f'
alias ccat='/usr/licensed/anaconda3/2025.6/bin/pygmentize'

###########
# history #
###########
export HISTSIZE=50000                # lines of history to keep
export HISTFILESIZE=50000            # keep extended history file
#export HISTTIMEFORMAT='%F %T '       # show date and time of past commands
PROMPT_COMMAND='history -a'          # append current session to history

######################################
# run checkquota at start of session #
######################################
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
