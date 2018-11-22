class jenkins {
    include jenkins::maven
    include jenkins::install
    include jenkins::config
    include jenkins::service

    include Class[jenkins::maven] -> Class[jenkins::install] -> Class[jenkins::config] ~> Class[jenkins::service]
}
