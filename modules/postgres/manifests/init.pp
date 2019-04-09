class postgres 
(
    $params=undef,
    $postgres_pass=undef
){

    include postgres::quizpoint
    class { 'postgresql::globals':
        version             => $params['version'],
        manage_package_repo => true,
        encoding            => 'UTF8',
        }->
    class { 'postgresql::server':
        postgres_password => $postgres_pass,
        #package_name      => 'postgresql11-server'
    }->
    postgresql::server::config_entry { 'listen_addresses':
        value     => $fqdn,
        #require   => Class['postgresql::server']
    }
}
