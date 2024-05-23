# bash/zsh git prompt support

# Set bash as the default shell.
/QOpenSys/pkgs/bin/chsh -s /QOpenSys/pkgs/bin/bash $USER

# create a .profile file in your home folder to store the environment variables.
cd ~
touch .profile
echo "export PATH=/QOpenSys/pkgs/bin:$PATH" >> .profile
echo "export JAVA_HOME=/QOpenSys/QIBM/ProdData/JavaVM/jdk17/64bit" >> .profile
echo "export JENKINS_HOME=/home/$USER/jenkins" >> .profile
echo "export GITBUCKET_HOME=/home/$USER/gitbucket" >> .profile
echo "source ~/.gitprompt.sh" >> .profile

###############-------------- >>> Need to add the PS1 variable change here

# Download the Git Prompt from GitHub
wget https://github.com/ravisankar-PIO/gitonibmi/blob/main/gitprompt.sh -o .gitprompt.sh


# Update and upgrade the YUM
yum update -y && yum upgrade -y


# Install GIT
yum install git -y
git config --global user.name 'Ravisankar Pandian' 
git config --global user.email ravisankar.pandian@programmers.io
ssh-keygen -t ed25519 -C "ravisankar.pandian@programmers.io"

##############################################################################

# Install Jenkins
mkdir ~/jenkins
wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war -o ~/jenkins/jenkins.war

# Install Service Commander
yum install service-commander -y
