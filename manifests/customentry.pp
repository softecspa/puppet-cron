# == Define: cron::customentry
#
# You can have a completely custom entry using the cron::customentry define,
# which uses the cron.d directory
#
# === Parameters
#
# [*command*]
#   The command to execute
#
# [*ensure*]
#   Valid values present or absent. Defaults to present.
#
# [*user*]
#   The user that executes the command.
#   Defaults to "root"
#
# [*minute*]
# [*hour*]
# [*monthday*]
# [*weekday*]
# [*month*]
#   Same meaning as the default http://docs.puppetlabs.com/references/stable/type.htm
#   This values defaults to '*'
#
# [*special*]
#   You can use cron shortcut names (without the @ char), as explained in 'man 5 crontab'
#
# [*path*]
#   Environment variable with the same name. Default to ${cron::default_path}
#
# [*workdir*]
#   The working directory when running the command.
#   Defaults to "/"
#
# [*nice*]
#   The nice value. If nil or false no renicing is done
#   Defaults to 19.
#
# [*ionice_cls*]
#   Ionice class for the command. If nil or false ionice
#   class is not changed (ionice_prio gets ignored too)
#   Defaults to 2.
#
# [*ionice_prio*]
#   Ionice priority inside the ionice class.
#   Defaults to 7.
#
# === Examples
#
# cron::customentry { 'prova':
#    minute => '*/2',
#    user => 'www-data',
#    command => "ls && echo >&2 'test stderr'",
#    workdir => '/tmp',
# }
#
# cron::customentry { 'prova':
#    special => 'hourly',
#    user => 'www-data',
#    command => 'ls && echo >&2 "test stderr"',
#    workdir => '/tmp',
# }
#
# creates the file /etc/cron.d/prova
#
# === Copyright
#
# Copyright 2007-2012 Softec SpA, unless otherwise noted.
#
define cron::customentry(
  $command,
  $user='root',
  $workdir='/',
  $nice='19',
  $ionice_cls='2',
  $ionice_prio='7',
  $ensure=present,
  $hour='*',
  $minute='*',
  $month='*',
  $monthday='*',
  $weekday='*',
  $special=false,
  $path=false,
  $mailto='',
  $comment='',
  )
{
  include cron
  $logdir = $cron::customlogdir
  $script = "$cron::libdir/${name}"
  $stdout_log = "${logdir}/${name}.stdout.log"
  $stderr_log = "${logdir}/${name}.stderr.log"

  if $path {
    $script_path = $path
  } else {
    $script_path = $cron::default_path
  }

  file {
  $script:
    ensure  => $ensure,
    owner   => 'root',
    group   => 'admin',
    mode    => '0750',
    content => template('cron/entry.erb'),
    require => File[$cron::customlogdir];
  "$cron::customdir/${name}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'admin',
    mode    => '0750',
    content => template('cron/cron.d.entry.erb'),
    require => File[$script]
  }
}
