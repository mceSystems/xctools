class Xctools < Formula
  desc "Handy command line tool for Xcode"
  homepage "https://github.com/mceSystems/xctools"
  url "https://github.com/mceSystems/xctools/archive/0.3.0.tar.gz"
  sha256 "3cfd3bc0c1161fd4c72b71bd0f707f8f4ab9e77acdc890983a3dc289a572630e"
  head "https://github.com/mceSystems/xctools.git"

  depends_on :xcode => "9.0"

  def install
    xcode_path = "#{buildpath}/.build/release/xctools"
    ohai "Building xcode"
    system("swift build --disable-sandbox -c release")
    bin.install xcode_path
  end

end
