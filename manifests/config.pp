# Class: activemq::config
#
#   class description goes here.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class activemq::config (
  $memory_usage,
  $store_usage,
  $temp_usage,
  $ssl,
  $cacert,
  $cert,
  $key,
  $keystorepass,
  $path = '/etc/activemq/activemq.xml',
  $webconsole = false
) {

  validate_re($path, '^/')
  $path_real = $path

  if $webconsole {
    augeas{'amq-webconsole':
      lens    => 'Xml.lns',
      incl    => $path_real,
      context => "/files/${path_real}/beans",
      changes => 'set import[last()+1]/#attribute/resource "jetty.xml"',
      onlyif  => 'match import[#attribute/resource = "jetty.xml"] size == 0',
    } 
  } else {
    augeas{'amq-webconsole':
      lens    => 'Xml.lns',
      incl    => $path_real,
      context => "/files/${path_real}/beans",
      changes => 'rm import[#attribute/resource = "jetty.xml"]'
    }
  }
  
  augeas{'amq-memory':
    lens    => 'Xml.lns',
    incl    => $path_real,
    context => "/files/${path_real}/beans/broker/systemUsage/systemUsage",
    changes => "set memoryUsage/memoryUsage/#attribute/limit '${memory_usage}'",
  }

  augeas{'amq-storage':
    lens    => 'Xml.lns',
    incl    => $path_real,
    context => "/files/${path_real}/beans/broker/systemUsage/systemUsage",
    changes => "set storeUsage/storeUsage/#attribute/limit '${store_usage}'",
  }

  augeas{'amq-temp':
    lens    => 'Xml.lns',
    incl    => $path_real,
    context => "/files/${path_real}/beans/broker/systemUsage/systemUsage",
    changes => "set tempUsage/tempUsage/#attribute/limit '${temp_usage}'",
  }
   
  if $ssl {

    file{'/etc/activemq/genkeys.sh':
      ensure => 'file',
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
      source => 'puppet:///modules/activemq/genkeys.sh',
    }
  
    exec{'amq-keys':
      path    => '/etc/activemq:/bin:/usr/bin',
      command => "genkeys.sh ${cacert} ${key} ${cert} ${keystorepass}",
      creates => '/etc/activemq/truststore.jks',
      require => File['/etc/activemq/genkeys.sh'],
    }

    file{'/etc/activemq/truststore.jks':
      ensure  => 'file',
      owner   => 'root',
      group   => 'activemq',
      mode    => '0640',
      require => Exec['amq-keys'],
    }

    file{'/etc/activemq/keystore.jks':  
      ensure  => 'file',
      owner   => 'root',
      group   => 'activemq',
      mode    => '0640',
      require => Exec['amq-keys'],
    }

    augeas{'amq-ssl':
      lens    => 'Xml.lns',
      incl    => $path_real,
      context => "/files/${path_real}/beans/broker",
      changes => [
        'set sslContext/sslContext/#attribute/keyStore "keystore.jks"',
        'set sslContext/sslContext/#attribute/trustStore "truststore.jks"',
        "set sslContext/sslContext/#attribute/keyStorePassword '${keystorepass}'",
        "set sslContext/sslContext/#attribute/trustStorePassword '${keystorepass}'"
      ],
    }

  } else {
    augeas{'amq-ssl':
      lens    => 'Xml.lns',
      incl    => $path_real,
      context => "/files/${path_real}/beans/broker",
      changes => 'rm sslContext',
    }
  }

}
