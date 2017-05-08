module Fastlane
  module Helper
    class MobileCenterHelper
      # class methods that you define here become available in your action
      # as `Helper::MobileCenterHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the mobile_center plugin helper!")
      end
    end
  end
end
