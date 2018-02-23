class varnish (
                $vcl_file,
                $vcl_default_file_path = '/etc/varnish/default.vcl',
                $listen                = '0.0.0.0',
                $port                  = '80',
                $backend               = 'malloc',
                $backend_opts          = '512m',
                $admin_listen          = '127.0.0.1',
                $admin_port            = '6082',
                $replace_vcl           = false,
              ) inherits varnish::params {

  validate_absolute_path($vcl_default_file_path)

  package { 'varnish':
    ensure => 'installed',
  }

  file { $vcl_default_file_path:
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => $vcl_file,
    notify  => Service['varnish'],
    require => Package['varnish'],
    replace => $replace_vcl,
  }

  if($varnish::params::sysconfig_file!=undef)
  {
    file { $varnish::params::sysconfig_file:
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("${module_name}/${varnish::params::sysconfig_template}"),
      notify  => Service['varnish'],
      require => Package['varnish'],
    }
  }

  service { 'varnish':
    ensure  => 'running',
    enable  => true,
    require => [ Package['varnish'], File[$vcl_default_file_path] ],
  }

}
