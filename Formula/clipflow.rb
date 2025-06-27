class Clipflow < Formula
  desc "Lightweight clipboard manager for macOS"
  homepage "https://raslanismail87.github.io/clipboard/"
  url "https://github.com/raslanismail87/clipboard.git"
  version "1.1.3"
  head "https://github.com/raslanismail87/clipboard.git"
  
  depends_on :macos
  depends_on xcode: :build
  
  def install
    # Make build script executable
    chmod "+x", "build_app.sh"
    
    # Build the app using the project's build script
    system "./build_app.sh"
    
    # Install the built app to Applications folder
    system "cp", "-R", "build/ClipFlow.app", "/Applications/"
    
    # Also create a symlink in Homebrew prefix for consistency
    prefix.install "build/ClipFlow.app"
  end
  
  def caveats
    <<~EOS
      ClipFlow has been installed to:
        /Applications/ClipFlow.app
      
      Since this was built locally on your machine, it should launch
      without Gatekeeper issues.
      
      To run ClipFlow:
        open "/Applications/ClipFlow.app"
      
      On first launch, you may need to grant accessibility permissions
      in System Preferences > Security & Privacy > Privacy > Accessibility
      for the auto-paste feature to work.
      
      To uninstall completely:
        brew uninstall clipflow
        rm -rf "/Applications/ClipFlow.app"
    EOS
  end
  
  test do
    assert_predicate prefix/"ClipFlow.app", :exist?
    assert_predicate prefix/"ClipFlow.app/Contents/MacOS/ClipboardManager", :exist?
  end
end