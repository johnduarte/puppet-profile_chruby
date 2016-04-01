test_name 'Install Puppet Agent' do

  puppet_agent_version = ENV['BEAKER_PUPPET_AGENT_VERSION'] || '1.4.1'

  step 'Install Puppet Agent' do
    install_puppet_agent_on(agents, :version => puppet_agent_version)
  end
end
