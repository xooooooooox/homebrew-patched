# Patched lazygit: the recent repos menu (ctrl+r) could not return to a
# dotfile-style repo opened via --git-dir/--work-tree (yadm/vcsh) -- the
# list only stored paths, so the entry was filtered out and, when present,
# switching to it failed with "not a git repository". The list now remembers
# the git location env vars per repo. Base: upstream master (> v0.64.1,
# includes the #5910 submodule-escape fix that patched.1-of-0.64.0 carried).
# Retire this formula once upstream ships a release with a recent-repos fix.
class Lazygit < Formula
  desc "Simple terminal UI for git commands (patched: recent repos menu for dotfile repos)"
  homepage "https://github.com/jesseduffield/lazygit/"
  url "https://github.com/xooooooooox/lazygit/archive/refs/tags/v0.64.1-patched.1.tar.gz"
  version "0.64.1"
  sha256 "3a5d4ebf03bbc22cd796caa1b887bf274dd86993bf9aae94900e0ee547013d26"
  license "MIT"

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
