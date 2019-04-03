class web {
    package {'nginx':
        ensure => 'latest',
    }
    
    file {'':
        ensure    => 'present',
        content   => epp('web/nginx.conf.epp'),
        require   => Package['nginx'],
        subscribe => Service['nginx']
    }

    service {'nginx':
        ensure  => running,
        enabled => true,
    }
}
