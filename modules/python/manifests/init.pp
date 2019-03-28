class python {

    define install_python (
        $python=$title
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
        $python='python2'
    ){
        exec {'update-pip':
            command => "/bin/${python} -m pip install -U pip",
            refreshonly => true,
        }
    }

    define install_pip_module (
        $python='python2',
        $module=$title,
        $version='',
    ){

        if $version {
            $command="/bin/${python} -m pip install ${module}==${$version}"
            $unless_command="/bin/${python} -m pip list installed | grep ${modulea} | grep ${version}"
        }
        else { 
            $command="/bin/${python} -m pip install ${module}"
            $unless_command="/bin/${python} -m pip list installed | grep ${module}"
        }

        Exec {$command:
            unless  => $unless_command,
        }
    }

}
