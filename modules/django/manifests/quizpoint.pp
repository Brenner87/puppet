class django::quizpoint (
    $quizpoint_params,
    $quizpoint_secret
)
{
    #include python

    python::install_python { $quizpoint_params['python'] }

    python::update_pip { 'update-pip':
        python => $quizpoint_params['python'],
        require => Python::Install_python['proj_python']
    }

    python::install_pip_module {'virtualenv':
        python => $quizpoint_params['python'],
        module => 'virtualenv',
        require =>Python::Update_pip['update-pip']
    }   
}
