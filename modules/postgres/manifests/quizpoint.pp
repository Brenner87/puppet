class postgres::quizpoint{

    $params=hiera("django::quizpoint::quizpoint_params")
    $user_pass=hiera("django::quizpoint::quizpoint_secret")['db_pass']
    $web_server_addr=$params['web_server_addr']

    postgresql::server::db { $params['db_name']:
        user      => $params['db_user'],
        password  => postgresql_password($params['db_user'], $user_pass),
    }->
    postgresql::server::database_grant { params['db_name']:
        privilege => 'ALL',
        db        => $params['db_name'],
        role      => $params['db_user'],
    }->
    postgresql::server::pg_hba_rule { 'allow quizpoint access':
        description => 'Open access from web server',
        type        => 'host',
        database    => $params['db_name'],
        user        => $params['db_user'],
        address     => "${web_server_addr}/32",
        auth_method => 'md5',
    }
}
