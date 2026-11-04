class HowTo < Formula
  desc "Turn a plain-English request into a shell command on your prompt"
  homepage "https://github.com/powersagitar/how-to"
  url "https://github.com/powersagitar/how-to/releases/download/v0.3.0/how-to-0.3.0.tar.gz"
  sha256 "c50fbb3b610d7343450585d945379f83665872313653d1bf49916b29eef00b4e"
  license "GPL-3.0-only"

  bottle do
    root_url "https://github.com/powersagitar/homebrew-tap/releases/download/how-to-0.3.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "44fe30e65ef6c3e0fbafeef8f8f194d88f7ed563dc78ff2a06fb5bcdc9d75b90"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c22dded1414b6dfc52bc3c91718f41495e07171c3db53c5a5d1635aec35e77ec"
  end

  # how-to.bash needs bash >= 4.4; macOS /bin/bash is 3.2.
  depends_on "bash" => :test
  uses_from_macos "zsh" => :test

  def install
    pkgshare.install "src/how-to.zsh", "src/how-to.bash"
    doc.install "README.md", "docs/usage.md"
  end

  def caveats
    <<~EOS
      how-to is a shell function, so it must be sourced. Add to ~/.zshrc:
        source #{opt_pkgshare}/how-to.zsh
      or to ~/.bashrc (bash >= 4.4):
        source #{opt_pkgshare}/how-to.bash
      The default provider needs the claude CLI on your PATH and logged in.
    EOS
  end

  test do
    assert_match "alias", shell_output("zsh -fc 'source #{pkgshare}/how-to.zsh; whence -w how-to'")
    bash = formula_opt_bin("bash")/"bash"
    assert_equal "function",
                 shell_output("#{bash} --norc -c 'source #{pkgshare}/how-to.bash; type -t _how_to_main'").chomp
  end
end
