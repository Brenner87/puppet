class jenkins ($base_version,
               $jdk_version,
               $jenkins_admin_password){
    $packages=['jenkins',]
    $groovy_dir='/var/lib/jenkins/init.groovy.d'
    package {'jenkins':
        ensure => 'latest',
        notify => File['/etc/sysconfig/jenkins'],
    }
    
    file {$groovy_dir:
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
        notify => File["${groovy_dir}/basic-security.groovy"],
    }

#    exec {"${groovy_dir}/basic-security.groovy":
#        command => "/usr/bin/echo '#!groovy
#import jenkins.model.*
#import hudson.util.*;
#import jenkins.install.*;
#def instance = Jenkins.getInstance()
#instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)'>${groovy_dir}/basic-security.groovy",
#        notify => Service['jenkins'],
#    }


#    exec {"${groovy_dir}/basic-security.groovy":
#        command=>"/usr/bin/echo 'import jenkins.model.*
#import hudson.security.*
#def instance = Jenkins.getInstance()
#def hudsonRealm = new HudsonPrivateSecurityRealm(false)
#hudsonRealm.createAccount(\"admin\",\"password\")
#instance.setSecurityRealm(hudsonRealm)
#instance.save()'>${groovy_dir}/basic-security.groovy",
#    notify => Service['jenkins'],
#    }


    file {"${groovy_dir}/basic-security.groovy":
        ensure  => 'present',
        content => template('jenkins/basic-security.groovy.erb'),
        notify  => Service['jenkins'],
    }
    
    file {'/etc/sysconfig/jenkins':
        ensure => 'present',
        source => 'puppet:///modules/jenkins/jenkins',
        mode   => '0644',
        owner  => 'root',
        group => 'root',
        notify => File[$groovy_dir],
    }
          

    package {'java-1.8.0-openjdk.x86_64':
        ensure => $jdk_version,
        before => Package['jenkins'],
    }

    service {'jenkins':
        ensure => 'running',
        enable => true,
 #       notify => Exec['/usr/bin/sleep 10 && /usr/bin/curl localhost:8080/login'],
    }
#    exec {'/usr/bin/sleep 10 && /usr/bin/curl localhost:8080/login':
#        notify => Exec['jenkins_restart'],
#    }
#
#    exec {'jenkins_restart':
#        command => '/usr/bin/systemctl restart jenkins',
#        onlyif  => "/usr/bin/grep -q 'InstallState.INITIAL_SETUP_COMPLETED' ${groovy_dir}/basic-security.groovy",
##       notify => File['remove_groovy']
#    }

#    file {'remove_groovy':
#        ensure => 'absent',
#        path   => "${groovy_dir}/basic-security.groovy",
#    }
}
