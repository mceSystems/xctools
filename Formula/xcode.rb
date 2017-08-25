class Xcode < Formula
    desc "Handy command line tool for Xcode"
    homepage "https://github.com/swift-xcode/xcode"
    url "https://github.com/swift-xcode/xcode/archive/0.0.2.tar.gz"
    sha256 "c885d4349f32931560ac44ffa65a5209e48c875686ef1e3fec2a33d2d229cc6c"
    head "https://github.com/swift-xcode/xcode.git"

    depends_on :xcode => "9.0"

    def install
      xcode_path = "#{buildpath}/.build/release/xcode"
      ohai "Building xcode"
      system("swift build -c release")
      bin.install xcode_path
    end

  end
