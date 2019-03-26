class django
{
    include django::quizpoint
    yum::group{ 'development':
        ensure  => 'present',
        timeout => 600,
    }   
}
