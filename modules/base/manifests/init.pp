class base ($base_version){

  include base::handle_users
  include base::handle_hosts

  $package_list=['epel-release',
                'automake',
                'vim-enhanced',
                'wget',
                'pcre-devel',
                'xz-devel',
                'git',
                'the_silver_searcher',
                'gnupg',
                'rng-tools',
                'gem',
                'lsof',
                
                ]
  $home_dirs = ['/home/vagrant/', '/root/',]

  package {$package_list:
      ensure => $base_version,
      notify => Package['hiera-eyaml'],
          }

  package {'hiera-eyaml':
      provider => 'gem',
      ensure   => 'present',
  }

  $home_dirs.each |$value| {
    file {"$value.vimrc":
        ensure => 'present',
        source => 'puppet:///modules/base/vimrc',
        owner  => split($value, '/')[-1],
        require => Package[$package_list],
        }
  }
  
}
