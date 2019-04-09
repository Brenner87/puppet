class postgres {
    class { 'postgresql::server':
        postgres_password => '111',
        package_name      => 'postgresql11-server'
    }

    postgresql::server::db { 'quizpoint':
        user      => 'quizpoint',
        password  => postgresql_password('quizpoint', '123'),
        subscribe => Class['postgresql::server']
    }


    postgresql::server::pg_hba_rule { 'allow quizpoint access':
        description        => 'Open access from web server',
        type               => 'host',
        database           => 'quizpoint',
        user               => 'quizpoint',
        address            => '192.168.56.113',
        auth_method        => 'md5',
        subscribe          => Postgresql::Server::Db['quizpoint']
    }

    postgresql::server::pg_hba_rule { 'allow quizpoint access from local host':
        description        => 'Open access from local host',
        type               => 'host',
        database           => 'quizpoint',
        user               => 'quizpoint',
        address            => '127.0.0.1',
        auth_method        => 'md5',
        subscribe          => Postgresql::Server::Db['quizpoint']
    }
    postgresql::server::config_entry { 'listen_addresses':
        value => $fqdn,
        subscribe          => Postgresql::Server::Db['quizpoint']
}
}
