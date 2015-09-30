#
class profile_chruby (
  $username = 'puppet',
  $ruby_ver = '2.1.6',
  $acceptance_key
) {

# set variables
#grep=$(which grep)
#shellrc=.$(echo $SHELL | cut -d / -f 3)rc

  Package {
    provider => $::osfamily ? {
      Darwin  => 'brew',
      default => undef
    }
  }
  case $::osfamily {
    'Darwin': {
      $home = "/Users/${username}"
      $managehome = false
      $chruby_group = 'wheel'
    }
    default: {
      $home = "/home/${username}"
      $managehome = true
      $chruby_group = 'root'
    }
  }

  # FIXME: Find out why OS X does not use profile.d
  file { '/etc/profile.d':
    ensure => directory,
    before => Class['chruby'],
  }

  package { 'sudo':
    ensure => present,
    before => User[$username],
  }

  user { $username:
    ensure     => present,
    managehome => $managehome,
    shell      => '/bin/bash',
    groups     => ['sudo'],
  }

  class { 'ruby_build':
    version => 'master',
  }

  class { 'chruby':
    version => '0.3.9',
    user    => 'root',
    group   => $chruby_group,
  }

  file{ "${home}/.ssh":
    ensure  => directory,
    owner   => $username,
    group   => $username,
    mode    => '0600',
    require => User[$username],
  }

  file{ "${home}/.ssh/id_rsa-acceptance":
    ensure  => present,
    owner   => $username,
    group   => $username,
    mode    => '0600',
    content => $acceptance_key,
    require => User[$username],
  }

  file{ "${home}/.bashrc":
    ensure  => present,
    owner   => $username,
    group   => $username,
    require => User[$username],
  }

  file_line{'Add chruby to .bashrc':
    path    => "${home}/.bashrc",
    line    => 'source /usr/local/share/chruby/chruby.sh',
    require => File["${home}/.bashrc"],
  }
  file_line{'Add chruby auto to .bashrc':
    path    => "${home}/.bashrc",
    line    => 'source /usr/local/share/chruby/auto.sh',
    require => File["${home}/.bashrc"],
  }

  file{"${home}/.ruby-version":
    ensure  => present,
    content => $ruby_ver,
    owner   => $username,
    group   => $username,
    require => User[$username],
  }

  file{"${home}/.bash_profile":
    ensure  => present,
    owner   => $username,
    group   => $username,
    require => User[$username],
  }

  file{"${home}/.fog":
    ensure  => present,
    owner   => $username,
    group   => $username,
    mode    => '0600',
    require => User[$username],
  }

  exec {  "/bin/grep -q -F '${shellrc}' ${home}/.bash_profile || echo 'if [ -f \"\${HOME}/.bashrc\" ] ; then\n  source \"\${HOME}/.bashrc\"\nfi' >> ${home}/.bash_profile":
    require => File["${home}/.bash_profile"],
  }

  ruby_build::install_ruby { $ruby_ver: }
}
