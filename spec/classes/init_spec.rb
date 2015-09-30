require 'spec_helper'
describe 'profile_chruby' do

  context 'with defaults for all parameters' do
    it { should contain_class('profile_chruby') }
  end
end
