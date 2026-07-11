class Yadm < Formula
  desc "Yet Another Dotfiles Manager (patched: zsh completion for add/checkout)"
  homepage "https://yadm.io/"
  url "https://github.com/xooooooooox/yadm/archive/refs/tags/3.5.0-patched.1.tar.gz"
  version "3.5.0"
  revision 1
  sha256 "caeed8711d76e39fcfbe6c9d2d6ff30943fc2d8e74c6be5334a9cb7facc0f415"
  license "GPL-3.0-or-later"

  def install
    system "make", "install", "PREFIX=#{prefix}"
    bash_completion.install "completion/bash/yadm"
    fish_completion.install "completion/fish/yadm.fish"
    zsh_completion.install "completion/zsh/_yadm"
  end

  test do
    system bin/"yadm", "init"
    assert_path_exists testpath/".local/share/yadm/repo.git/config", "Failed to init repository."
    assert_match testpath.to_s, shell_output("#{bin}/yadm gitconfig core.worktree")
  end
end
