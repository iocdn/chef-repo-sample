lock '3.5.0'

CHEF_REPO = File.expand_path('..', File.dirname(__FILE__))

set :log_level, :debug

set :application, 'chef'

set :use_sudo, false
set :pty, true

server "10.128.0.6"

on roles(:all) do |host|
  host.user = 'admin'
  #execute :yum, 'makecache'
end


#role :demo, %w{example.com example.org example.net}
task :uptime do
  on roles(:all), in: :parallel do |host|
    uptime = capture(:uptime)
    puts "#{host.hostname} reports: #{uptime}"
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

task :chef do
  on roles(:all), in: :parallel do |host|
    execute("sudo chef-client -z N node1")
  end
end  

# /var/tmp/chefに転送
# chef zero 実行
# rake lint
# rake food
