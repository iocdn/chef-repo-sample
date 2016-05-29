#
# how to setup : chef exec gem install serverspec
# how to use   : chef exec rake spec:all or chef exec rake spec:node1
require 'rake'
require 'pry'
require 'rspec/core/rake_task'
require 'json'
require 'active_support'

task :spec    => 'spec:all'
task :default => :spec

ENVIRONMENT = ENV['ENVIRONMENT'] || 'development'
BASEDIR = File.dirname(__FILE__)


namespace :spec do
  nodes = []
  Dir.glob("#{BASEDIR}/nodes/#{ENVIRONMENT}/*.json").each do |node_json|
    nodes << File.basename(node_json).gsub(/\.json$/,'')
  end 

  task :all     => nodes
  task :default => :all

  nodes.each do |node|
    roles = []
    j = JSON.parse(File.read("#{BASEDIR}/nodes/#{ENVIRONMENT}/#{node}.json"))
    target_host = (j['server']) ? j['server'] : j['name']
    if j['run_list']
      roles = j['run_list'].select{ |r| r =~/^role\[.*\]$/ }.map { |rr| rr.gsub(/^role\[(.*)\]$/,"\\1") }
    end
    patterns = []
    patterns.push "environment/#{ENVIRONMENT}/#{node}_spec.rb"
    roles.each do |role|
      patterns.push "roles/#{role}_spec.rb"
    end
    RSpec::Core::RakeTask.new(node.to_sym) do |t|
      ENV['TARGET_HOST'] = target_host
      t.pattern = "#{BASEDIR}/spec/{#{patterns.join(',')}}"
      #t.pattern = "#{BASEDIR}/spec/environment/#{ENVIRONMENT}/#{node}_spec.rb"
    end
  end
end
