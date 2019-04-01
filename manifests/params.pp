# aide::params sets the default values for parameters.
class aide::params {
  $package         = 'aide'
  $mailto          = undef
  $version         = 'latest'
  $db_path         = '/var/lib/aide/aide.db'
  $db_temp_path    = '/var/lib/aide/aide.db.new'
  $gzip_dbout      = 'no'
  $hour            = 0
  $minute          = 0
  $aide_log        = '/var/log/aide/aide.log'
  $syslogout       = true
  $config_template = 'aide/aide.conf.erb'
  $cron_template   = 'aide/cron.erb'
  $nocheck         = false

  $default_rules = {
    'FIPSR'         => ['p','i','n','u','g','s','m','c','acl','selinux','xattrs','sha256'],
    'ALLXTRAHASHES' => ['sha1','rmd160','sha256','sha512','tiger'],
    'EVERYTHING'    => ['R','ALLXTRAHASHES'],
    'NORMAL'        => ['sha256'],
    'DIR'           => ['p','i','n','u','g','acl','selinux','xattrs'],
    'PERMS'         => ['p','u','g','acl','selinux','xattrs'],
    'STATIC'        => ['p','u','g','acl','selinux','xattrs','i','n','b','c','ftype'],
    'LOG'           => ['p','u','g','n','acl','selinux','ftype'],
    'CONTENT'       => ['sha256','ftype'],
    'CONTENT_EX'    => ['sha256','ftype','p','u','g','n','acl','selinux','xattrs'],
    'DATAONLY'      => ['p','n','u','g','s','acl','selinux','xattrs','sha256'],
  }
  case $::osfamily {
    'Debian': {
      $aide_path = '/usr/bin/aide'
      $conf_path = '/etc/aide/aide.conf'
    }
    'Redhat': {
      $aide_path = '/usr/sbin/aide'
      $conf_path = '/etc/aide.conf'
    }
    default: {
      $aide_path = '/usr/sbin/aide'
      $conf_path = '/etc/aide.conf'
      #fail("The ${module_name} module is not supported on an ${::osfamily} based system.")
    }
  }
}
