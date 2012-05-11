define activemq::transport (
$ensure='present',
$transport_name='undef',
$uri='undef'
) {

  if $transport_name == 'undef' {
    $r_transport_name = $name
  }

  if $ensure == 'present' {
    if $uri == 'undef' {
      fail("uri must be set for activemq transport ${r_transport_name}")
    }

    augeas{"amqtrans-${name}":
      lens    => 'Xml.lns',
      incl    => '/etc/activemq/activemq.xml',
      context => '/files/etc/activemq/activemq.xml/beans/broker/transportConnectors',
      changes => [
        "set transportConnector[last()+1]/#attribute/name ${r_transport_name}",
        "set transportConnector[#attribute/name='${r_transport_name}']/#attribute/uri ${uri}",
      ],
      onlyif  => "match transportConnector[#attribute/uri = '${uri}'] size == 0",
    }
  } else {
    augeas{"amqtrans-${name}":
      lens    => 'Xml.lns',
      incl    => '/etc/activemq/activemq.xml',
      context => '/files/etc/activemq/activemq.xml/beans/broker/transportConnectors',
      changes => "rm transportConnector[#attribute/name = '${r_transport_name}']",
    }
  }
}
