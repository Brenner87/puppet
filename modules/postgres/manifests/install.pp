class postgres::install {

    package {'pgdg-centos11':
        ensure => latest,

    package {'postgresql11-server':
        ensure  => '11.2-2',
        require => Package['pgdg-centos11'],
    }

    package {'postgresql11-contrib.x86_64':
        ensure  => '11.2-2',
        require => Package['postgresql11-server'],
    }



}
