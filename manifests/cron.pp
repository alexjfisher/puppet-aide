# Class for managing aide's cron job.
class aide::cron (
  $aide_path,
  $minute,
  $hour,
  $nocheck,
  $mailto,
) {

  if $nocheck == true {
    $cron_ensure = 'absent'
  } else {
    $cron_ensure = 'present'
  }

  if $mailto != undef {
    cron { 'aide':
      ensure  => $cron_ensure,
      command => "${aide_path} --check | /bin/mail -s \"\$(hostname) - AIDE Integrity Check\" ${mailto}",
      user    => 'root',
      hour    => $hour,
      minute  => $minute,
    }
  } else {
    cron { 'aide':
      ensure  => $cron_ensure,
      command => "${aide_path} --check",
      user    => 'root',
      hour    => $hour,
      minute  => $minute,
    }
  }
}
