class python {

    define install_python (
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
    
        Package['ius-release'] -> Package[$python] -> Package["${python}-devel"] -> Package["${python}-pip"]    
    }

    define update_pip (
        $python
    ){
        exec {'update-pip':
            command => "/bin/${python} -m pip install -U pip"
        }
    }

    define install_pip_module (
        $python='python2',
        $module
    ){
        Exec {"install-module":
            command => "/bin/${python} -m pip install ${module}",
            unless  => "/bin/${python} -m pip list installed | grep ${module}",
        }
    }

}
