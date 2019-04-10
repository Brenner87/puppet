class puppetmaster ($puppet_version){
    package {'puppetserver':
        ensure => $puppet_version,
    }

    service {'puppetserver':
        ensure => 'running',
        enable => true,
    }
}
