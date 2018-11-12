class jenkins::config ($jenkins_admin_password){

    $groovy_dir='/var/lib/jenkins/init.groovy.d'

    file {'/etc/sysconfig/jenkins':
        ensure => 'present',
        source => 'puppet:///modules/jenkins/jenkins',
        mode   => '0644',
        owner  => 'jenkins',
        group => 'jenkins',
    }

    file {$groovy_dir:
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }

    file {"${groovy_dir}/security.groovy":
        ensure  => 'present',
        content => template('jenkins/security.groovy.erb'),
        owner   => 'jenkins',
        group   => 'jenkins',
        mode    => '0600',
        require => File[$groovy_dir],
    }
    
    file {"${groovy_dir}/installPlugins.groovy":
        ensure  => 'present',
        content => template('jenkins/installPlugins.groovy.erb'),
        owner   => 'jenkins',
        group   => 'jenkins',
        mode    => '0600',
        require  => File[$groovy_dir],
    }
}

