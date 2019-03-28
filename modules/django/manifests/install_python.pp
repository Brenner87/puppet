define django::install_python (
    $python
){
    $packages=[$python, "${python}-pip", "${python}-devel"]

    yumrepo {'ius':
        baseurl  => 'https://dl.iuscommunity.org/pub/ius/stable/CentOS/7',
        gpgcheck => 0,
        descr    => 'Python repo'
    }

    yum::group { 'development':
        ensure  => 'present',
        timeout => 600,
        enabled => true,
        require => Yumrepo['ius'],
    }

    package {$packages:
        ensure => present,
        require => Yumrepo['ius'],
    }


    
}
