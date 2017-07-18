directory ::File.dirname(node['travis_java']['jdk_switcher_path']) do
  owner 'root'
  group 'root'
  mode 0o755
  recursive true
end

remote_file node['travis_java']['jdk_switcher_path'] do
  source node['travis_java']['jdk_switcher_url']
  owner node['travis_java']['user']
  group node['travis_java']['group']
  mode 0o644
end
