[Documentation Home](../README.md)

# Git Guide

## What is Git

Git is a tool that allows multiple people and groups contribute to a project simultaneously. Git is the industry standard way to collaborate on *software* projects. It lets multiple teams of people all contribute to one set of master source code. In an industry where a single wrong character can cause catastrophic failure, it's important to have one set of 'stable' software, and to give people the ability to test new code without fear of interfering with the work of others. 

We can apply a few Git tools to create one set of mutually agreed upon instruction manuals. Consider this example scenario. Somebody in Housing has decided that some data entry instructions need to be updated. This can range from writing instructions for a totally new procedure for a new funding source, or just polishing up some outdated language. Git allows her to make a clone of the existing master instructions, this is called a ***branch***. All the updates are made on the branch, then when she decides she has a final draft, the branch can be merged with the master copy.

But there's more depth to Git. Let's say someone decides they need to make some updates, but then they employ the help of somebody else in the department to help. That person can make a branch of the branch, so they have a tool for deciding between themselves on the contents of their final version. Once they agree, their branches are merged together, then that larger branch is merged into the master copy using the same process. You can make a branch of a branch of a branch, etc. Every time branches are merged there is a built in review and reconciliation process for differences between the versions.

To work on this project, we will probably use about 1% of the power of Git.

## Github

Github is a platform that provides free hosting of Git repositories, like this one. It also provides all sorts of user friendly tools to manage the branching, merging, cloning, etc. 


### Practical Step-by-Step

- [Make a Github account](https://github.com). Use your HRDC G Suite account (xxxxxxxx@thehrdc.org). This will insure that the agency will not lose any contributions made my employees that end up leaving HRDC.
- [Download Github Desktop](https://desktop.github.com/). This is a pretty user friendly tool to manage Git operations on your computer. This is their [Official Documentation](https://docs.github.com/en/free-pro-team@latest/desktop). That should be your go-to source of information about how Git, Github, and Github Desktop all work together. In the steps below, I will try to reference as much official material as possible that applies to our use case.
- [Clone the repository](https://docs.github.com/en/free-pro-team@latest/desktop/contributing-and-collaborating-using-github-desktop/cloning-a-repository-from-github-to-github-desktop). This makes a copy of the entire documentation and lets you edit any and all files locally.
- [Create a branch](https://docs.github.com/en/free-pro-team@latest/desktop/contributing-and-collaborating-using-github-desktop/managing-branches). "You can use branches to safely experiment with changes to your project. Branches isolate your development work from other branches in the repository. For example, you could use a branch to develop a new feature or fix a bug." 
- [Commit changes](https://docs.github.com/en/free-pro-team@latest/desktop/contributing-and-collaborating-using-github-desktop/committing-and-reviewing-changes-to-your-project). This is how individual changes are managed. The changes that you make will be committed to the branch that you created.
- [Push to origin](https://docs.github.com/en/free-pro-team@latest/desktop/contributing-and-collaborating-using-github-desktop/pushing-changes-to-github). This publishes the changes to the remote repository (on github.com). They will still be specific to the branch you created.
- [Merging Branches](https://docs.github.com/en/free-pro-team@latest/desktop/contributing-and-collaborating-using-github-desktop/creating-an-issue-or-pull-request#creating-a-pull-request). This is the final step where your changes are applied to the master document. Or if you are working on branch of a branch, then it will apply the changes one level up.