class jenkins {
    include docker
    include jenkins::maven
    include jenkins::install
    include jenkins::config
    include jenkins::service

    include Class[docker] -> Class[jenkins::maven] -> Class[jenkins::install] -> Class[jenkins::config] ~> Class[jenkins::service]
}
