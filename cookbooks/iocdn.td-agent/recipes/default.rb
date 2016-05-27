#
# Cookbook Name:: iocdn.td-agent
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

cookbook_file "/etc/yum.repos.d/td-agent.repo" do
  source "td-agent.repo"
end

yum_package "td-agent" do
  action :install
end

bash "chkconfig td-agent on" do
  action :run
  code <<-EOS
    chkconfig td-agent on
  EOS
  not_if "chkconfig --list |grep td-agent 2>&1 >/dev/null"
end

cookbook_file "/etc/td-agent/td-agent.conf" do
  source "td-agent.conf"
end

bash "install fluent-plugin-elasticsearch" do
  action :run
  code <<-EOS
    td-agent-gem install fluent-plugin-elasticsearch
  EOS
  not_if "td-agent-gem list |grep fluent-lugin-elasticsearch 2>&1 >/dev/null"  
end

bash "init td-agent" do
  action :run
  code <<-EOS
   mkdir -p /var/log/td-agent/position
   chown td-agent:td-agent /var/log/td-agent/position
   chmod 755 /var/log/td-agent/position
   chmod -R  777 /var/log/httpd
  EOS
  not_if " [ -d /var/log/td-agent/position ] "
end

service "td-agent" do
  action :start
end

