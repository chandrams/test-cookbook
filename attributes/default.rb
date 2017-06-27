default['travis_java']['jdk_switcher_url'] = 'https://raw.githubusercontent.com/chandrams/jdk_switcher/test-jdk_switcher/jdk_switcher.sh'
default['travis_java']['jdk_switcher_path'] = '/opt/jdk_switcher/jdk_switcher.sh'
default['travis_java']['jvm_base_dir'] = '/usr/lib/jvm'
default['travis_java']['arch'] = 'i386'
default['travis_java']['arch'] = 'amd64' if node['kernel']['machine'] =~ /x86_64/

default['travis_java']['ibmjava']['platform'] = 'linux'
default['travis_java']['ibmjava8']['jvm_name'] = "java-8-ibm-#{node['travis_java']['arch']}"
default['travis_java']['ibmjava8']['pinned_release'] = nil
default['travis_java']['ibmjava9']['jvm_name'] = "java-9-ibm-#{node['travis_java']['arch']}"
default['travis_java']['ibmjava9']['pinned_release'] = nil

default['travis_java']['user'] = "travis"
default['travis_java']['group'] = "travis"

