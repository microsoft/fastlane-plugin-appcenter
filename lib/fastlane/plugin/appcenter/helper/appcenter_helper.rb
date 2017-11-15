module Fastlane
  module Helper
    class AppcenterHelper
      # class methods that you define here become available in your action
      # as `Helper::AppcenterHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the appcenter plugin helper!")
      end
    end
  end
end
