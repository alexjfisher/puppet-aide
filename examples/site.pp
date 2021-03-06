node default {
  class { 'aide':
    minute => 0,
    hour   => 1,
  }
  aide::rule { 'MyRule':
    rules => [ 'p', 'sha256'],
  }
  aide::watch { '/etc':
    path  => '/etc',
    rules => 'MyRule'
  }
  aide::watch { '/boot':
    path  => '/boot',
    rules => 'MyRule'
  }

}
