#!/bin/bash
#      ___                     ___           ___           ___                       ___     
#     /  /\      ___          /  /\         /  /\         /  /\        ___          /  /\    
#    /  /::\    /  /\        /  /:/        /  /:/_       /  /:/       /  /\        /  /:/_   
#   /  /:/\:\  /  /:/       /  /:/        /  /:/ /\     /  /:/       /  /:/       /  /:/ /\  
#  /  /:/~/:/ /__/::\      /  /:/  ___   /  /:/ /::\   /  /:/  ___  /__/::\      /  /:/ /:/_ 
# /__/:/ /:/  \__\/\:\__  /__/:/  /  /\ /__/:/ /:/\:\ /__/:/  /  /\ \__\/\:\__  /__/:/ /:/ /\
# \  \:\/:/      \  \:\/\ \  \:\ /  /:/ \  \:\/:/~/:/ \  \:\ /  /:/    \  \:\/\ \  \:\/:/ /:/
#  \  \::/        \__\::/  \  \:\  /:/   \  \::/ /:/   \  \:\  /:/      \__\::/  \  \::/ /:/ 
#   \  \:\        /__/:/    \  \:\/:/     \__\/ /:/     \  \:\/:/       /__/:/    \  \:\/:/  
#    \  \:\       \__\/      \  \::/        /__/:/       \  \::/        \__\/      \  \::/   
#     \__\/                   \__\/         \__\/         \__\/                     \__\/    
#
# (c) 2020 Princeton Institute for Computational Science and Engineering
 
# This file contains useful aliases and shell functions for researchers using high-performance
# computing clusters. For details see https://github.com/PrincetonUniversity/removing_tedium

#################
# shell options #
#################
shopt -s histappend  # all shells write to same history
shopt -s checkjobs   # check if background jobs are running on exit
shopt -s cdspell     # guess misspelled cd commands
shopt -s autocd      # change directory w/o cd if entry is invalid
shopt -s extglob     # enable extended glob patterns
#shopt -s expand_aliases

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
cl() { cd "$1" && ll; } # uses alias defined above
alias ..='cd ..'
alias ...='cd ../..'

#######################
# environment modules #
#######################
alias ma='module avail'
alias mp='module purge'
alias ml='echo && module -l list 2>&1 | tail -n +3 && echo'
alias mla='module load anaconda3'
alias mlc='module load cudatoolkit'
alias rh8='module load rh/devtoolset/8'

#########
# conda #
#########
conen() {
  if [ $(module -l list 2>&1 | grep -c anaconda3) -eq 0 ]; then
    echo "Loading anaconda3 module ..."
    module load anaconda3
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

#########
# slurm #
#########
SLURMSCRIPT="job.slurm"
alias sq='squeue -u $USER'
alias sqs='squeue -u $USER --start'
alias wq='watch -n 1 squeue -u $USER'
alias sb='sbatch $SLURMSCRIPT'
alias cpu5='salloc --nodes=1 --ntasks=1 --mem=4G --time=00:05:00'
alias gpu5='salloc --nodes=1 --ntasks=1 --mem=4G --time=00:05:00 --gres=gpu:1'
alias st='slurmtop'
alias fair='echo "Fairshare: " && sshare | cut -c 84- | sort -g | uniq | tail -1'
FRMT="1.1,1.3,1.4,1.5,1.6,1.7,2.3"
alias myprio='join -j 1 -o ${FRMT} <(sqs | sort) <(sprio | sort) | sort -g'
mycancel() { squeue -u $USER -o "%i" -S i -h | tail -n 1); }
maxmem() { snodes | tr -s [:blank:] | cut -d' ' -f7 | sort -g | uniq; }
eff() { seff $(( $(echo $(ls -t slurm-*.out | head -n 1) | tr -dc '0-9' ))); }
goto() { ssh $(squeue -u $USER -o "%i %R" -S i -h | tail -n 1 | cut -d' ' -f2); }
alias sw='sbatch $SLURMSCRIPT && watch -n 1 squeue -u $USER'
lastweek() {
  days=7
  if [ "$#" -eq 1 ]; then
    days=$1
  fi
  seconds=$(($days * 24 * 60 * 60))
  now=$(date +%s)
  minusdays=$((now - $seconds))
  startdate=$(date --date=@$minusdays +'%m/%d')
  FMT=jobid%20,start,end,state,jobname%20,reqtres%40
  sacct -u $USER -S $startdate -o $FMT | egrep -v '[0-9].ext|[0-9].bat|[0-9]\.[0-9] '
}

#######
# gpu #
#######
alias smi='nvidia-smi'
alias wsmi='watch -n 1 nvidia-smi'

######################
# specific to adroit #
######################
if [[ $(hostname) == adroit* ]]; then
  alias gpu5='salloc -N 1 -n 1 -t 5 --gres=gpu:tesla_v100:1'
  alias v100='ssh adroit-h11g1'
fi

#####################
# specific to della #
#####################
if [[ $(hostname) == della* ]]; then
    alias limits='cat /etc/slurm/job_submit.lua | egrep -v "job_desc|--" | awk '"'"'/_MINS/ \
                  {print "  "$1,"<=",$3" mins ("$3/60 " hrs)"}'"'"''
fi

############
# turbovnc #
############
turbostart() {
  module load turbovnc
  if [ $(vncserver -list | wc -l) -eq 4 ]; then
    vncserver
  else
    echo -e "\n***SESSION ALREADY RUNNING***" && vncserver -list
  fi
}
turbostopall() {
  module load turbovnc
  for x in $(vncserver -list); do
    if [[ $x =~ ^: ]]; then
      vncserver -kill $x
    fi
  done
}

########
# misc #
########
alias wthr='/usr/bin/clear && date && curl -s wttr.in/princeton'
alias myos='cat /etc/os-release'
alias wa='watch -n 1'
alias cq='checkquota'
alias htop='htop -u $USER'
alias R='R --vanilla --quiet'
alias has512='lscpu | grep -E --color=always "avx512"'
alias dirsize='du -h --max-depth=1 | sort -h'
alias mypath='readlink -f'

###########
# history #
###########
export HISTSIZE=50000                # lines of history to keep
export HISTFILESIZE=50000            # keep extended history file
export HISTTIMEFORMAT='%F %T '       # show date and time of past commands
PROMPT_COMMAND='history -a'          # append current session to history
alias h8='history 150 | cut -c 28-'  # ignore index and timestamp

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
    perseus)
      echo 
      timeout 5 checkquota | head -n 3
      echo ;;
    tigercpu*)
      echo
      timeout 5 checkquota | head -n 3
      echo ;;
    tigergpu*)
      echo
      timeout 5 checkquota | head -n 3
      echo ;;
    tigressdata*)
      echo
      timeout 5 checkquota | head -n 7
      echo ;;
    traverse*.*)
      echo
      timeout 5 checkquota | head -n 3
      echo ;;
  esac
fi
