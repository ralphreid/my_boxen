require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # additional modules
  include onepassword

  include atom
  atom::package { 'linter': }
  atom::package { 'markdown-pdf': }
  atom::package { 'markdown-preview': }
  atom::package { 'markdown-sort-list': }
  atom::package { 'markdown-preview-opener': }
  atom::package { 'markdown-table-formatter': }
  atom::package { 'tidy-markdown': }
  atom::package { 'markdown-format': }
  atom::package { 'linter-markdown': }
  atom::package { 'markdown-scroll-sync': }
  atom::package { 'markdown-helpers': }
  atom::theme { 'monokai': }

  #configure git
  git::config::global { 'user.email':
    value  => 'beresfordjunior@me.com'
  }
  git::config::global { 'user.name':
    value  => 'Ralph Reid'
  }

  package { 'alfred': provider => 'brewcask' }
  package { 'google-chrome': provider => 'brewcask' }
  package { 'postbox': provider => 'brewcask' }
  package { 'dropbox': provider => 'brewcask' }
  package { 'iterm2': provider => 'brewcask' }
  package { 'evernote': provider => 'brewcask' }
  package { 'pycharm': provider => 'brewcask' }
  package { 'skype': provider => 'brewcask' }
  package { 'hipchat': provider => 'brewcask' }
  package { 'paw': provider => 'brewcask' }

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  nodejs::version { '0.8': }
  nodejs::version { '0.10': }
  nodejs::version { '0.12': }

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.7': }
  ruby::version { '2.2.3': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}
