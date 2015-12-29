class cron (
){

  $lockdir = '/var/lock'
  $logdir = '/var/log/cron'
  $runparts = '/bin/run-parts'
  $libdir = '/var/lib/cron'

  $customdir = '/etc/cron.d'
  $customlogdir = "${logdir}/cron.d"

  $default_path = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

  File {
    require => Service['cron']
  }

  package {'cron':
    ensure  => installed
  }

  service { 'cron':
    ensure  => running,
    enable  => true,
    require => Package['cron']
  }

  file {
    '/etc/crontab':
      ensure  => present,
      owner   => root,
      group   => admin,
      mode    => '0664',
      content => template('cron/crontab.erb');
    $customdir:
      ensure  => directory,
      owner   => root,
      group   => admin,
      mode    => '02775';
    $logdir:
      ensure  => directory,
      owner   => root,
      group   => admin,
      mode    => '02775';
    $customlogdir:
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => '01777';
    $libdir:
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => '0775';
    $lockdir:
      ensure  => directory,
      group   => root,
      mode    => '1777';
  }

  logrotate::file {'puppet-cron-logs-custom':
    log           => "${customlogdir}/*.log",
    interval      => 'daily',
    rotation      => '14',
    options       => ['missingok', 'compress', 'notifempty'],
    archive       => true,
    require       => File[$customlogdir]
  }

  # Cron pattern used here:
  # http://projects.puppetlabs.com/projects/1/wiki/Cron_Patterns
  #
  # execute "night" jobs between 5 and 7 AM,
  # at different minutes but in the same hour.
  $hour = ip_to_cron(1, 3) + 5
  $minutes = ip_to_cron(4)

  Cron::Frequency {
  }

  cron::frequency {'hourly':
    minute => $minutes[0],
    hour   => '*',
  }
  cron::frequency {'daily':
    hour    => $hour,
    minute  => $minutes[1],
  }
  cron::frequency {'weekly':
    hour    => $hour,
    minute  => $minutes[2],
    weekday => 7,
  }
  cron::frequency {'monthly':
    hour      => $hour,
    minute    => $minutes[3],
    monthday  => 1,
  }

  # frequently: every 5 minutes
  cron::frequency {'frequently':
    minute => ip_to_cron(12),
  }

  # two times in a hour
  cron::frequency {'bihourly':
    minute => ip_to_cron(2),
  }

  # 4 times in a day
  cron::frequency {'4hours':
    minute  => ip_to_cron(1),
    hour    => ip_to_cron(6,24),
  }

}

