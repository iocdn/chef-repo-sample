lock '3.5.0'

require 'capistrano/console'
require 'json'

# chef-repoルートディレクトリ
CHEF_REPO = File.expand_path('..', File.dirname(__FILE__))
# 環境情報
STAGE = env.fetch(:stage)
# ssh ユーザ
SSH_USER = 'keiichi'
# Chef-Client Package Url
CHEF_CLIENT_URL='https://packages.chef.io/stable/el/6/chef-12.10.24-1.el6.x86_64.rpm'


# ログレベル
set :log_level, :debug
# アプリケーション名(任意)
set :application, 'chef'
#set :use_sudo, false
# sudo 時必須
set :pty, true

on roles(:all) do |host|
  host.user = SSH_USER
end

# server情報の生成
Dir.glob("#{CHEF_REPO}/nodes/#{STAGE}/*.json").each do |_node_file|
  _json = JSON.parse(File.read _node_file)
  if _json["server"].nil?
    server _json["name"], name: _json["name"], user: SSH_USER
  else
    server _json["server"], name: _json["name"], user: SSH_USER
  end
end

########################################################################################
#  TASK
########################################################################################

########################################
# 環境別ノード情報の表示
# chef exec cap development list_server
########################################
task :list_server do
  on roles(:all), in: :parallel do |server|
    puts "STAGE: #{STAGE} SSH_USER: #{server.user}"
    printf(" server: %s node_name: %s\n",server.hostname, server.fetch(:name))
  end
end

########################################
# uptime
# chef exec cap deveopment uptime
########################################
task :uptime do
  on roles(:all), in: :parallel do |server|
    uptime = capture(:uptime)
    printf("%s(%s) %s\n", server.hostname, server.fetch(:name), uptime)
  end
end

########################################
# MemFree/MemTotal
# chef exec cap development mem
########################################
task :mem do
  on roles(:all) , in: :parallel do |server|
    total = capture("cat  /proc/meminfo | awk '/MemTotal/{print $2}'") 
    free  = capture("cat  /proc/meminfo | awk '/MemFree/{print $2}'")
    printf("%s(%s) %s kb / %s kb \n",server.hostname, server.fetch(:name) , total, free)

  end
end

########################################
# chef
# chef exec cap development chef:all
########################################
namespace :chef do
  task :all  => ["chef:uptime1"] 
  task :uptime1 do
    on roles(:all), in: :parallel do |server|
      uptime = capture(:uptime)
      printf("%s(%s) %s\n", server.hostname, server.fetch(:name), uptime)
    end
  end
  task :uptime2 do
    on roles(:all), in: :parallel do |server|
      uptime = capture(:uptime)
      printf("%s(%s) %s\n", server.hostname, server.fetch(:name), uptime)
    end
  end


end


task :ls do
  on roles(:all), in: :parallel do |host|
    system("git pull origin master")
    #execute("hostname")
    chef_v = capture("rpm -qa chef")
    m = chef_v.match(/chef-(?<version>\d+\.\d+).*$/)
    if m.nil?
      execute("sudo yum -y install https://packages.chef.io/stable/el/6/chef-12.10.24-1.el6.x86_64.rpm")
    elsif m["version"].to_f < 12.10
      execute("sudo yum -y update https://packages.chef.io/stable/el/6/chef-12.10.24-1.el6.x86_64.rpm")
    end
    x = capture(:uptime)
  end
end

# chef-repoをアーカイブ
task :archive do
  run_locally do
    execute("sudo tar -czf /tmp/chef-repo.tar.gz -C #{File.dirname(CHEF_REPO)} #{File.basename(CHEF_REPO)} --exclude log")
  end
end

task :sync do
  on roles(:all), in: :parallel do |host|
    system("rsync -v  /tmp/chef-repo.tar.gz #{host.hostname}:/tmp/")
    execute("tar -zxf /tmp/chef-repo.tar.gz -C /tmp")
  end
end


#nodes/development/node1.json
# sudo chef-client -z -j nodes/development/node1.json -E development
# sudo chef-client -z -j nodes/development/node1.json
task :run do
  on roles(:all), in: :parallel do |host|
    execute("sudo chef-client -z N node1")
  end
end  

# /var/tmp/chefに転送
# chef zero 実行
# rake lint
# rake food
