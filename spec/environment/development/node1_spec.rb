require 'spec_helper'

#a = {a: "xxxxxxxxxxxxxxxxxxx"}
#set_property a

describe package('httpd'), :if => os[:family] == 'redhat' do
#  p property[:a]
  it { should be_installed }
end
 
#describe service('httpd'), :if => os[:family] == 'redhat' do
#  it { should be_enabled }
#  it { should be_running }
#end
