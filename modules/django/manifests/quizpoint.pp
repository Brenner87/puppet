class django::quizpoint (
    quizpoint_params,
    quizpoint_secret
)
{
    $linux_packages = [
        'https://centos7.iuscommunity.org/ius-release.rpm',
        'python36',
        'python36-pip',
        'python36-devel',
    ]

    $pip_packages = [
        'pip',
        'virtualenv',
    ]

    yum::group { 'development':
        ensure  => 'present',
        timeout => 600,
    }

    package { $linux_packages:
        ensure => latest
    }

    ensure_packages ( $pip_packages {
        ensure   => latest,
        privider => pip3,
        require  => Package ['python36-pip']
    })

       
}
