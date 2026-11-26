class SpaceIndicator < Formula
  desc "Menu bar app showing the active macOS Space number"
  homepage "https://github.com/powersagitar/space-indicator"
  url "https://github.com/powersagitar/space-indicator/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "d8303fea31f83d94de9029eced2cb818209a7e2672cbbc702f5dfec2d4dde734"
  license "GPL-3.0-only"

  depends_on xcode: ["27.0", :build]
  depends_on arch: :arm64
  depends_on macos: :golden_gate

  def install
    if Utils.safe_popen_read("xcode-select", "-p").include?("CommandLineTools")
      odie <<~EOS
        Full Xcode is required; the Command Line Tools alone are not enough. Run:
          sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
      EOS
    end
    unless quiet_system("xcodebuild", "-license", "check")
      odie <<~EOS
        The Xcode license has not been accepted. Run:
          sudo xcodebuild -license accept
      EOS
    end
    unless quiet_system("xcodebuild", "-checkFirstLaunchStatus")
      odie <<~EOS
        Xcode's first-launch components are missing. Run:
          sudo xcodebuild -runFirstLaunch
      EOS
    end

    xcodebuild "-project", "SpaceIndicator.xcodeproj",
               "-scheme", "SpaceIndicator",
               "-configuration", "Release",
               "-derivedDataPath", "build",
               "CODE_SIGN_IDENTITY=-",
               "MARKETING_VERSION=#{version}",
               # Swift macro plugins (SwiftUI's @State, @Observable) run under their own
               # sandbox-exec, which cannot nest inside Homebrew's build sandbox.
               "OTHER_SWIFT_FLAGS=$(inherited) -disable-sandbox",
               "build"

    prefix.install "build/Build/Products/Release/Space Indicator.app"
    bin.install "scripts/space-indicator-cleanup"
  end

  def caveats
    <<~EOS
      Setup (one time):
        ln -sfn "#{opt_prefix}/Space Indicator.app" "/Applications/Space Indicator.app"
      Then start it with:
        open "/Applications/Space Indicator.app"
      (or from Spotlight once linked). Launch at Login is in its menu.

      Common pitfalls on a fresh machine:
        - Full Xcode 27 or later is required; the Command Line Tools alone are
          not enough. Switch with:
            sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
        - Accept the Xcode license:
            sudo xcodebuild -license accept
        - Install Xcode's first-launch components:
            sudo xcodebuild -runFirstLaunch
        - Apple Silicon and macOS 27 or later only.
        - If the number doesn't appear, check System Settings -> Menu Bar, where
          items can be hidden. On notched MacBooks a full menu bar can push it
          behind the notch.
        - Nothing asks for permissions. A prompt asking for any means something
          is wrong.
        - Turning on Launch at Login makes macOS show a "Background Items Added"
          notice. That is expected: it is the LaunchAgent plist being written.
        - Uninstalling: run space-indicator-cleanup before brew uninstall.
    EOS
  end

  test do
    assert_predicate prefix/"Space Indicator.app/Contents/MacOS/Space Indicator", :executable?
    assert_equal "true",
                 shell_output("/usr/libexec/PlistBuddy -c 'Print :LSUIElement' " \
                              "'#{prefix}/Space Indicator.app/Contents/Info.plist'").strip
    assert_predicate bin/"space-indicator-cleanup", :executable?
  end
end
