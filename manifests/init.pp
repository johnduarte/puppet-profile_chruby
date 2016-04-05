#
class profile_chruby (
  $ruby_ver = '2.1.6'
) {

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  case $::osfamily {
    'Darwin': {
      $chruby_group = 'wheel'
      $global_bashrc = '/etc/bashrc'
      $pkg_provider = 'brew'
      contain homebrew
    }
    'Debian': {
      $chruby_group = 'root'
      $global_bashrc = '/etc/bash.bashrc'
      $pkg_provider = undef
    }
    default: {
      $chruby_group = 'root'
      $global_bashrc = '/etc/bashrc'
      $pkg_provider = undef
    }
  }

  class { 'ruby_build':
    version => 'master',
  }

  class { 'chruby':
    version => '0.3.9',
    user    => 'root',
    group   => $chruby_group,
  }

  file_line{'Add chruby to global bashrc':
    path    => "${global_bashrc}",
    line    => 'source /usr/local/share/chruby/chruby.sh',
  }->
  file_line{'Add chruby auto to global bashrc':
    path    => "${global_bashrc}",
    line    => 'source /usr/local/share/chruby/auto.sh',
  }->
  file_line{'Add chruby ruby version to global bashrc':
    path    => "${global_bashrc}",
    line    => "chruby ${ruby_ver}",
  }

  ruby_build::install_ruby { $ruby_ver: }

}
