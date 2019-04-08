class postgres {
    class { 'postgresql::server':
        postgres_password          => '111',
    }
  }
