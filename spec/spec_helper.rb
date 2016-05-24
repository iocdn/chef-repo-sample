require 'serverspec'
require 'net/ssh'

#require '/home/keiichi/chef-repo/spec/shared/common.rb'

Dir.glob( "#{File.dirname(__FILE__)}/shared/*.rb" ).each{|f| require f}


set :backend, :ssh

if ENV['ASK_SUDO_PASSWORD']
  begin
    require 'highline/import'
  rescue LoadError
    fail "highline is not available. Try installing it."
  end
  set :sudo_password, ask("Enter sudo password: ") { |q| q.echo = false }
else
  set :sudo_password, ENV['SUDO_PASSWORD']
end

host = ENV['TARGET_HOST']

options = Net::SSH::Config.for(host)

options[:user] ||= Etc.getlogin

set :host,        options[:host_name] || host
set :ssh_options, options

set :env, :LANG => 'C', :LC_MESSAGES => 'ja_jp.utf-8'

set :request_pty, true
