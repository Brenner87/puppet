class django
{
    yum::group{ 'development':
        ensure  => 'present',
        timeout => 600,
    }   
}
