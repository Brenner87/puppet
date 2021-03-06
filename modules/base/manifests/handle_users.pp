class base::handle_users ($auth_keys, $users, $groups){

  $groups.each |$groupname, $attr|{
    group {$groupname:
      * => $attr,
      }
  }

  $users.each |$username, $attrs| {
    user {$username:
      * => $attrs
    }
  }

  $auth_keys.each |$username, $item| {
    [$type, $key, $def] = split($item, ' ')
    ssh_authorized_key {$def:
      ensure => present,
      user   => $username,
      type   => $type,
      key    => $key,
    }
  }
}
