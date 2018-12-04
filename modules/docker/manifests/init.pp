class docker {
    include docker::install
    include docker::service

    include Class[docker::install] ~> Class[docker::service]
}
