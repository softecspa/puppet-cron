# == Define: cron::frequency
#
# You can define a frequency by using cron::frequency define.
# Once defined, you can use it as a frequency target to cron::entry.
#
# === Parameters
#
# cron::frequency accepts the following paramenters:
#
# [*minute*]
# [*hour*]
# [*monthday*]
# [*weekday*]
# [*month*]
# [*special*]
#   Same meaning as the default cron puppet type, look at
#   http://docs.puppetlabs.com/references/stable/type.html#cron
#   This values must be specified
#
# [*ensure*]
#   Valid values present or absent. Defaults to present.
#
# [*logrotate_interval*]
#   When to rotate logs using logrotate. Defaults to daily.
#
# [*logrotate_keep*]
#   How many logs to keep rotated. Default to 14.
#
# [*path*]
#   Environment variable with the same name. Default to ${cron::default_path}
#
# === Examples
#
#  cron::frequency {"midnight":
#    minute => "0",
#    hour => "0"
#  }
#
# === Copyright
#
# Copyright 2011-2012 Softec Spa, unless otherwise noted.
#
define cron::frequency(
  $hour                   = undef,
  $minute                 = undef,
  $month                  = undef,
  $monthday               = undef,
  $weekday                = undef,
  $special                = undef,
  $logrotate_interval     = 'daily',
  $logrotate_keep         = '14',
  $ensure                 = present,
  $path                   = false,
  )
{
  $crondir = "/etc/cron.${name}"
  $logdir = "${cron::logdir}/${name}"
  $lockfile = "${cron::lockdir}/cron_${name}.lock"
  $ensure_d = $ensure ? {
    present => directory,
    default => absent
  }
  if $path {
    $env = ["PATH=${path}"]
  } else {
    $env = ["PATH=${cron::default_path}"]
  }

  file {$crondir:
    ensure  => $ensure_d,
    owner   => root,
    group   => admin,
    mode    => '2775',
    require => File['/etc/crontab']
  }

  file {$logdir:
    ensure  => $ensure_d,
    owner   => root,
    group   => root,
    mode    => '1777',
    require => File[$cron::logdir]
  }

  logrotate::file {"puppet-cron-logs-${name}":
    log      => "${logdir}/*.log",
    interval => $logrotate_interval,
    rotation => $logrotate_keep,
    options  => ['missingok', 'compress', 'notifempty'],
    archive  => true,
    require  => File[$logdir]
  }

  cron {"cron-${name}":
    ensure      => $ensure,
    command     => "flock -x -n -o ${lockfile} -c '${cron::runparts} --report ${crondir}'",
    user        => 'root',
    minute      => $minute,
    hour        => $hour,
    monthday    => $monthday,
    special     => $special,
    weekday     => $weekday,
    environment => $env,
    require     => File[$crondir]
  }
}
