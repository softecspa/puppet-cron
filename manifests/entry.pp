# == Define: cron::entry
#
# Standard entry in our cron system
# Stdout for command is redirected, to
#   /var/log/cron/${frequency}/$name.stdout.log,
# and stderr to
#   /var/log/cron/${frequency}/$name.stderr.log
#
# A logrotate definition is added for all logs.
#
#
# === Parameters
#
# Supported parameters:
#
# [*frequency*]
#   By default the following frequencies are defined:
#     * frequently: executes every 2 minutes
#     * bihourly: executes twice per hour
#     * 4hours : executes 4 times per hour
#     * daily: executes once a day
#     * weekly: executes once a week
#     * monthly: executes once a month
#   But you can have more frequency defined
#
# [*command*]
#   The command to execute
#
# [*user*]
#   The user that executes the command.
#   Defaults to "root"
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
# [*ensure*]
#   Valid values 'present' or 'absent'
#
# === Examples
#
#   cron::entry {"prova":
#     frequency => "frequently",
#     user => "www-data",
#     command => "ls && echo >&2 'test stderr'",
#     workdir => "/tmp",
#     nice => "10",
#     ionice_cls => "1",
#     ionice_prio => "5"
#   }
#
# === Copyright
#
# Copyright 2011-2012 Softec SpA.
#
define cron::entry(
  $frequency,
  $command,
  $user         = 'root',
  $workdir      = '/',
  $nice         = '19',
  $ionice_cls   = '2',
  $ionice_prio  = '7',
  $ensure       = present,
  $path         = false
) {
  include cron

  $directory = "/etc/cron.${frequency}"
  $logdir = "/var/log/cron/${frequency}"
  $stdout_log = "${logdir}/${name}.stdout.log"
  $stderr_log = "${logdir}/${name}.stderr.log"

  if $path {
    $script_path = $path
  } else {
    $script_path = $cron::default_path
  }

  file {"${directory}/${name}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'admin',
    mode    => '0750',
    content => template('cron/entry.erb'),
    require => Cron::Frequency[$frequency]
  }
}

