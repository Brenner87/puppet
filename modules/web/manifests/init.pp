class web {
    package {'nginx':
        ensure => 'latest',
    }
    
    file {'/etc/nginx/nginx.conf':
        ensure    => 'present',
        content   => epp('web/nginx.conf.epp'),
        require   => Package['nginx'],
        subscribe => Service['nginx'],
        owner     => 'root',
        group     => 'root'
    }

}
