class Xcode < Formula
    desc "Handy command line tool for Xcode"
    homepage "https://github.com/pepibumur/xcode"
    url "https://github.com/pepibumur/xcode/archive/0.0.1.tar.gz"
    sha256 "xxxx"
    head "https://github.com/pepibumur/xcode.git"

    depends_on :xcode

    def install
      xcode_path = "#{buildpath}/.build/release/xcode"
      ohai "Building xcode"
      system("swift build -c release -Xlinker -rpath -Xlinker @executable_path -Xswiftc -static-stdlib")
      frameworks.install yaml_lib_path
      bin.install xcode_path
    end

  end
