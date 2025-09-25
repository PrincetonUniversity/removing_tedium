#!/bin/bash
 
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
shopt -s checkwinsize # check window size after each command 
#shopt -s expand_aliases


#############
# apptainer #
#############
if [[ $(hostname) == adroit? ]]; then
    export APPTAINER_CACHEDIR=/scratch/network/jdh4/APPTAINER_CACHE
else
    export APPTAINER_CACHEDIR=/scratch/gpfs/CSES/jdh4/APPTAINER_CACHE
fi
export APPTAINER_TMPDIR=/tmp


#########
# color #
#########
# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac
force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac


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
cs() { cd "$1" && ll; } # uses alias defined above
alias ..='cd .. && ls -ltrh'
alias ...='cd ../.. && ls -ltrh'


#######################
# environment modules #
#######################
alias ma='module avail'
alias mp='module purge'
alias ml='echo && module -l list 2>&1 | tail -n +3 && echo'
mla() { module load $(module avail -l anaconda3 2>&1 | grep anaconda3/202 | tail -n 1 | awk '{print $1}'); ml; }
mlc() { module load $(module avail -l cudatoolkit/1 2>&1 | grep cudatoolkit | tail -n 1 | awk '{print $1}'); ml; }
alias modl='module load'
alias mods='module show'


#########
# conda #
#########
alias ccn='conda create --name'
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
js() { if [ -f ./$SLURMSCRIPT ]; then cat $SLURMSCRIPT; else echo "$SLURMSCRIPT not found"; fi }
alias ssj='scontrol show job'
alias cpu5='salloc --nodes=1 --ntasks=1 --mem=4G --time=00:05:00'
alias gpu5='salloc --nodes=1 --ntasks=1 --mem=4G --time=00:05:00 --gres=gpu:1'
alias fair='echo "Fairshare: " && sshare | cut -c 84- | sort -g | uniq | tail -1'
alias health='sinfo --long --Node'
hog() {
  start_date=$(date -d"30 days ago" +%D);
  account=$(sshare | grep $USER | awk '{print $1}' | head -n 1);
  sreport user top start=${start_date} end=now TopCount=100 accounts=${account} -t hourper --tres=cpu;
}
fmt="1.1,1.3,1.4,1.5,1.6,1.7,2.3"
alias myprio='join -j 1 -o ${fmt} <(sqs | sort) <(sprio | sort) | sort -g'
mycancel() { scancel $(squeue -u $USER -o "%i" -S i -h | tail -n 1); }
maxmem() { snodes | tr -s [:blank:] | cut -d' ' -f7 | sort -g | uniq; }
eff() { jobstats $(( $(echo $(ls -t slurm-*.out | head -n 1) | tr -dc '0-9' ))); }
goto() {
  CNT=$(squeue -u $USER -o "%i %R %T" -S i -h | tail -n 1 | grep RUNNING | wc -l)
  if [ ${CNT} -eq 1 ]; then
    ssh $(squeue --me -o "%i %R" -S i -h | tail -n 1 | cut -d' ' -f2)
  else
    echo "No running jobs. Nowhere to go."
  fi
}

#alias sw='sbatch $SLURMSCRIPT && watch -n 1 squeue -u $USER'
sw() {
  if [ $(grep -c @princeton.edu $SLURMSCRIPT) -ne 0 ]; then
    echo "EMAIL ADDRESS FOUND"
  else
    sbatch $SLURMSCRIPT && watch -n 1 squeue -u $USER
  fi
}
email() {
  if [ -f ./$SLURMSCRIPT ]; then
    sed -i "/mail-type/d;/mail-user/d" $SLURMSCRIPT
  fi
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
  alias gpu80='ssh adroit-h11g1'
  alias abuse='watch -n 1 squeue -R bootcamp1'
fi


########
# misc #
########
alias wthr='/usr/bin/clear && date && curl -s wttr.in/princeton'
# BEGIN reportseff
# pip install --upgrade --target=$HOME/bin/reportseff reportseff
alias rseff='PYTHONPATH=$HOME/bin/reportseff $HOME/bin/reportseff/bin/reportseff --since=d=7 --format jobid%16,user,state%11,start,elapsed%11,timelimit%11,nnodes%6,ncpus%5,reqmem%10,partition,CPUEff,MemEff,GPU -u jdh4'
export LESS="-R"
# END reportseff
alias myos='cat /etc/os-release'
alias wa='watch -n 1'
alias cq='checkquota'
alias checkq='sudo /usr/local/bin/checkquota'
alias pwd='pwd -P'
alias lookfor='rpm -qa | grep -i'
alias htop='htop -u $USER'
alias R='R --vanilla --quiet'
alias has512='lscpu | grep -E --color=always "avx512"'
alias dirsize='du -h --max-depth=1 | sort -h'
alias hpc='git clone https://github.com/PrincetonUniversity/hpc_beginning_workshop \
           && cd hpc_beginning_workshop && ls -ltrh'
alias ccat='/usr/licensed/anaconda3/2020.7/bin/pygmentize'
alias mypath='readlink -f'

demo() { PS1="$ "; }
bashrc() {
  if [ "$#" -eq 0 ]; then
    if [ -f /home/"$USER"/.bashrc ]; then
      cat /home/"$USER"/.bashrc
    fi
  else
    if [ -f /home/"$1"/.bashrc ]; then
      cat /home/"$1"/.bashrc
    fi
  fi
}
notascii() {
  grep --color='auto' -P -n "[^[:ascii:]]" "$1"
}
if [[ $(hostname) == della* ]]; then
    alias limits='cat /etc/slurm/job_submit.lua | egrep -v "job_desc|--" | awk '"'"'/_MINS/ \
                  {print "  "$1,"<=",$3" mins ("$3/60 " hrs)"}'"'"''
    export HF_HOME=/scratch/gpfs/$USER/.cache/huggingface/
fi

alias cores='shownodes | tail -n +2 | grep -v cloud | head -n -1 | awk -F/ '"'"'{print $2}'"'"' | awk -F" " '"'"'{sum+=$1} END{print sum;}'"'"''
alias gpus='shownodes | tail -n +2 | grep -v cloud | awk -F/ "NF==4" | awk '"'"'{print $7}'"'"' | awk -F/ '"'"'{print $2}'"'"' | awk -F" " '"'"'{sum+=$1} END{print sum;}'"'"''

myfind() {
  if [ "$#" -eq 1 ]; then
    find . -iname \*"$1"\* 2>/dev/null
  else
    [ -d "$1" ] && find "$1" -iname \*"$2"\* 2>/dev/null
  fi
}

findperson() {
  if [ $1 = "-h" ] || [ $1 = "--help" ]; then
    echo "$ findperson George Jones"
    echo "$ findperson _ Smith"
    echo "$ findperson John _"
    return
  fi
  if [ $1 = "_" ]; then
    ldapsearch -x -LLL "(&(givenName=*)(sn=$2))"
    return
  fi
  if [ $2 = "_" ]; then
    ldapsearch -x -LLL "(&(givenName=$1)(sn=*))"
    return
  fi
  ldapsearch -x -LLL "(&(givenName=$1)(sn=$2))"
}


###########
# history #
###########
export HISTSIZE=50000                # lines of history to keep
export HISTFILESIZE=50000            # keep extended history file
#export HISTTIMEFORMAT='%F %T '       # show date and time of past commands
PROMPT_COMMAND='history -a'          # append current session to history
alias hh='history 150 | cut -c 28-'  # ignore index and timestamp
alias hh='history 150 | cut -c 8-'


######################################
# run checkquota at start of session #
######################################
if [ ! -z "$PS1" ]; then
  case $(hostname) in
    adroit?)
      echo 
      timeout 5 checkquota | head -n 3
      echo ;;
    della[0-9].*)
      echo 
      timeout 5 checkquota | head -n 3
      echo ;;
    stellar-intel*)
      echo 
      timeout 5 checkquota | head -n 3
      echo ;;
    stellar-amd*)
      echo 
      timeout 5 checkquota | head -n 3
      echo ;;
    tiger*)
      echo
      timeout 5 checkquota | head -n 3
      echo ;;
  esac
fi
