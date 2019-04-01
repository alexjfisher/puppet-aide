# Class for managing aide's cron job.
class aide::cron (
  $aide_path,
  $conf_path,
  $minute,
  $hour,
  $nocheck,
  $mailto,
) {

  if $nocheck {
    $cron_ensure = 'absent'
  } else {
    $cron_ensure = 'present'
  }

  if $mailto {
    $command = "${aide_path} --config ${conf_path} --check | /usr/bin/mailx -s '${facts['fqdn']} - AIDE Integrity Check' ${mailto}"
  } else {
    $command = "${aide_path} --config ${conf_path} --check"
  }

  cron { 'aide':
    ensure  => $cron_ensure,
    command => $command,
    user    => 'root',
    hour    => $hour,
    minute  => $minute,
  }
}
