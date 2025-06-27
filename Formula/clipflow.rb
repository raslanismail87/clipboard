class Clipflow < Formula
  desc "Lightweight clipboard manager for macOS"
  homepage "https://raslanismail87.github.io/clipboard/"
  url "https://github.com/raslanismail87/clipboard/raw/master/ClipFlow-1.1.3-app.zip"
  version "1.1.3"
  sha256 "75178a42c7cfa641d36226c17dc7c3ec118021f4daecc3853343a5d4fcfa785f"
  
  def install
    prefix.install "ClipFlow.app"
  end
  
  def caveats
    <<~EOS
      ClipFlow has been installed to:
        #{prefix}/ClipFlow.app
      
      To run ClipFlow:
        open "#{prefix}/ClipFlow.app"
      
      To add ClipFlow to your Applications folder:
        ln -sf "#{prefix}/ClipFlow.app" "/Applications/ClipFlow.app"
      
      Note: On first launch, you may need to:
        1. Right-click the app and select "Open"
        2. Click "Open" in the security dialog
        3. Grant accessibility permissions in System Preferences
      
      This is normal for unsigned applications.
    EOS
  end
  
  test do
    assert_predicate prefix/"ClipFlow.app", :exist?
    assert_predicate prefix/"ClipFlow.app/Contents/MacOS/ClipboardManager", :exist?
  end
end