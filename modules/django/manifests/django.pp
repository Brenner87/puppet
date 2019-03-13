class django (
    $proj_allowed_hosts,
    $proj_url,
    $proj_name,
    $proj_db_addr,
    $proj_path,
    $wsgi_cong,
    $is_prod,
    $db_port,
    $db_user,
    $db_name,
    $db_password,
    $db_key,
    $user,
    $group,
    $python,)
{
    yum::group{ 'development':
        ensure  => 'present',
        timeout => 600,
    }   
}
