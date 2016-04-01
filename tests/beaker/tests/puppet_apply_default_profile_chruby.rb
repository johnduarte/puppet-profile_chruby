test_name 'Deploy profile_chruby with puppet apply'

agents.each do |agent|
  step 'Apply Manifest'
  on(agent, puppet('apply', '-e "include profile_chruby"'), :acceptable_exit_codes => [0,2]) do |result|
    #assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end

  step 'Verify Results'
  agent.close
  on(agent, 'pwd')
  on(agent, 'ruby --version') do |result|
    assert_match(/2\.1\.6/, result.stdout, 'Proper ruby version not available to user')
  end
end
