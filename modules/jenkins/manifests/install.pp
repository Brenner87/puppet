class jenkins::install ($base_version,
                        $jdk_version,
                        ){

    $packages=['jenkins',]
    $groovy_dir='/var/lib/jenkins/init.groovy.d'

#    package {'java-1.8.0-openjdk.x86_64':
    package {'java-1.8.0-openjdk-devel':
        ensure => $jdk_version,
        before => Package['jenkins'],
    }

    package {'jenkins':
        ensure => $base_version,
    }
}
