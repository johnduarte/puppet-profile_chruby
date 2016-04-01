test_name 'Install profile_chruby Module' do

  @local = {}
  @staging = {}
  step 'Setup' do
    proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../../../'))
    @staging = { :module_name => 'johnduarte-profile_chruby' }

    # Check to see if module version is specified.
    @staging[:version] = ENV['MODULE_VERSION'] if ENV['MODULE_VERSION']

    @local = { :module_name => 'profile_chruby',
              :source => proj_root }
  end

  agents.each do |agent|
    @local[:target_module_path] = agent['distmoduledir']

    # Install dependencies if running locally.
    step 'Install profile_chruby Module Dependencies' do
      # TODO: Parse metadata.json for dependencies
      on(agent, puppet('module install puppetlabs-stdlib'))
      on(agent, puppet('module install puppetlabs-git'))
      on(agent, puppet('module install puppetlabs-vcsrepo'))
      on(agent, puppet('module install nanliu-staging'))
      on(agent, puppet('module install justinstoller-chruby'))
      on(agent, puppet('module install justinstoller-ruby_build'))
      on(agent, puppet('module install gildas-homebrew'))
    end

    # in CI install from staging forge, otherwise from local
    step 'Install profile_chruby Module' do
      copy_module_to(agent)
    end
  end
end
