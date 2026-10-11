class HowTo < Formula
  desc "Turn a plain-English request into a shell command on your prompt"
  homepage "https://github.com/powersagitar/how-to"
  url "https://github.com/powersagitar/how-to/releases/download/v0.1.0/how-to-0.1.0.tar.gz"
  sha256 "049546d2fea404f3bd4794e5650470ac7c8fa99473777cb34e00dc9ab8d424e5"
  license "GPL-3.0-only"

  # how-to.bash needs bash >= 4.4; macOS /bin/bash is 3.2.
  depends_on "bash" => :test

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
