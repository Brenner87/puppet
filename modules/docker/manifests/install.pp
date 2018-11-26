class docker::install ($version='latest'){
    package {'docker-ce':
        ensure => $version,
    }
}
