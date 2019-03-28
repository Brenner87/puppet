define django::install_python (
    $python
){
    $packages=["ius-release", $python, "${python}-pip", "${python}-devel"]

#    yumrepo {'ius':
#        baseurl  => 'https://dl.iuscommunity.org/pub/ius/stable/CentOS/7',
#        gpgcheck => 0,
#        enabled => true,
#        descr    => 'Python repo'
#    }

    yum::group { 'development':
        ensure  => 'present',
        timeout => 600,
        require => Package['ius-release'],
    }

    package {$packages:
        ensure => present,
        require => Yumrepo['ius'],
    }

    Package['ius-release'] -> Package[$python] -> Package["${python}-devel" -> Pakcage["${python}-pip"]


    
}
