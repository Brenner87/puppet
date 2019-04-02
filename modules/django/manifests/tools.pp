class django::tools {
    define collectstatic (
            $proj_path=$title,
            $user='root',
            $group='root',
            $is_prod=false,
            $db_pass='',
            $db_key='',
            $allowed_hosts='',
            $db_addr='127.0.0.1',
            $db_port='5432',
            $db_user,
            $db_name
    ){
        $command="/bin/echo yes | ${proj_path}/env/bin/python ${proj_path}/www/manage.py collectstatic"
        Exec {$command:
            user        => $user,
            group       => $group,
            environment => [
                    "IS_PROD=${is_prod}",
                    "DB_QUIZPOINT_PASS=${db_pass}", 
                    "DB_QUIZPOINT_KEY=${db_key}",
                    "DB_NAME=${db_name}",
                    "DB_USER=${db_user}",
                    "DB_PORT=${db_port}",
                    "PROJ_ALLOWED_HOSTS=${allowed_hosts}",
                    "PROJ_DB_ADDR=${db_addr}"
            ]
        }     
    }
}
