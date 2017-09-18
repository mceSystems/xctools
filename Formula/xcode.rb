class Xcode < Formula
    desc "Handy command line tool for Xcode"
    homepage "https://github.com/swift-xcode/xcode"
    url "https://github.com/swift-xcode/xcode/archive/0.1.0.tar.gz"
    sha256 "827a26e09e961c4928bf45517ec9a864a4151c2903a281ed31df81a8030742d5"
    head "https://github.com/swift-xcode/xcode.git"

    depends_on :xcode => "9.0"

    def install
      xcode_path = "#{buildpath}/.build/release/xcode"
      ohai "Building xcode"
      system("swift build -c release")
      bin.install xcode_path
    end

  end
