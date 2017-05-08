describe Fastlane::Actions::MobileCenterAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The mobile_center plugin is working!")

      Fastlane::Actions::MobileCenterAction.run(nil)
    end
  end
end
