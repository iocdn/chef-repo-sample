require 'spec_helper'

describe service('httpd'), :if => os[:family] == 'redhat' do
  it { should be_enabled }
  it { should be_running }
#  include_examples 'common::init'
end

describe service('mysqld') do
  it { should be_enabled }
  it { should be_running }
end

describe file('/etc/php.ini') do
   it { should contain 'date.timezone = "Asia/Tokyo"' }
   it { should contain 'mbstring.language = Japanese'}
end

describe file('/var/www/html/wordpress/wp-config.php') do
  it { should contain "define('DB_NAME', 'wordpress' );" }
  it { should contain "define('DB_USER', 'user01')" }
end

describe service('elasticsearch') do
  it { should be_enabled }
  it { should be_running }
end

describe service('td-agent') do
  it { should be_enabled }
  it { should be_running }
end

describe file('/var/log/httpd') do
  it { should be_directory }
  it { should be_mode 777 }
end

describe service('kibana') do
  it { should be_running }
end


describe command("netstat -ntla |awk '/LISTEN/{print $4}'") do
  its(:stdout) { should match /0.0.0.0:5601$/ }
  its(:stdout) { should match /0.0.0.0:3306$/ }
  its(:stdout) { should match /:::80$/ }
end

