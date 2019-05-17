class docker:service {
    service {"docker":
        ensure => 'running',
        enable => true,
    }
}
