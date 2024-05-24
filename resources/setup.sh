#!/QOpenSys/usr/bin/bash
# ------------------------------------------------------------------------- #
# Program       : setup.sh
# Author        : Ravisankar Pandian
# Company       : Programmers.io
# Date Written  : 24/05/2024
# Copyright     : Programmers.io
# ------------------------------------------------------------------------- #

progress_bar() {
    # $1 is the total work
    # $2 is the work done so far
    local total_work=$1
    local work_done=$2
    local progress=$((work_done*20/total_work))  # 20 because 100/5=20
    local filled_part=$(printf "%${progress}s" "")
    local empty_part=$(printf "%$((20-progress))s" "")  # 20 because 100/5=20
    printf "|%s%s| %s%%\r" "${filled_part// /#}" "${empty_part}" "$((work_done*100/total_work))"
}

show_progress(){
  total_work=$1
  echo "doing it at $1 %"
  for i in $(seq 1 $total_work); do
      # Simulate some work with sleep
      sleep 0.005
      progress_bar $total_work $i
  done
  echo ""  # Newline after progress bar

}



# Set bash as the default shell.
/QOpenSys/pkgs/bin/chsh -s /QOpenSys/pkgs/bin/bash $USER
echo "Changed the default shell to bash..."

# create a .profile file in your home folder to store the environment variables.
echo "Setup the environment variables..."
show_progress 5
cd ~
echo "export PATH=/QOpenSys/pkgs/bin:$PATH" >> .profile
echo "export JAVA_HOME=/QOpenSys/QIBM/ProdData/JavaVM/jdk17/64bit" >> .profile
echo "export JENKINS_HOME=/home/$USER/jenkins" >> .profile
echo "export GITBUCKET_HOME=/home/$USER/gitbucket" >> .profile
echo "source ~/.gitprompt.sh" >> .profile

###############-------------- >>> Need to add the PS1 variable change here

# Download the Git Prompt from GitHub
echo "Download the Git Promt from GitHub..."
wget -v https://github.com/ravisankar-PIO/gitonibmi/blob/main/gitprompt.sh -o .gitprompt.sh


# Update and upgrade the YUM
echo "update the yum repository and existing packages..."
yum -v update -y  && yum -v upgrade -y 


# Install GIT
echo "Install GIT..."
yum -v install git -y
git config --global user.name 'Ravisankar Pandian' 
git config --global user.email ravisankar.pandian@programmers.io
ssh-keygen -t ed25519 -C "ravisankar.pandian@programmers.io"

##############################################################################

# Install Jenkins
mkdir ~/jenkinss
echo "Download Jenkins..."
wget -v http://mirrors.jenkins.io/war-stable/latest/jenkins.war -o ~/jenkinss/jenkins.war

# Install Service Commander
echo "Install Service Commander..."
yum -v install service-commander -y
