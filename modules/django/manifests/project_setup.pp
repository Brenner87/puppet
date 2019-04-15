class django::project_setup (
    $params,
    $secret
)
{
    #include python


    $allowed_hosts = $params['proj_allowed_hosts']
    $proj_name     = $params['proj_name']
    $db_addr       = $params['proj_db_addr']
    $path          = $params['proj_path']
    $log           = "${path}/logs/${proj_name}.log"
    $src           = $params['proj_src']
    $is_prod       = $params['is_prod']
    $db_port       = $params['db_port']
    $db_user       = $params['db_user']
    $db_name       = $params['db_name']
    $user          = $params['user']
    $group         = $params['group']
    $python        = $params['python'] 
    $uwsgi_port    = $params['uwsgi_port']
    $uwsgi_addr    = $params['uwsgi_addr']
    $static        = $params['static']
    $web_serv_addr = $params['web_server_addr']
    $db_pass       = $secret['db_pass']
    $db_key        = $secret['db_key']
    $super_pass    = $secret['superuser_pass']

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
        python    => $python,
        subscribe => Python::Update_pip['update-pip']
    }  

    python::create_venv {"${path}/env":
        python  => $python,
        owner   => $user,
        require => Python::Install_pip_module['virtualenv']
    }

    python::install_pip_module {'uwsgi':
        python    => $python,
        venv      => "${path}/env",
        owner     => $user,
        subscribe => Python::Create_venv["${path}/env"]
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
        python    => $python,
        venv      => "${path}/env",
        owner     => $user,
        req_file  => "${path}/www/requirements.txt",
        require   => Python::Create_venv["${path}/env"],
        subscribe => Vcsrepo["${path}/www"]                    
   }

   django::tools::migrate_db{$path:
        user          => $params['user'],
        group         => 'nginx',
        is_prod       => $is_prod,
        db_pass       => $db_pass,
        db_key        => $db_key,
        allowed_hosts => $allowd_hosts,
        db_addr       => $db_addr,
        db_port       => $db_port,
        db_user       => $db_user,
        db_name       => $db_name,
        require       => Python::Install_pip_module['requirements.txt'], 
        subscribe => Vcsrepo["${path}/www"]
   }

    django::tools::create_superuser{$path:
        user          => $params['user'],
        group         => 'nginx',
        is_prod       => $is_prod,
        db_pass       => $db_pass,
        db_key        => $db_key,
        allowed_hosts => $allowd_hosts,
        db_addr       => $db_addr,
        db_port       => $db_port,
        db_user       => $db_user,
        db_name       => $db_name,
        super_user      => $user,
        pass      => $super_pass,
        require   => Python::Install_pip_module['requirements.txt'],
        subscribe => Vcsrepo["${path}/www"]
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
        owner   => $params['user'],
        group   => $params['group'],
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
        user          => $params['user'],
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
