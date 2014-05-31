class proj::rvm (
  $user,
  $version,
) {

  Exec {
    path => [
       '/usr/bin',
       '/usr/sbin',
       '/usr/local/bin',
       '/bin',
       '/sbin',
    ],
    logoutput => on_failure,
  }

  validate_re($version, '^\d+\.\d+\.\d+$',
    'Please specify a valid ruby version, format: x.x.x (e.g. 1.9.3)')

  if ! defined(User[$user]) {
    user { $user:
      ensure         => present,
      shell          => '/bin/bash',
      home           => "/home/${user}",
      managehome     => true,
    }
  }

  # install dependencies
  case $::operatingsystem {
      amazon,centos: {
        $pkg = [ 'libyaml-devel', 'readline-devel', 'zlib-devel', 'libffi-devel','openssl-devel', 'gcc-c++','patch','autoconf','automake','libtool','bison'] 
      }
      ubuntu: {
        $pkg = [ 'g++', 'libreadline6-dev', 'zlib1g-dev', 'libyaml-dev', 'libgdbm-dev', 'libncurses5-dev', 'autoconf', 'automake', 'libtool', 'pkg-config', 'libffi-dev', 'libsqlite3-dev', 'sqlite3' ]
        }
        default: { fail ("Error: Unsupported operating system = ${::operatingsystem}") }
   }
  package { $pkg:
    ensure  => installed,
  }

  # dependency check
  exec { 'check-needed-packages':
    command      => '/usr/bin/which git && /usr/bin/which curl && /usr/bin/which make',
    user         => $user,
    environment  => [ "HOME=/home/${user}" ],
    require      => [User[$user],Package[$pkg]],
    unless       => "test -e /home/${user}/.rvm/scripts/rvm",
    notify       => Exec['rvm-install-script'],
  }

  # install via script
  exec { 'rvm-install-script':
    command     => '/usr/bin/wget https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer && sh rvm-installer stable',
    cwd         => "/home/${user}/",
    user        => $user,
    creates     => "/home/${user}/.rvm/scripts/rvm",
    notify      => Exec["rvm-install-ruby-${version}"],
    environment => [ "HOME=/home/${user}" ],
    refreshonly => true,
  }


  # install ruby <version>
  exec { "rvm-install-ruby-${version}":
    command     => "/home/${user}/.rvm/bin/rvm install ${version}",
    cwd         => "/home/${user}/",
    user        => $user,
    timeout     => 3000,
    environment => [ "HOME=/home/${user}" ],
    unless      => "/bin/bash -c 'source /home/${user}/.rvm/scripts/rvm && rvm list | grep ${version}'",
    require     => Exec['rvm-install-script'],
    refreshonly => true,
  }

  # Order of things
  Exec['check-needed-packages']~>Exec['rvm-install-script']~>Exec["rvm-install-ruby-${version}"]
}
