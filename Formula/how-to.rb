class HowTo < Formula
  desc "Turn a plain-English request into a shell command on your prompt"
  homepage "https://github.com/powersagitar/how-to"
  url "https://github.com/powersagitar/how-to/releases/download/v0.2.0/how-to-0.2.0.tar.gz"
  sha256 "02f8286ebc281fba6cf204a76a66da1ded437955f88e055df9a2c361a6bdb36d"
  license "GPL-3.0-only"

  bottle do
    root_url "https://github.com/powersagitar/homebrew-tap/releases/download/how-to-0.2.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "67dfc7a5a026726c1b62552c56a428879bfd5a746f55c0dce36a976a3f40823a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e888be40e7ced1b4fa29426c826ae33f7f8410b2be884f4ddf88971134d9eba0"
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
