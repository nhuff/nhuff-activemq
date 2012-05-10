define activemq::transport (
$ensure='present',
$transport_name='undef',
$uri
) {

  if $transport_name == 'undef' {
    $r_transport_name = $name
  }

  if $ensure == 'present' {
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
