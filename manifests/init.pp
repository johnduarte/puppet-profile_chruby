#
class profile_chruby (
  $username = 'puppet',
  $ruby_ver = '2.1.6',
  $acceptance_key
) {

# set variables
#grep=$(which grep)
#shellrc=.$(echo $SHELL | cut -d / -f 3)rc

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

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
      $group = 'staff'
      $sudo_group = 'wheel'
      warning('sudo package installation not supported on OS X')
      file { $home:
        ensure  => directory,
        owner   => $username,
        group   => $group,
        require => User[$username],
      }
    }
    default: {
      $home = "/home/${username}"
      $managehome = true
      $chruby_group = 'root'
      $group = $username
      $sudo_group = 'sudo'
      package { 'sudo':
        ensure => present,
        before => User[$username],
      }
    }
  }

  # FIXME: Find out why OS X does not use profile.d
  file { '/etc/profile.d':
    ensure => directory,
    before => Class['chruby'],
  }

  user { $username:
    ensure     => present,
    managehome => $managehome,
    shell      => '/bin/bash',
    groups     => [$sudo_group],
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
    group   => $group,
    mode    => '0600',
    require => User[$username],
  }

  file{ "${home}/.ssh/id_rsa-acceptance":
    ensure  => present,
    owner   => $username,
    group   => $group,
    mode    => '0600',
    content => $acceptance_key,
    require => User[$username],
  }

  file{ "${home}/.bashrc":
    ensure  => present,
    owner   => $username,
    group   => $group,
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
    group   => $group,
    require => User[$username],
  }

  file{"${home}/.bash_profile":
    ensure  => present,
    owner   => $username,
    group   => $group,
    require => User[$username],
  }

  file{"${home}/.fog":
    ensure  => present,
    owner   => $username,
    group   => $group,
    mode    => '0600',
    require => User[$username],
  }

  exec {  "grep -q -F '${shellrc}' ${home}/.bash_profile || echo 'if [ -f \"\${HOME}/.bashrc\" ] ; then\n  source \"\${HOME}/.bashrc\"\nfi' >> ${home}/.bash_profile":
    require => File["${home}/.bash_profile"],
  }

  ruby_build::install_ruby { $ruby_ver: }
}
