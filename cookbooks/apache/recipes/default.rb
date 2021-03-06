#
# Cookbook Name:: apache
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package "httpd" do
  action :install
end
service "httpd" do
  action :start
end

bash 'httpd_service_on' do
  code <<-EOH
      chkconfig httpd on
    EOH
end
