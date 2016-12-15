# puppet-packages
Puppet module to manage the easy installation of packages across hiera.

It assumes Macports for OSX and Zypper for Suse systems.

## Instructions
Call the class from your code, e.g. `class { 'packages': }`

## Issues
This module is using hiera data that is embedded in the module rather than using a params class.  This may not play nicely with other modules using the same technique unless you are using hiera 3.0.6 and above (PE 2015.3.2+).
