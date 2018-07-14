##/etc/puppet/modules/buildbot_asf/manifests/init.pp

class buildbot_asf (

  $uid                           = 8996,
  $gid                           = 8996,
  $group_present                 = 'present',
  $groupname                     = 'buildmaster',
  $groups                        = [],
  $service_ensure                = 'running',
  $service_name                  = 'buildbot',
  $shell                         = '/bin/bash',
  $user_present                  = 'present',
  $username                      = 'buildmaster',
  $required_packages             = ['python-mysqldb', 'buildbot'],

  # list of passwords
  $master_list                   = {},

  # override below in yaml
  $buildbot_base_dir             = '',
  $buildmaster_work_dir          = '',
  $connector_port                = '',
  $slave_port_num                = '',
  $mail_from_addr                = '',
  $projectName                   = '',
  $project_url                   = '',
  $change_horizon                = '',
  $build_horizon                 = '',
  $event_horizon                 = '',
  $log_horizon                   = '',
  $build_cache_size              = '',
  $change_cache_size             = '',
  $projects_path                 = '',

  # below are contained in eyaml
  $db_url                        = '',
  $pbcsUser                      = '',
  $pbcsPwd                       = ''

){

  validate_hash($master_list)

# install required packages:
  package {
    $required_packages:
      ensure => 'present',
  }

# buildbot specific

  user {
    $username:
      ensure     => $user_present,
      name       => $username,
      home       => "/x1/${username}",
      shell      => $shell,
      uid        => $uid,
      gid        => $groupname,
      groups     => $groups,
      managehome => true,
      require    => Group[$groupname],
  }

  group {
    $groupname:
      ensure => $group_present,
      name   => $groupname,
      gid    => $gid,
  }

  apt::pin { 'xenial-buildbot':
    ensure          => 'present',
    priority        => 1800,
    packages        => 'buildbot-0.8.12-3',
    before          => Package['buildbot'],
  }

  file {
    "/x1/${username}/master1/master.cfg":
      ensure  => 'present',
      owner   => $username,
      group   => $groupname,
      notify  => Exec['buildbot-reconfig'],
      content => template('buildbot_asf/master.cfg.erb');

    "/x1/${username}/master1/buildbot.tac":
      ensure  => 'present',
      owner   => $username,
      group   => $groupname,
      content => template('buildbot_asf/buildbot.tac.erb');

    "/x1/${username}/master1/private.py":
      ensure  => 'present',
      owner   => $username,
      group   => $groupname,
      mode    => '0640',
      content => template('buildbot_asf/private.py.erb');

# various required files

    "/x1/${username}/master1/templates":
      ensure => 'directory',
      mode   => '0755',
      owner  => $username,
      group  => $groupname;
    "/x1/${username}/master1/templates/root.html":
      ensure => 'present',
      mode   => '0664',
      owner  => $username,
      group  => $groupname,
      source => 'puppet:///modules/buildbot_asf/root.html';
    "/x1/${username}/master1/public_html/asf_logo_wide_2016.png":
      ensure => 'present',
      mode   => '0644',
      owner  => $username,
      group  => $groupname,
      source => 'puppet:///modules/buildbot_asf/asf_logo_wide_2016.png';
    "/x1/${username}/master1/public_html/bg_gradient.jpg":
      ensure => 'present',
      mode   => '0644',
      owner  => $username,
      group  => $groupname,
      source => 'puppet:///modules/buildbot_asf/bg_gradient.jpg';
    "/x1/${username}/master1/public_html/default.css":
      ensure => 'present',
      mode   => '0644',
      owner  => $username,
      group  => $groupname,
      source => 'puppet:///modules/buildbot_asf/default.css';
    "/x1/${username}/master1/public_html/favicon.ico":
      ensure => 'present',
      mode   => '0644',
      owner  => $username,
      group  => $groupname,
      source => 'puppet:///modules/buildbot_asf/favicon.ico';
    "/x1/${username}/master1/public_html/style.css":
      ensure => 'present',
      mode   => '0644',
      owner  => $username,
      group  => $groupname,
      source => 'puppet:///modules/buildbot_asf/style.css';
    "/x1/${username}/master1/public_html/robots.txt":
      ensure => 'present',
      mode   => '0644',
      owner  => $username,
      group  => $groupname,
      source => 'puppet:///modules/buildbot_asf/robots.txt';
    "/x1/${username}/master1/public_html/sitemap-index.xml":
      ensure => 'present',
      mode   => '0644',
      owner  => $username,
      group  => $groupname,
      source => 'puppet:///modules/buildbot_asf/sitemap-index.xml';
    "/x1/${username}/master1/configscanner.py":
      ensure => 'present',
      mode   => '0755',
      owner  => $username,
      group  => $groupname,
      source => 'puppet:///modules/buildbot_asf/configscanner.py';
    '/usr/lib/systemd/user/configscanner.service':
      ensure => 'present',
      mode   => '0755',
      owner  => $username,
      group  => $groupname,
      source => 'puppet:///modules/buildbot_asf/configscanner.ubuntu';


# required scripts for cron jobs

    "/x1/${username}/master1/config-update-check.sh":
      ensure => 'absent',
      mode   => '0755',
      owner  => $username,
      group  => $groupname;
    "/x1/${username}/master1/create-master-index.sh":
      ensure => 'present',
      mode   => '0755',
      owner  => $username,
      group  => $groupname,
      source => 'puppet:///modules/buildbot_asf/create-master-index.sh';
    "/x1/${username}/master1/public_html/projects/openoffice/":
      ensure => 'directory',
      mode   => '0755',
      owner  => $username,
      group  => $groupname;
    "/x1/${username}/master1/public_html/projects/openoffice/create-ooo-snapshots-index.sh":
      ensure => 'present',
      mode   => '0755',
      owner  => $username,
      group  => $groupname,
      source => 'puppet:///modules/buildbot_asf/create-ooo-snapshots-index.sh';
    "/x1/${username}/master1/public_html/projects/xmlgraphics/fop/create-fop-snapshots-index.sh":
      ensure => 'present',
      mode   => '0755',
      owner  => $username,
      group  => $groupname,
      source => 'puppet:///modules/buildbot_asf/projects/create-fop-snapshots-index.sh';
    "/x1/${username}/master1/public_html/projects/xmlgraphics/batik/create-batik-snapshots-index.sh":
      ensure => 'present',
      mode   => '0755',
      owner  => $username,
      group  => $groupname,
      source => 'puppet:///modules/buildbot_asf/projects/create-batik-snapshots-index.sh';
    "/x1/${username}/master1/public_html/projects/xmlgraphics/commons/create-commons-snapshots-index.sh":
      ensure => 'present',
      mode   => '0755',
      owner  => $username,
      group  => $groupname,
      source => 'puppet:///modules/buildbot_asf/projects/create-commons-snapshots-index.sh';
    "/x1/${username}/master1/public_html/projects/subversion/nightlies/create-subversion-nightlies-index.sh":
      ensure => 'present',
      mode   => '0755',
      owner  => $username,
      group  => $groupname,
      source => 'puppet:///modules/buildbot_asf/projects/create-subversion-nightlies-index.sh';
  }

# cron jobs

  cron {
    'create-master-index':
      user        => $username,
      minute      => 30,
      command     => "/x1/${username}/master1/create-master-index.sh",
      environment => "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin\nSHELL=/bin/sh", # lint:ignore:double_quoted_strings
      require     => User[$username];
    'create-ooo-snapshots-index':
      user        => $username,
      minute      => 40,
      hour        => 5,
      command     => "/x1/${username}/master1/public_html/projects/openoffice/create-ooo-snapshots-index.sh",
      environment => "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin\nSHELL=/bin/sh", # lint:ignore:double_quoted_strings
      require     => User[$username];
    'create-fop-snapshots-index':
      user        => $username,
      minute      => '10',
      hour        => '10',
      command     => "/x1/${username}/master1/public_html/projects/xmlgraphics/fop/create-fop-snapshots-index.sh",
      environment => "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin\nSHELL=/bin/sh", # lint:ignore:double_quoted_strings
      require     => User[$username];
    'create-batik-snapshots-index':
      user        => $username,
      minute      => '15',
      hour        => '10',
      command     => "/x1/${username}/master1/public_html/projects/xmlgraphics/batik/create-batik-snapshots-index.sh",
      environment => "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin\nSHELL=/bin/sh", # lint:ignore:double_quoted_strings
      require     => User[$username];
    'create-commons-snapshots-index':
      user        => $username,
      minute      => '20',
      hour        => '10',
      command     => "/x1/${username}/master1/public_html/projects/xmlgraphics/commons/create-commons-snapshots-index.sh",
      environment => "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin\nSHELL=/bin/sh", # lint:ignore:double_quoted_strings
      require     => User[$username];
    'create-subversion-nightlies-index':
      user        => $username,
      minute      => '5',
      hour        => '4',
      command     => "/x1/${username}/master1/public_html/projects/subversion/nightlies/create-subversion-nightlies-index.sh",
      environment => "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin\nSHELL=/bin/sh", # lint:ignore:double_quoted_strings
      require     => User[$username];
  }

# execs

  exec {
    'buildbot-reconfig':
      command     => "/usr/bin/buildbot reconfig /x1/${username}/master1",
      onlyif      => "/usr/bin/buildbot checkconfig /x1/${username}/master1",
      refreshonly => true,
}

}


# Buildbot config scanner app
service { 'configscanner':
        ensure    => 'running',
        enable    => true,
        hasstatus => true,
        subscribe => [
          File['/x1/buildmaster/master1/configscanner.py']
        ]
    }
