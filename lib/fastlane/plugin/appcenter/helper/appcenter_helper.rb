module Fastlane
  module Helper
    class AppcenterHelper
      # basic utility method to check file types that App Center will accept,
      # accounting for file types that can and should be zip-compressed
      # before they are uploaded
      def self.file_extname_full(path)
        is_zip = File.extname(path) == ".zip"

        # if file is not .zip'ed, these do not change basename and extname
        unzip_basename = File.basename(path, ".zip")
        unzip_extname = File.extname(unzip_basename)

        is_zip ? unzip_extname + ".zip" : unzip_extname
      end

    end
  end
end
