#
# Cookbook:: test
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


file "./hello.txt" do
	content "Hello, this is my first cookbook recipe\n how are you?"
action :create
end

execute "cat ./hello.txt"
execute "pwd"
