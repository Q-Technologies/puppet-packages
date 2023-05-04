# packages

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [Description](#description)
  * [Assumptions](#assumptions)
  * [Limitations](#limitations)
* [Instructions](#instructions)
* [Issues](#issues)

<!-- vim-markdown-toc -->

## Description

Puppet module to easily manage a list of operating system packages across hiera.  It tries to make it efficient to install 
packages across different Linux systems within the same Hiera scope.  Common packages can be listed under the Kernel
type, while more unique packages can be listed by the OS family.

By default, the listed items are interpreted as package name and Puppet will just make sure they are installed (i.e. version is not managed).  To
manage the version provide an array of Strings instead of a just a String.  The first element will be interpreted as the package name and the second
argument is the version to match (this is just passed through to the Puppet package resource, so 'latest' can also be specified.

Additionally, packages can be put into an ignore group.  This is most helpful when you generally want to manage a package, but you don't want to in a specific role
because it uses a class that already manages that package.

### Assumptions

  * it set Macports as the package provider for OSX 
  * it set Zypper as the package provider for Suse systems 
  * it uses the default for other platforms

### Limitations
Specifying a specific version may be troublesome if you are managing operating systems at different major versions as there is no way to differentiate for each OS 
release. I could add another layer into the Hash to match OS release, but that will get messy and defeat the purpose of trying to simplify.


## Instructions
Call the class from your code, e.g. 

```
class { 'packages': }
```

Specify hiera details along the following lines:

```
################################################################################
#
# Packages
#
################################################################################
packages::add: 
  Linux:
    - [git,'latest']
    - curl
    - iftop
    - wget
    - rsync
    - less
    - iotop
    - lvm2
    - screen
  Darwin:
    - watch
  Debian:
    - bind9utils
    - bsd-mailx
    - iputils-arping
    - iputils-clockdiff
    - iputils-ping
    - iputils-tracepath
    - vim
    - manpages
    - dlocate
    - rsyslog
  RedHat:
    - bind-utils
    - mailx
    - iputils
    - vim-enhanced
    - man-pages
    - [rsyslog,'7.4.7-12.el7']
  Suse:
    - bind-utils
    - iputils
    - vim
    - man
    - man-pages

packages::remove:
  Linux:
    - pdsh

packages::ignore:
  Linux:
    - openssh-server

```

## Issues
This module is using hiera data that is embedded in the module rather than using a params class.  This may not play nicely with other modules using the same technique unless you are using hiera 3.0.6 and above (PE 2015.3.2+).
