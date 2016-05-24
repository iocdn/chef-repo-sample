#
# Cookbook Name:: iocdn.wordpress
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

bash "download epel" do
  code "wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm -O /tmp/epel-release-6-8.noarch.rpm"
  not_if { File.exists?("/tmp/epel-release-6-8.noarch.rpm") }
end

bash "download epel" do
  code "wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm -O /tmp/remi-release-6.rpm"
  not_if { File.exists?("/tmp/remi-release-6.rpm") }
end

yum_package 'epel-release-6-8' do
  action :install
  source "/tmp/epel-release-6-8.noarch.rpm"
end

yum_package 'remi-release-6' do
  action :install
  source "/tmp/remi-release-6.rpm"
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

bash "download wordpress" do
 code "wget https://ja.wordpress.org/wordpress-4.5.2-ja.tar.gz -O /tmp/wordpress-4.5.2-ja.tar.gz"
 not_if { File.exists?("/tmp/wordpress-4.5.2-ja.tar.gz") }
end

bash "expand wordpress" do
  code <<-EOS
    cd /var/www/html 
    tar -zxvf /tmp/wordpress-4.5.2-ja.tar.gz
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

