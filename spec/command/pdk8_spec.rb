require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Pdk8 do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ pdk8 }).should.be.instance_of Command::Pdk8
      end
    end
  end
end

