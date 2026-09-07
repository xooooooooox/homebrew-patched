# Retired 2026-09-07: patch (1), deterministic PATH order in `vfox env`
# output, merged upstream (version-fox/vfox#691) and shipped in v1.0.12;
# patch (2), the machine-global shared env cache, was closed unimplemented
# (#694) and is retired with the formula (~15ms/rebuild trade-off accepted).
# Kept as history and as the template for the next patch — see README
# "Retiring a tool". Replacements: core (arm/current macOS) or
# xooooooooox/prebuilt/vfox (Intel/monterey).
class Vfox < Formula
  desc "Cross-language version manager (patched: stable PATH order + shared env cache)"
  homepage "https://vfox.dev/"
  url "https://github.com/xooooooooox/vfox/archive/refs/tags/v1.0.11-patched.2.tar.gz"
  version "1.0.11"
  sha256 "c0fcc7662d39d3ac603488743fc18509218d29b75a93f763a4b15f5ccb3f52f3"
  license "Apache-2.0"
  revision 2

  # Watch the upstream repo (the fork tag never moves): `brew livecheck`
  # reports when upstream ships a release newer than the patched base.
  livecheck do
    url "https://github.com/version-fox/vfox"
    strategy :github_latest
  end

  deprecate! date: "2026-09-07", because: "has its PATH-order fix upstream in v1.0.12 (shared cache dropped)"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args

    bash_completion.install "completions/bash_autocomplete" => "vfox"
    zsh_completion.install "completions/zsh_autocomplete" => "_vfox"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vfox --version")
  end
end
