define activemq::user(
$ensure='present',
$username='undef',
$password='undef',
$groups=''
) {
  if $username == 'undef' {
    $r_user = $name
  } else {
    $ruser = $username
  }

  if is_array($groups){
    $r_groups = join($groups,',')
  } else {
    $r_groups = $groups
  }

  if $ensure == 'present' {
    if $password == 'undef' {
      fail("password must be specified for activemq user ${r_user}")
    }

    augeas{"amquser-${name}":
      lens    => 'Xml.lns',
      incl    => $activemq::config::path,
      context => "/files/${activemq::config::path}/beans/broker/plugins/simpleAuthenticationPlugin/users",
      changes => "set authenticationUser[last()+1]/#attribute/username '${r_user}'",
      onlyif  => "match authenticationUser[#attribute/username = '${r_user}'] size == 0",
    }

    augeas{"amquser-${name}-atts":
      lens    => 'Xml.lns',
      incl    => $activemq::config::path,
      context => "/files/${activemq::config::path}/beans/broker/plugins/simpleAuthenticationPlugin/users",
      changes => [
        "set authenticationUser[#attribute/username = '${r_user}']/#attribute/password '${password}'",
        "set authenticationUser[#attribute/username = '${r_user}']/#attribute/groups '${r_groups}'"
      ],
      require => Augeas["amquser-${name}"],
    }
 
  } else {
    augeas{"amquser-${name}":
      lens    => 'Xml.lns',
      incl    => $activemq::config::path,
      context => "/files/${activemq::config::path}/beans/broker/plugins/simpleAuthenticationPlugin/users",
      changes => "rm authenticationUser[/#attribute/username = '${r_user}']",
    }
  }
}


