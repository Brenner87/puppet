class postgres::quizpoint{
    contain class{'postgres::proj_db_setup':
        proj_name => 'quizpoint'
    }
}
