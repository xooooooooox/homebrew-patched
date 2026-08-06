# Patched lazygit: escaping a submodule back to a bare repo opened via
# --git-dir/--work-tree (yadm/vcsh dotfiles) failed with "not a git
# repository" -- the env vars were cleared on entering the submodule and
# never restored (upstream #1118).
# Retire this formula once upstream ships a fix (> v0.64.0).
class Lazygit < Formula
  desc "Simple terminal UI for git commands (patched: submodule escape in bare repos)"
  homepage "https://github.com/jesseduffield/lazygit/"
  url "https://github.com/xooooooooox/lazygit/archive/refs/tags/v0.64.0-patched.1.tar.gz"
  version "0.64.0"
  sha256 "e134e24b821342ec5a671b7b6da3ddca3607f605a915f590fb9abfc17f52d140"
  license "MIT"
  revision 1

  # Watch the upstream repo (the fork tag never moves): `brew livecheck`
  # reports when upstream ships a release newer than the patched base.
  livecheck do
    url :homepage
    strategy :github_latest
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = OS.mac? ? "1" : "0"
    ldflags = "-X main.version=#{version} -X main.buildSource=#{tap.user}"
    system "go", "build", "-mod=vendor", *std_go_args(ldflags:)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/lazygit -v")
  end
end
