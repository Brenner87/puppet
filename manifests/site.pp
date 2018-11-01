node default {
    notify {'This is production environment':}
    include base
}

node /^jenkins.*vagrant\.com/ {
    include 'role::jenkins'
}

node /^puppetmaster.*vagrant\.com/ {
    include 'role::puppetmaster'
}
