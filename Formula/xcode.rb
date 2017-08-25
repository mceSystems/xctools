class Xcode < Formula
    desc "Handy command line tool for Xcode"
    homepage "https://github.com/swift-xcode/xcode"
    url "https://github.com/swift-xcode/xcode/archive/0.0.2.tar.gz"
    sha256 "c4099729b5a4f94eb0fcd8b114f0929f8c211f3f934b98684d906ef3d069490e"
    head "https://github.com/swift-xcode/xcode.git"

    depends_on :xcode

    def install
      xcode_path = "#{buildpath}/.build/release/xcode"
      ohai "Building xcode"
      system("swift build -c release -Xlinker -rpath -Xlinker @executable_path -Xswiftc -static-stdlib")
      frameworks.install yaml_lib_path
      bin.install xcode_path
    end

  end
