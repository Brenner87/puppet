class jenkins::maven {

    package {'java-1.8.0-openjdk-devel':
        ensure => 'latest',

    $source = 'http://www-eu.apache.org/dist/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz'
    $destination = '/opt/maven'
    $archive = '/opt/maven.tar.gz'

    file {$archive:
        ensure => 'present',
        owner  => 'root',
        group  => 'root',
        mode   => '644',
        source => $source,
    }

    file {$destination:
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '755',
    }

    exec {'unpack_maven':
        unless  => "/bin/test -d ${destination}/bin",
        cwd     => '/opt',
        command => "/bin/tar -xzf ${archive} --strip-components 1 -C ${destination}",
    }

    file {'/etc/profile.d/maven.sh':
        ensure  => 'present',
        owner  => 'root',
        group  => 'root',
        mode   => '644',
        content => template('jenkins/maven.sh.erb'),
    }

    file {"${destination}/conf/settings.xml":
        ensure => 'present',
        owner  => 'root',
        group  => 'root',
        mode   => '644',
        content => template('jenkins/settings.xml.erb'),
    }
    
    File[$archive] -> File[$destination] -> Exec['unpack_maven'] ~> File['/etc/profile.d/maven.sh'] ~> File["${destination}/conf/settings.xml"]
}
