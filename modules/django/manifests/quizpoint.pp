class django::quizpoint (
    $quizpoint_params,
    $quizpoint_secret
)
{
    #include python


    $allowed_hosts = $quizpoint_params['proj_allowed_hosts']
    $proj_name     = $quizpoint_params['proj_name']
    $db_addr       = $quizpoint_params['proj_db_addr']
    $path          = $quizpoint_params['proj_path']
    $log           = "${path}/logs/${proj_name}.log"
    $src           = $quizpoint_params['proj_src']
    $is_prod       = $quizpoint_params['is_prod']
    $db_port       = $quizpoint_params['db_port']
    $db_user       = $quizpoint_params['db_user']
    $db_name       = $quizpoint_params['db_name']
    $user          = $quizpoint_params['user']
    $group         = $quizpoint_params['group']
    $python        = $quizpoint_params['python'] 
    $uwsgi_port    = $quizpoint_params['uwsgi_port']
    $uwsgi_addr    = $quizpoint_params['uwsgi_addr']
    $db_pass       = $quizpoint_secret['db_pass']
    $db_key        = $quizpoint_secret['db_key']
    $static        = $quizpoint_secret['static']

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
        ensure  => present,
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


    file {"${path}/config/vars":
        ensure  => present,
        content => epp('django/vars.epp',
        {
            allowed_hosts =>  $allowed_hosts,
            proj_name     =>  $proj_name,
            db_addr       =>  $db_addr,
            path          =>  $path,
            log           =>  $log,
            src           =>  $src,
            is_prod       =>  $is_prod,
            db_port       =>  $db_port,
            db_user       =>  $db_user,
            db_name       =>  $db_name,
            user          =>  $user,
            group         =>  $group,
            python        =>  $python,
            uwsgi_port    =>  $uwsgi_port,
            db_pass       =>  $db_pass,
            db_key        =>  $db_key,
        }),
        owner   => $quizpoint_params['user'],
        group   => $quizpoint_params['group'],
        require => File["${path}/config"]
    }

    file {"${path}/config/uwsgi.ini":
        ensure         => present,
        content        => epp('django/uwsgi.ini.epp', {
            uwsgi_port => $uwsgi_port,
            uwsgi_addr => $uwsgi_addr
        }),
        owner   => $user,
        group   => $group,
        require => File["${path}/config"],
    }

    file {"/etc/systemd/system/${proj_name}.service":
        ensure        => present,
        content       => epp('django/uwsgi.service.epp', {
            proj_name => $proj_name,
            path      => $path,
            user      => $user
        }),
        owner   => 'root',
        group   => 'root',
        require => File["${path}/config"],
    }

    file {"${path}/config/${proj_name}_nginx.conf":
        ensure          => present,
        content         => epp('django/proj_nginx.conf.epp', {
            proj_name   => $proj_name,
            path        => $path,
            user        => $user,
            uwsgi_port  => $uwsgi_port,
            uwsgi_addr  => $uwsgi_addr,
            proj_path   => $path,
            static_path => $static
        }),
        owner   => 'root',
        group   => 'root',
        require => File["${path}/config"],
     }

     file {"/etc/nginx/conf.d/${proj_name}_nginx.conf":
        ensure  => 'link',
        target  => "${path}/config/${proj_name}_nginx.conf",
        require => [
                        File["${path}/config/${proj_name}_nginx.conf"],
                        Package['nginx']
                   ],
        notify => Service['nginx']
     }

   django::tools::collectstatic {$path:
        user          => $quizpoint_params['user'],
        group         => 'nginx',
        is_prod       => $is_prod,
        db_pass       => $db_pass,
        db_key        => $db_key,
        allowed_hosts => $allowd_hosts,
        db_addr       => $db_addr,
        db_port       => $db_port,
        db_user       => $db_user,
        db_name       => $db_name,
        subscribe     => Python::Install_pip_module['requirements.txt']
   }
   exec { 'daemon-reload':
        command     => '/usr/bin/systemctl daemon-reload',
        refreshonly => true,
        subscribe   => File["/etc/systemd/system/${proj_name}.service"],
    }

    service {$proj_name:
        ensure => running,
        enable => true,
        subscribe => [
                        Exec['daemon-reload'],
                        File["${path}/config/uwsgi.ini"],
                        File["${path}/config/vars"],
                        Django::Tools::Collectstatic[$path]
                     ],
    }

    service {'nginx':
        ensure    => running,
        enable    => true,
        subscribe => Service[$proj_name],
    }
}
