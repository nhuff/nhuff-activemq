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
    
}
