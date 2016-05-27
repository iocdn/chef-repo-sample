#
# Cookbook Name:: iocdn.elasticsearch
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
yum_package "java-1.7.0-openjdk" do
  action :install
end

cookbook_file "/etc/yum.repos.d/elasticsearch.repo" do
  source  "elasticsearch.repo" 
end

yum_package "elasticsearch" do
  action :install
end

bash "chckconfig on elasticsearch" do
  action :nothing
  code <<-EOS
    chkconfig elasticsearch on
  EOS
  only_if "chkconfig --list |grep elasticsearch 2>&1 >/dev/null"
end

service "elasticsearch" do
  action :start
end
