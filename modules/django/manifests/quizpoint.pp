class django::quizpoint (
    $quizpoint_params,
    $quizpoint_secret
)
{
    #include python

    python::install_python { $quizpoint_params['python']: }

    python::update_pip { 'update-pip':
        python    => $quizpoint_params['python'],
        subscribe => Python::Install_python[$quizpoint_params['python']]
    }

    python::install_pip_module {'virtualenv':
        python  => $quizpoint_params['python'],
        module  => 'virtualenv',
        require =>Python::Update_pip['update-pip']
    }  

    user {$quizpoint_params['user']:
        ensure     => present,
        uid        => 1200,
        managehome => false,
    }



    file {$quizpoint_params['proj_path']:
        ensure  => directory,
        owner   => $quizpoint_params['user'],
        group   => 'nginx',
        require => User[$quizpoint_params['user']],
    }

    ['config','run_data','logs'].each |$dir| {

        file {"${quizpoint_params['proj_path']}/${dir}":
            ensure  => directory,
            owner   => $quizpoint_params['user'],
            group   => 'nginx',
            require => File[$quizpoint_params['proj_path']],
        }
    }


    file {"${quizpoint_params['proj_path']}/logs/${quizpoint_params['proj_name']}.log":
        ensure  => directory,
        owner   => $quizpoint_params['user'],
        group   => 'nginx',
        require => File["${quizpoint_params['proj_path']}/logs"],
    }
}
