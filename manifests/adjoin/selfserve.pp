# == Class centrify::adjoin::password
#
# This class is called from centrify for
# joining AD using a username and password.
class centrify::adjoin::selfserve {

  $_user           = $::centrify::join_user
  $_domain         = $::centrify::domain
  $_container      = $::centrify::container
  $_zone           = $::centrify::zone
  $_extra_args     = $::centrify::extra_args
  $_precreate      = $::centrify::precreate
  $_selfserve_rodc = $::centrify::selfserve_rodc

  $_default_join_opts = ["-u '${_user}'", "-s '${_selfserve_rodc}'", '--selfserve' ]

  if $_container {
    $_container_opt = "-c '${_container}'"
  } else {
    $_container_opt = ''
  }

  if $_zone {
    $_zone_opt = "-z '${_zone}'"
    $_join_opts = delete(concat($_default_join_opts, $_zone_opt, $_container_opt, $_extra_args), '')
    $_options = join($_join_opts, ' ')
    $_command = "adjoin -V ${_options} '${_domain}'"
  } else {
    $_join_opts = delete(concat($_default_join_opts, $_container_opt, $_extra_args), '')
    $_options = join($_join_opts, ' ')
    $_command = "adjoin -w ${_options} '${_domain}'"
  }

  if $_precreate {
    $_precreate_command = "${_command} -P"
    exec { 'adjoin_precreate_with_selfserve':
      path    => '/usr/bin:/usr/sbin:/bin',
      command => $_precreate_command,
      unless  => "adinfo -d | grep ${_domain}",
      before  => Exec['adjoin_with_selfserve'],
    }
  }

  exec { 'adjoin_with_selfserve':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => $_command,
    unless  => "adinfo -d | grep ${_domain}",
    notify  => Exec['run_adflush_and_adreload'],
  }

  exec { 'run_adflush_and_adreload':
    path        => '/usr/bin:/usr/sbin:/bin',
    command     => 'adflush && adreload',
    refreshonly => true,
  }
}