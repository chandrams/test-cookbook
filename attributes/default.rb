default['travis_java']['jdk_switcher_url'] = 'https://raw.githubusercontent.com/michaelklishin/jdk_switcher/565b95b8946abf8ce3f2b0cc87fb8260a3d5aa3c/jdk_switcher.sh'
default['travis_java']['jdk_switcher_path'] = '/opt/jdk_switcher/jdk_switcher.sh'
default['travis_java']['jvm_base_dir'] = '/usr/lib/jvm'
default['travis_java']['arch'] = 'i386'
default['travis_java']['arch'] = 'amd64' if node['kernel']['machine'] =~ /x86_64/

default['travis_java']['ibmjava']['platform'] = 'linux'
default['travis_java']['ibmjava8']['jvm_name'] = "java-8-ibm-#{node['travis_java']['arch']}"
default['travis_java']['ibmjava9']['jvm_name'] = "java-9-ibm-#{node['travis_java']['arch']}"

default['travis_java']['openjdk8-openj9']['jvm_name'] = "openjdk8-openj9-#{node['travis_java']['arch']}"
default['travis_java']['openjdk8-openj9']['pinned_release'] = 'jdk8u152-b16'

