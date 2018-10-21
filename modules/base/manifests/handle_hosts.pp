class base::handle_hosts($hosts){
    $hosts.each |$host, $attrs| {
        host {$host:
        * => $attrs
        }
    }
}
