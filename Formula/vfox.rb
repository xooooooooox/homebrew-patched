# Patched vfox: deterministic PATH order in `vfox env` output — upstream
# orders same-scope SDK paths by goroutine completion, permanently
# invalidating the env-state cache (slow rebuild on every hook run).
# Retire this formula once upstream ships a fix (> v1.0.11).
class Vfox < Formula
  desc "Cross-language version manager (patched: deterministic env PATH order)"
  homepage "https://vfox.dev/"
  url "https://github.com/xooooooooox/vfox/archive/refs/tags/v1.0.11-patched.1.tar.gz"
  version "1.0.11"
  sha256 "b0ed49cab852139a05f811d982777b630e3ac6debe18c3fddc867541ce6c26d1"
  license "Apache-2.0"
  revision 1

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
