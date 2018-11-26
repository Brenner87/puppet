class role::jenkins{
    include base
    include docker
    include jenkins

    include Class['base']->Class['docker']->Class['jenkins']
}
