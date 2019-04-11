node default {
    notify {'This is production environment':}
    include base
}

node /^jenkins.*vagrant\.com/ {
    notify {'This is production environment':}
    include 'role::jenkins'
}

node /^puppetmaster.*vagrant\.com/ {
    notify {'This is production environment':}
    include 'role::puppetmaster'
}

node /^web.*vagrant\.com/ {
    notify {'This is production environment':}
    include 'role::web'
    include 'role::django'
}

node /^db.*vagrant\.com/ {
    notify {'This is production environment':}
    include 'role::postgres'
}

node /^quizpoint.*vagrant\.com/ {
    notify {'This is production environment':}
    contain 'role::postgres'
    contain 'role::web'
    contain 'django::quizpoint'
    Class['role::postgres']->Class['role::web']->Class['django::quizpoint']
}
