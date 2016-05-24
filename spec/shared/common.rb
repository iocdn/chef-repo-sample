shared_examples 'common::init' do

  describe package('mysql-community-server') do
    it { should be_installed }
  end

end
