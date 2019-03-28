define django::install_python (
    $python
){
    $packages=["ius-release", $python, "${python}-pip", "${python}-devel"]

    yum::group { 'development':
        ensure  => 'present',
        timeout => 600,
        require => Package['ius-release'],
    }

    package { $packages:
        ensure => present,
    }

    Package['ius-release'] -> Package[$python] -> Package["${python}-devel" -> Pakcage["${python}-pip"]
   
}
