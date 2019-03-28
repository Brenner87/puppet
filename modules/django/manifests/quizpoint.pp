class django::quizpoint (
    $quizpoint_params,
    $quizpoint_secret
)
{
    django::install_python { "proj_python":
        python => $quizpoint_params['python']
        }
       
}
