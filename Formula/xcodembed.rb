class Xcodembed < Formula
    desc "A command line tools for embedding Xcode frameworks"
    homepage "https://github.com/pepibumur/xcodembed"
    url "https://github.com/pepibumur/xcodembed/archive/0.0.1.tar.gz"
    sha256 "xxxx"
    head "https://github.com/pepibumur/xcodembed.git"
  
    depends_on :xcode
  
    def install
      xcodegen_path = "#{buildpath}/.build/release/XcodeGen"
      ohai "Building XcodeGen"
      system("swift build -c release -Xlinker -rpath -Xlinker @executable_path -Xswiftc -static-stdlib")
      frameworks.install yaml_lib_path
      bin.install xcodegen_path
    end
  
  end