class Xcode < Formula
    desc "Handy command line tool for Xcode"
    homepage "https://github.com/xcodeswift/xctools"
    url "https://github.com/xcodeswift/xctools/archive/0.2.0.tar.gz"
    sha256 "c9528c346511380d68c29391af44fbc5be1ffa2d5bfd8d7fd160face357cba5b"
    head "https://github.com/xcodeswift/xctools.git"

    depends_on :xcode => "9.0"

    def install
      xcode_path = "#{buildpath}/.build/release/xctools"
      ohai "Building xcode"
      system("swift build --disable-sandbox -c release")
      bin.install xcode_path
    end

  end
