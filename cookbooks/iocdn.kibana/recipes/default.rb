#
# Cookbook Name:: iocdn.kibana
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

kibana_url   = node["iocdn.kibana"]["package"]["url"]
kibana_name  = File.basename(kibana_url)

remote_file "/usr/local" do
  source 'http://somesite.com/index.php'
  owner 'web_admin'
  group 'web_admin'
  mode '0755'
  action :create
end
