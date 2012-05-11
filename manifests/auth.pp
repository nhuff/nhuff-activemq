define activemq::auth(
$ensure='present',
$queue='undef',
$topic='undef',
$read='undef',
$write='undef',
$admin='undef'
) {

  if $queue == 'undef' and $topic == 'undef' {
    fail('Either a topic or a queue must be set for an activemq auth')
  } elsif ($queue != 'undef' and $topic != 'undef') {
    fail('Either a topic or a queue must be set for an activemq auth not both')
  } elsif ($queue != 'undef') {
    $q_or_t = 'queue'
    $obj_name = $queue
  } else {
    $q_or_t = 'topic'
    $obj_name = $topic
  }

  if is_array($read) {
    $r_read = join($read,',')
  } else {
    $r_read = $read
  }

  if is_array($write) {
    $r_write = join($write,',')
  } else {
    $r_write = $write
  }

  if is_array($admin) {
    $r_admin = join($admin,',')
  } else {
    $r_admin = $admin
  }

  
  if $ensure == 'present' {
    if $r_read == 'undef' or $r_write == 'undef' or $r_admin == 'undef' {
      fail("Need to define rights for activemq auth '${name}'")
    }

    augeas{"amqauth-${name}":
      lens    => 'Xml.lns',
      incl    => $activemq::config::path,
      context => "/files/${activemq::config::path}/beans/broker/plugins/authorizationPlugin/map/authorizationMap/authorizationEntries",
      changes => "set authorizationEntry[last()+1]/#attribute/${q_or_t} '${obj_name}'",
      onlyif  => "match authorizationEntry[#attribute/${q_or_t} = '${obj_name}'] size == 0",
    }

    augeas{"amqauth-${name}-attrs":
      lens    => 'Xml.lns',
      incl    => $activemq::config::path,
      context => "/files/${activemq::config::path}/beans/broker/plugins/authorizationPlugin/map/authorizationMap/authorizationEntries",
      changes => [
        "set authorizationEntry[#attribute/${q_or_t} = '${obj_name}']/#attribute/read '${r_read}'",
        "set authorizationEntry[#attribute/${q_or_t} = '${obj_name}']/#attribute/write '${r_write}'",
        "set authorizationEntry[#attribute/${q_or_t} = '${obj_name}']/#attribute/admin '${r_admin}'",
        "set authorizationEntry[#attribute/${q_or_t} = '${obj_name}']/#attribute/admin '${r_admin}'"
      ],
      require => Augeas["amqauth-${name}"],
    }

  } else {
    
    augeas{"amqauth-${name}":
      lens    => 'Xml.lns',
      incl    => $activemq::config::path,
      context => "/files/${activemq::config::path}/beans/broker/plugins/authorizationPlugin/map/authorizationMap/authorizationEntries",
      changes => "rm authorizationEntry[#attribute/${q_or_t} = '${obj_name}']",
    }
  }
}
