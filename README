puppet-rvm
==========

Localized installation of multiple versions of ruby via [RVM](https://raw.githubusercontent.com/wayneeseguin/rvm/master/binscripts/rvm-installer).

Tested to work on 64-bit:

  * AWS Linux
  * CentOS 6.x
  * Ubuntu

## Parameters
  * `user`    : target user to install ruby into
  * `version` : must be the full version (format: x.x.x)

## Usage

Basic:

This will automatically create `/home/fluentd` and `ruby-1.9.3`

class { 'rvm':
      user    => 'fluentd',
      version => '1.9.3',
     }

## Dependencies

This module relies on following packages (install it beforehand, either manually or via puppet):

  * git
  * curl
  * make
