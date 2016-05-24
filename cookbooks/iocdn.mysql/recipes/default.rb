#
# Cookbook Name:: iocdn.mysql
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
db = data_bag_item('iocdn_mysql', 'default')

package "mysql-server" do
  action :install
  notifies :run, "bash[mysql_chkconfig_on]", :immediately
end

bash "mysql_chkconfig_on" do
  action :nothing
  code "chkconfig mysqld on"
  notifies :start , "service[mysqld]", :immediately
end

service "mysqld" do
  action :nothing
  notifies :run , "bash[initialize]", :immediately
end

bash "initialize" do
  action :nothing
  code <<-EOS
  mysql -uroot -e "DROP database test;"
  mysql -uroot -e "UPDATE mysql.user SET Password=PASSWORD('#{db["root_password"]}') WHERE User='root';FLUSH PRIVILEGES;"
  EOS
end


node["iocdn.mysql"]["databases"].each do |dbname|
  bash "create_database_#{dbname}" do
    action :run
    code "mysql -uroot -p#{db["root_password"]} -e 'create database #{dbname}'"
    not_if "mysql -uroot -p#{db["root_password"]}  #{dbname} -e ''"
  end
end

node["iocdn.mysql"]["users"].each do |user|
  bash "create_user" do
    action :run
    code <<-"EOS"
    mysql -uroot -p#{db["root_password"]} -e "GRANT ALL PRIVILEGES ON #{user["db"]}.* TO '#{user["name"]}'@'localhost' IDENTIFIED BY  '#{user["pwd"]}';"
    EOS
  end
end
