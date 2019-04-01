# the aide class manages some the configuration of aide
class aide (
  String[1] $package = $aide::params::package,
  String[1] $version = $aide::params::version,
  Stdlib::Unixpath $conf_path = $aide::params::conf_path,
  Stdlib::Unixpath $db_path = $aide::params::db_path,
  Stdlib::Unixpath $db_temp_path = $aide::params::db_temp_path,
  Integer[0,23] $hour = $aide::params::hour,
  Integer[0,59] $minute = $aide::params::minute,
  Enum['yes','no'] $gzip_dbout = $aide::params::gzip_dbout,
  Stdlib::Unixpath $aide_path = $aide::params::aide_path,
  Stdlib::Unixpath $aide_log = $aide::params::aide_log,
  Boolean $syslogout = $aide::params::syslogout,
  String $config_template = $aide::params::config_template,
  Boolean $nocheck = $aide::params::nocheck,
  Optional[String[1]] $mailto = undef,
  Hash $rules = {},
  Hash $watches = {},
  Hash $default_rules = $aide::params::default_rules,
  Boolean $use_default_rules = false,
) inherits aide::params {

  package { $package:
    ensure => $version,
  }

  class  { 'aide::config':
      conf_path       => $conf_path,
      db_path         => $db_path,
      db_temp_path    => $db_temp_path,
      gzip_dbout      => $gzip_dbout,
      aide_log        => $aide_log,
      syslogout       => $syslogout,
      config_template => $config_template,
      require         => Package[$package],
  }

  class  { 'aide::firstrun':
      aide_path    => $aide_path,
      conf_path    => $conf_path,
      db_temp_path => $db_temp_path,
      db_path      => $db_path,
      subscribe    => Class['aide::config'],
  }

  class  { 'aide::cron':
    aide_path => $aide_path,
    conf_path => $conf_path,
    minute    => $minute,
    hour      => $hour,
    nocheck   => $nocheck,
    mailto    => $mailto,
  }

  if $use_default_rules {
    $default_rules.each | String $rule_name, Array $rules | {
      aide::rule { $rule_name:
        rules => $rules,
        order => '03',
      }
    }
  }

  $rules.each | String $rule, Hash $attrs | {
    aide::rule { $rule:
      * => $attrs,
    }
  }

  $watches.each | String $watch, Hash $attrs | {
    aide::watch { $watch:
      * => $attrs,
    }
  }
}
