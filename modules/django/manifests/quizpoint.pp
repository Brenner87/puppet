class django::quizpoint (
    $quizpoint_params,
    $quizpoint_secret
)
{
    $linux_packages = [
        'https://centos7.iuscommunity.org/ius-release.rpm',
        'python36',
        'python36-pip',
        'python36-devel',
    ]

    $pip_packages = [
        'virtualenv',
    ]

    yum::group { 'development':
        ensure  => 'present',
        timeout => 600,
    }

    package { $linux_packages:
        ensure => latest
    }

#    include pip

    pip::install { $pip_packages:
        python_version => '3.6',
        ensure         => present,
        require        => Package['python36-pip'],
    }

       
}
