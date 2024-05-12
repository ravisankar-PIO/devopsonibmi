<h1 align=center> SFTP on IBMi
</h1>

>Setup IBMi to allow other systems to access it's IFS folder using SFTP

We are going to setup my laptop as SFTP client (which will request for files) and IBMi as the SFTP host (which will contain the files). So in this case, my laptop will be the one that makes a request to download files. 

SFTP means the ability to do FTP without password based authentication. Instead of password we will use the public/private keys. We will give the public key to the host (IBMi) and private key to the client (my laptop).

It is a three Step Process where we need to,
- [Setup IBMi as remote host](#setup-ibmi-as-remote-host)


<p style="font-size:8px"> (No, so we will leave it to blanks) </p> 




## Generate Keys
  
- Login to your IBMi with a profile that has authority to create and manage user profiles. 
<br>  
- Enter command `Call QP2TERM` to enter the PASE Environment 
<br>
- Start by creating the keypairs by entering the command
  `ssh-keygen -t RSA`
  You will be asked for multiple questions for generating the keypairs.
  | Prompt | Response |
  | -- | -- |
  | Enter file in which to save the key |
- We will create separate user profile for this SFTP access. Note that the login is disabled.
  `system "CRTUSRPRF USRPRF(SFTPUSR1) INLMNU(*SIGNOFF)"`
<br>
- Create a HOME directory on the IBM i to store the user's SSH-related files.
  `mkdir /home/sftpusr1`
<br>
- Create a .SSH directory within the user's home directory.
`mkdir /home/sftpusr1/.ssh`
<br>
- Set permissions on the user's home directory.
`chmod 755 /home/sftpusr1`
<br>
- Set permissions on the user's .SSH directory.
`chmod 700 /home/sftpusr1/.ssh`
<br>
- Change ownership of the home directory to the SSH user.
`chown sftpusr1 /home/sftpusr1`
<br>
- Change ownership of the .SSH directory to the SSH user.
`chown sftpusr1 /home/sftpusr1/.ssh`
<br>
- Change the Home directory of the sftpusr1
`system "CHGUSRPRF USRPRF(sftpusr1) HOMEDIR('/home/sftpusr1')"`
<br>
- Rename the public key from id_rsa.pub to authorized_keys and place it in the home directory of SSH user. (Assuming that the public key has been pasted to the /tmp folder)
  `mv /tmp/id_rsa.pub /home/sftpusr1/.ssh/authorized_keys`
<br>
- Change ownership of the authorized_keys file to the SSH user.
`chown sftpusr1 /home/sftpusr1/.ssh/authorized_keys`
<br>
- Set permissions on the authorized_keys file.
`chmod 600 /home/sftpusr1/.ssh/authorized_keys`


**That's it! We've successfully setup the IBMi as SFTP host**

