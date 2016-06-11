# -*- mode: ruby -*-
# vi: set ft=ruby :


## VMのネットワーク
require 'ipaddr'
PRIVATE_NETWORKS = IPAddr.new('192.168.56.1/24').to_range

VAGRANTFILE_API_VERSION = "2"

# Chef の情報定義
CHEF_ENV           = 'development'
BASEDIR            = File.dirname(File.expand_path(__FILE__))
COOKBOOKS_PATH     = ['cookbooks', 'site-cookbooks'].map{|r| File.join(BASEDIR, r)}
DATA_BAGS_PATH     = File.join(BASEDIR, 'data_bags')
ENVIRONMENTS_PATH  = File.join(BASEDIR, 'environments')
NODES_PATH         = File.join(BASEDIR, 'nodes', CHEF_ENV)
ROLES_PATH         = File.join(BASEDIR, 'roles')


# ChefのNode一覧の生成
nodes = []
Dir.glob("#{NODES_PATH}/*").map do |r|
  file_name = File.basename(r)
  next unless file_name =~/\.json$/
  node_name =  file_name.gsub(/\.json$/,'')
  nodes.push node_name
end

# Vagrantの設定
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.omnibus.chef_version = "12.10.24"  # chef 12.10.24のインストール
  config.vm.box = "nrel/CentOS-6.6-i386"    # boxファイルのインストール
  
  private_networks = PRIVATE_NETWORKS.first(nodes.size + 2).map{|r| r.to_s}
  count = 2
  # node毎の設定
  nodes.each do |node_name|
    config.vm.define node_name.to_sym do |node|
      node.vm.network :private_network, ip: private_networks[count] # ネットワーク設定
      count += 1
      node.vm.hostname = node_name
      # chefの設定
      node.vm.provision :chef_zero do |chef|
        chef.channel = "stable"
        chef.version = "12.10.24"
        chef.cookbooks_path    = COOKBOOKS_PATH
        chef.data_bags_path    = DATA_BAGS_PATH
        chef.environments_path = ENVIRONMENTS_PATH
        chef.nodes_path        = NODES_PATH
        chef.roles_path        = ROLES_PATH 
        chef.node_name         = node_name
        chef.environment       = CHEF_ENV
#        chef.run_list          = ["role[web]"]
      end
    end
  end
end
