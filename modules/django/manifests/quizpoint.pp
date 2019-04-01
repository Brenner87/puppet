class django::quizpoint (
    $quizpoint_params,
    $quizpoint_secret
)
{
    #include python


    $allowed_hosts = $quizpoint_vars['proj_allowed_hosts']
    $name          = $quizpoint_vars['proj_name']
    $db_addr       = $quizpoint_vars['proj_db_addr']
    $path          = $quizpoint_vars['proj_path']
    $log           = "${path}/logs/${name}.log"
    $src           = $quizpoint_vars['proj_src']
    $is_prod       = $quizpoint_vars['is_prod']
    $db_port       = $quizpoint_vars['db_port']
    $db_user       = $quizpoint_vars['db_user']
    $db_name       = $quizpoint_vars['db_name']
    $db_port       = $quizpoint_vars['db_port']
    $user          = $quizpoint_vars['user']
    $group         = $quizpoint_vars['group']
    $python        = $quizpoint_vars['python'] 
    $uwsgi_port    = $quizpoint_vars['uwsgi_port']
    $db_pass       = $quizpoint_secret['db_pass']
    $db_key        = $quizpoint_secret['db_key']

    user {$user:
        ensure     => present,
        managehome => false,
    }



    file {$path:
        ensure  => directory,
        owner   => $user,
        group   => 'nginx',
        require => User[$user],
    }

    ['config','run_data','logs'].each |$dir| {

        file {"${path}/${dir}":
            ensure  => directory,
            owner   => $user,
            group   => 'nginx',
            require => File[$path],
        }
    }


    file {$log:
        ensure  => directory,
        owner   => $user,
        group   => 'nginx',
        require => File["${path}/logs"],
    }

    python::install_python { $python: }

    python::update_pip { 'update-pip':
        python    => $python,
        subscribe => Python::Install_python[$python]
    }

    python::install_pip_module {'virtualenv':
        python  => $python,
        require =>Python::Update_pip['update-pip']
    }  

    python::create_venv {"${path}/env":
        python  => $python,
        owner   => $user,
        require => Python::Install_pip_module['virtualenv']
    }

    python::install_pip_module {'uwsgi':
        python  => $python,
        venv    => "${path}/env",
        owner   => $user,
        require => Python::Create_venv["${path}/env"]
    }

    vcsrepo {"${path}/www":
        ensure   => latest,
        provider => 'git',
        source   => $src,
        user     => $user,
        group    => 'nginx',
        require  => [User[$user],File[$path],Package['git']],
    }

    python::install_pip_module {'requirements.txt':
        python   => $python,
        venv     => "${path}/env",
        owner    => $user,
        req_file => "${path}/www/requirements.txt",
        require  => [
                        Python::Create_venv["${path}/env"], 
                        Vcsrepo["${path}/www"]                    
                    ]
   }

   #   django::tools::collectstatic {$quizpoint_params['proj_path']:
   #       user    => $quizpoint_params['user'],
   #       group   => 'nginx',
   #       require => Vcsrepo["${quizpoint_params['proj_path']}/www"]
   #   }

    file {"${path}/config/vars":
        ensure  => present,
        content => epp('django/vars.epp',),
        owner   => $quizpoint_params['user'],
        group   => $quizpoint_params['group'],
        require => File["${path}/config"]
    }

    file {"${path}/config/uwsgi.ini":
        ensure  => present,
        content => epp('django/uwsgi.ini.epp'),
        owner   => $user,
        group   => $group,
        require => File["${path}/config"],
    }

    file {"/etc/systemd/system/${name}.service":
        ensure  => present,
        content => epp('uwsgi.service.epp'),
        owner   => 'root',
        group   => 'root',
        require => File["${path}/config"],
    }
}
