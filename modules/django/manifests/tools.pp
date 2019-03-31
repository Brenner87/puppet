class django::tools {
    define collectstatic (
            $proj_path=$title,
            $user='root',
            $group='root',
    ){
        $command="/bin/echo yes | ${proj_path}/env/bin/python ${proj_path}/www/manage.py collectstatic"
        Exec {$command:
            user  => $user,
            group => $group,
        }     
    }
}
