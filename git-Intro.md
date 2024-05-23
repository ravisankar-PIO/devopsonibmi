- [Installation](#installation)
- [Settings](#settings)
  - [System Level](#system-level)
  - [Global Level](#global-level)
  - [Local Level](#local-level)
- [Usage](#usage)
  - [Cheat Sheet](#cheat-sheet)
  - [Visual helper](#visual-helper)


# Installation
1. Install GIT to your desktop.
2. Navigate to a folder, right click and select Open Git Bash here
   ![alt text](images/gitbash.png)

# Settings
Let's talk about `git config` settings. 
## System Level 
Settings are applied for all users

## Global Level
Settings are applied for all the Repos of current user
```bash
git config --global user.name 'Ravisankar Pandian' #To add a user name for the git application.

git config --global user.email ravi@ravi.com #To add email for the git application 

git config --global core.editor "code --wait" #to setup the default editor as vscode. the --wait flag is to keep the window open until we close it

git config --global -e # will open the config file for us to edit

 git config --global init.defaultBranch main # set the defaultBranch to Main
```


Let's talk about CRLF
![alt text](images/crlf.png)
* Windows set the EOL (end of line) as CR LF (Carriage Return Line Feed)
* Mac/Linux set the EOL as LF (only Line Feed)
So it is important to setup the EOL characters correctly when working with different OSes. 
The thumb rule is to set `true` for Windows and `input` for Mac/Linux
```bash
git config --global core.autocrlf input # for Mac/Linux
git config --global core.autocrlf true # for Windows
```
## Local Level
Settings are applied only for the current Repository


# Usage
|Command|Description|
|-|-|
`git init`            | To initialize a repository <br> Then add files/folders to the workspace to edit them
`git add <filename>`  | To add the modified/new files to the staging area <br> If you remove any file, then you need to `git add <removed_file>` in order to stage that change.


```bash
# to add all the files to the staging area
  git add . 
# This will automatically recognize the deleted file.

# to show the status of our push/commit/staged changes
  git status 

git commit # to commit the staged files for change
git commit -m 'commit message' # to commit along with a short commit message
git push # to push the committed files to the remote branch
git config --global user.name 'Ravisankar Pandian' # to add name for the github?
git config --global user.email 'ravi@ravi.com' # to add email for the github?
git log --graph --decorate --oneline # to display the git structure
git reset --hard HEAD~1 # to undo the last done commit
git reset --soft HEAD~1 # ????
git reset HEAD~1 # to undo the last commit and set -1 position back
git revert HEAD # to plop another commit(C3) after the current commit(C2), but this C3 will be a replica of C1
git branch bugfix # to create a new branch called bugfix
git branch bugWork c7^^2^ # one step up from C7, go to second parent in merge commit, then one step up, then create a branch called bugWork
git branch -f bugfix HEAD~1 # move the current branch to a position -1 from HEAD
git branch -f bugFix c4
git checkout bugfix # to move the HEAD to the bugfix branch
git checkout -b bugfix # combines the above two steps into one
git checkout HEAD~2 # move up 2 generations
git checkout HEAD^ # move to the first parent in a merge commit
git checkout HEAD^2 # move to the second parent in a merge commit
git cherry_pick c1 c2 c3 # cherry pick the commit to append to the current HEAD position
git rebase c1 # Drops the current branch and appends to the C1 in a linear way.
git rebase c1 c5 # Takes the independent parent branches of C1 and appends it to the C5
git rebase -i HEAD~1 # interactively select, omit, rearrange the commits to rebase.
git tag t1 c1 # adds a tag t1 to the commit c1. Once added, we can use tags and commits interchangeably
git describe <branch> # shows the nearest anchor tag above, how many commits is current head is ahead of it, and the current head's hash.
```
## Cheat Sheet
Click [here](resources/git.pdf) to view the cheat sheet for git commands.

## Visual helper
A good git visual tool that can be used to learn the branching and pushing in Git. Click this [link](https://git-school.github.io/visualizing-git/#free-remote)

Learn git branching via visual game [here](https://learngitbranching.js.org/)

Before you make irreplaceable damage to your git, use the [firstAidGit](https://firstaidgit.io/#/) for remedy.

added a new line