#
# Cookbook:: test
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


file "/root/chandra/chef/hello.txt" do
	content "Hello, this is my first cookbook recipe\n how are you?"
action :create
end
arch = node['travis_java']['arch']
puts "arch = #{arch}"
