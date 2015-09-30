# profile_chruby

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with profile_chruby](#setup)
    * [What profile_chruby affects](#what-profile_chruby-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with profile_chruby](#beginning-with-profile_chruby)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

`profile_chruby` manages a single defined ruby instance for a specified user.
It aims to take the place of `crossfader` for managing rubies while removing
the extra wrapper that `crossfader` imposed.

## Module Description

This module manages `chruby` and `ruby-build` to create a single defined
default ruby for the given user. The intention is that PuppetLabs professional
can update thier ruby version to match the prevailing version used by their
group. For example, people doing testing can ensure that their ruby verison
matches that of the Jenkins test systems that will run the tests in CI.

The module will create the given user on the system if the user is not
already present. It will also add a given ssh key to the user in order to
ensure that the user can connect to test VMs. The value of the key can be
entered as a parameter when applying the module, but can more conveniently
be added as a hiera data entry.

## Setup

### What profile_chruby affects

* Installs `sudo` package
* Adds/updates user and following user files
  * `$home/.ssh/id-rsa-acceptance` - to provide access to test VMs
  * `$home/.bashrc` - source `chruby` scripts
  * `$home/.ruby-version` - define ruby version to auto load for user
  * `$home/.bash_profile` - source `.bashrc`
  * `$home/.fog` - only creates this file, contents are not managed
* Adds user to `sudo` group
* Installs `chruby`
* Installs `ruby-build`
  * Compiles and installs defined ruby version

### Beginning with profile_chruby

You are most likely to want to deploy to a specified user:

`puppet apply -e "class { 'profile_chruby': username => 'mary' }"`

## Usage

`puppet apply -e "class { 'profile_chruby': }"`

Without a `username` parameter, a user named `puppet` will be managed
and the default version of ruby installed for that user.

`puppet apply -e "class { 'profile_chruby': username => 'mary' }"`

With a `username` parameter, a user named `mary` will be managed
and the default version of ruby installed for that user.

`puppet apply -e "class { 'profile_chruby': username => 'mary', ruby_ver => '1.9.3-p484' }"`

With a `username` parameter, the specified user named `mary` will be managed
and the specified ruby version `1.9.3-p484` installed for that user.


## Reference

### Public Classes

`profile_chruby`

## Limitations

This module is supported on Debian and RedHat derivatives as well as OS X.
