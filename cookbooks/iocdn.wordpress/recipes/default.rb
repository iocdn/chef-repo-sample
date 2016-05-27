#
# Cookbook Name:: iocdn.wordpress
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

node["iocdn.repo"].each do |repo|
  remote_file "/tmp/#{repo["name"]}" do
    source repo["url"]
    action :create
  end

  yum_package "#{repo["name"].gsub(/\.rpm$/,'')}" do
    action :install
    source "/tmp/#{repo["name"]}"
  end
end

%w(php php-mbstring php-mysql).each do |pkg|
  yum_package pkg do
    action :install
    if pkg == 'php'
      notifies :run, "bash[initialize php.ini]" , :immediately
    end
  end
end

bash "initialize php.ini" do
  action :nothing
  code <<-EOS
    sed -i.bk -e 's#;date.timezone.*#date.timezone = "Asia/Tokyo"#;s/;mbstring.language\s*=\s*Japanese/mbstring.language = Japanese/' /etc/php.ini
  EOS
end

wordpress_url  = node["iocdn.wordpress"]["url"]
wordpress_name = File.basename(wordpress_url)

remote_file "/tmp/#{wordpress_name}" do
  source wordpress_url
  action :create
end

bash "expand wordpress" do
  code <<-"EOS"
    cd /var/www/html 
    tar -zxf /tmp/#{wordpress_name}
  EOS
end

db_name = node["iocdn.wordpress"]["db"]["name"]
db_user = node["iocdn.wordpress"]["db"]["user"]
db_pwd  = node["iocdn.wordpress"]["db"]["pwd"]

bash "initialize wordpress db" do
  code <<-EOS
   cd /var/www/html/wordpress
   sed "s/define('DB_NAME',.*)/define('DB_NAME', '#{db_name}' )/;s/define('DB_USER',.*)/define('DB_USER', '#{db_user}')/;s/define('DB_PASSWORD',.*)/define('DB_PASSWORD', '#{db_pwd}')/" wp-config-sample.php > wp-config.php
  EOS
  not_if { File.exists?("/var/www/html/wordpress/wp-config.php") }
end

cookbook_file "/etc/httpd/conf.d/wordpress.conf" do
 source "wordpress.conf"
 owner "apache"
 group "apache"
 mode '0644'
 notifies :restart , "service[httpd]" , :immediately
end

service "httpd" do
  action :nothing
end

