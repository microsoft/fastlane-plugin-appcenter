describe Fastlane::Helper::AppcenterHelper do
  describe "#file_extname_full" do
    it "returns '' (blank) for a file with no extension" do
      path = "./fixtures/appfiles/Appfile_empty"
      expect(Fastlane::Helper::AppcenterHelper.file_extname_full(path)).to eq("")
    end

    it "returns '.zip' for a zip file with no preceding extension" do
      path = "./test.zip"
      expect(Fastlane::Helper::AppcenterHelper.file_extname_full(path)).to eq(".zip")
    end

    it "returns '.apk' for an .apk file" do
      path = "./fixtures/appfiles/apk_file_empty.apk"
      expect(Fastlane::Helper::AppcenterHelper.file_extname_full(path)).to eq('.apk')
    end

    it "returns '.ipa' for an .ipa file" do
      path = "./fixtures/appfiles/ipa_file_empty.ipa"
      expect(Fastlane::Helper::AppcenterHelper.file_extname_full(path)).to eq(".ipa")
    end

    it "returns '.dSYM.zip' for a .dSYM.zip file" do
      path = "./fixtures/symbols/Themoji.dSYM.zip"
      expect(Fastlane::Helper::AppcenterHelper.file_extname_full(path)).to eq(".dSYM.zip")
    end

    it "returns '.dSYM' for a .dSYM package/directory" do
      path = "./fixtures/symbols/Themoji.dSYM"
      expect(Fastlane::Helper::AppcenterHelper.file_extname_full(path)).to eq(".dSYM")
    end

    it "returns '.app.zip' for a .app.zip file" do
      path = "./fixtures/appfiles/mac_app_empty.app.zip"
      expect(Fastlane::Helper::AppcenterHelper.file_extname_full(path)).to eq(".app.zip")
    end

    it "returns '.app' for a .app package/directory" do
      path = "./fixtures/appfiles/mac_app_empty.app"
      expect(Fastlane::Helper::AppcenterHelper.file_extname_full(path)).to eq(".app")
    end
  end
end
