require 'spec_helper'

require_relative '../cookbooks/core/libraries/local_gems'

include LocalGems

describe 'Local gems' do

  context 'installed' do
    it 'should return the installed gems' do
      mock(self).`('gem list --local') { "gem1 (1)\ngem2 (2)" }

      installed.keys.should == ['gem1', 'gem2']
    end

    it 'should return the installed versions' do
      mock(self).`('gem list --local') { "gem1 (1)\ngem2 (2)" }

      installed.values.should == [['1'], ['2']]
    end

    it 'should handle multiple versions of the same gem' do
      mock(self).`('gem list --local') { "gem1 (1, 2)" }

      installed.values.should == [['1', '2']]
    end

    it 'should handle native extensions' do
      mock(self).`('gem list --local') { "gem1 (1 x86-mingw32)" }

      installed.values.should == [['1']]
    end
  end

  context 'gems_to_install' do
    it 'should not return gems that are already installed' do
      mock(self).installed { { 'gem1' => ['1.1'] } }

      gems_to_install({ 'gem1' => '1.1' }).should == {}
    end

    it 'should return gems that are already installed but have an older version' do
      mock(self).installed { { 'gem1' => ['1.0'] } }

      gems_to_install({ 'gem1' => '1.1' }).should == { 'gem1' => '1.1' }
    end

    it 'should return gems that are not installed' do
      mock(self).installed { { 'gem1' => ['1.0'] } }

      gems_to_install({ 'gem2' => '2.0' }).should == { 'gem2' => '2.0' }
    end
  end
end