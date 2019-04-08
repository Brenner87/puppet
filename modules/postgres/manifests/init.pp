class postgres {
    class { 'postgresql::server':
        postgres_password          => '111',
    }

    postgresql::server::db { 'quizpoint':
        user     => 'quizpoint',
        password => postgresql_password('quizpoint', '111'),
    }


    #    postgresql::server::pg_hba_rule { 'allow application network to access app database':
    #          description        => 'Open up postgresql for access from 200.1.2.0/24',
         type               => 'host',
         database           => 'quizpoint',
         user               => 'quizpoint',
         address            => '192.168.56.113',
         auth_method        => 'md5',
    #     target             => '/path/to/pg_hba.conf',
    #     postgresql_version => '9.4',
    #}

}
