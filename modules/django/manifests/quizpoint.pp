class django::quizpoint (
    $quizpoint_params,
    $quizpoint_secret
)
{
    class {'django::project_setup':
        params => $quizpoint_params
        secret => $quizpoint_secret
    }
}
