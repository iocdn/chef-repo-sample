require 'spec_helper'

describe service('httpd'), :if => os[:family] == 'redhat' do
  it { should be_enabled }
  it { should be_running }
  include_examples 'common::init'
end

