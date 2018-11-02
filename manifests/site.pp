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
