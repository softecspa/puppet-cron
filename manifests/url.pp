define cron::url (
  $url,
  $ensure             = present,
  $user               = 'www-data',
  $protocol           = 'http',
  $read_timeout       = '',
  $wget_output        = '/dev/null',
  $stdin_output       = false,
  $quiet              = true,
  $spider             = false,
  $timeout            = '',
  $no_http_keep_alive = false,
  $no_cookies         = false,
  $hour               = '*',
  $minute             = '*',
  $month              = '*',
  $monthday           = '*',
  $weekday            = '*',
  $login              = '',
  $pass               = '',
  $tries              = '',
  $mailto             = '',
  $comment            = '',
  $params             = '',
) {

  if $protocol !~ /^http(s)?$/ {
    fail ('protocol can be only http or https')
  }

  if (($login != '') and ($pass == '')) or (($login == '') and ($pass != '')) {
    fail ('login and pass must be blank or speficified togheter')
  }

  $user_pass = $login?{
    ''      => '',
    default => "${login}:${pass}@"
  }

  if $url !~ /^http(s)?/ {
    $real_url = "${protocol}://${user_pass}${url}"
  } else {
    $real_url = $url
  }

  $param_read_timeout = $read_timeout?{
    ''      => '',
    default => " --read-timeout=${read_timeout}"
  }

  $param_tries = $tries?{
    ''      => '',
    default => " --tries=${tries}"
  }

  $param_wget_output = $stdin_output?{
    false =>  $wget_output?{
                ''      => '',
                default => " -O $wget_output"
              },
    true  => ' -O-',
  }

  $param_timeout = $timeout?{
    ''      => '',
    default => " --timeout=${timeout}",
  }

  $param_spider = $spider? {
    false => '',
    true  => ' --spider'
  }

  $param_no_http_keep_alive = $no_http_keep_alive? {
    false => '',
    true  => ' --no-http-keep-alive',
  }

  $param_no_cookies = $no_cookies? {
    false => '',
    true  => ' --no-cookies'
  }

  $param_quiet = $quiet?{
    ''      => '',
    default => ' -q'
  }

  $other_params = $params?{
    ''      => '',
    default => " ${params}",
  }

  $cron_command = "wget \"${real_url}\"${param_tries}${param_read_timeout}${param_wget_output}${param_quiet}${param_timeout}${param_spider}${param_no_http_keep_alive}${param_no_cookies}${other_params}"

  cron::customentry{$name :
    ensure    => $ensure,
    command   => $cron_command,
    user      => $user,
    hour      => $hour,
    minute    => $minute,
    month     => $month,
    monthday  => $monthday,
    weekday   => $weekday,
    comment   => $comment,
    mailto    => $mailto
  }

}
