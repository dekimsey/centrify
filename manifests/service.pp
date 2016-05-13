# == Class centrify::service
#
# This class is meant to be called from centrify.
# It ensure the service is running.
#
class centrify::service {
  service { 'centrifydc':
    ensure     => running,
    name       =>  $::centrify::dc_service_name,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  service { 'centrify-sshd':
    ensure     => $::centrify::sshd_service_ensure,
    name       => $::centrify::sshd_service_name,
    enable     => false,
    hasstatus  => true,
    hasrestart => true,
  }
}
