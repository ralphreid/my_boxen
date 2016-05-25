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

  atom::package {
    [
      'linter',
      'markdown-pdf',
      'multi-cursor',
      'markdown-preview',
      'markdown-sort-list',
      'markdown-preview-opener',
      'markdown-table-formatter',
      'markdown-format',
      'linter-markdown',
      'markdown-scroll-sync',
      'markdown-helpers',
    ]:
  }

  atom::theme { 'monokai': }

  #configure git
  git::config::global { 'user.email':
    value  => 'beresfordjunior@me.com'
  }
  git::config::global { 'user.name':
    value  => 'Ralph Reid'
  }

  package {
    [
      'paw',
      'google-chrome',
      'postbox',
      'dropbox',
      'iterm2',
      'evernote',
      'pycharm',
      'skype',
      'hipchat',
      'slack',
      'alfred',
      'vagrant-manager',
      'kindle',
    ]: provider => 'brewcask'
  }

  class { 'vagrant': }

  vagrant::plugin { 'r10k': }

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
  ruby::version { '2.1.8': }
  ruby::version { '2.2.4': }

  # Set the global default ruby (auto-installs it if it can)
  class { 'ruby::global':
    version => '2.2.3'
  }

  # ensure a gem is installed for all ruby versions
  ruby_gem { 'bropages for all rubies':
    gem          => 'bropages',
    version      => '~> 0.1.0',
    ruby_version => '*',
  }

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
