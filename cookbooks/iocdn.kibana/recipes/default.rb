#
# Cookbook Name:: iocdn.kibana
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

kibana_url   = node["iocdn.kibana"]["package"]["url"]
file_name  = File.basename(kibana_url)
kibana_name = file_name.gsub(/\.tar\.gz$/, '')

remote_file "/tmp/#{file_name}" do
  source kibana_url
  action :create
end

bash "install kibana" do
  action :run
  code <<-"EOS"
    tar -zxf /tmp/#{file_name} -C /usr/local
    ln -snf /usr/local/#{kibana_name} /usr/local/kibana
  EOS
  only_if { !File.exists?('/usr/local/kibana') or File.readlink('/usr/local/kibana') != "/usr/local/#{kibana_name}" }
end

cookbook_file "/etc/init.d/kibana" do
  source "etc/init.d/kibana"
  mode '0755'
end

service "kibana" do
  action :start
end
