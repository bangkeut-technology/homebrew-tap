# Written by CD from packaging/homebrew/bnb-print-agent.rb.tmpl in
# bangkeut-technology/beef-and-basil. Edit the template there: the next build of
# the print agent writes over this file.
class BnbPrintAgent < Formula
  desc "Beef & Basil print agent: prints the shop's tickets on its thermal printers"
  homepage "https://beefandbasil.co"
  # The same files the Printers page offers. Their names carry no version;
  # `version` is PRINT_AGENT_VERSION, which is what `brew upgrade` compares.
  if Hardware::CPU.arm?
    url "https://api.beefandbasil.co/downloads/print-agent/bnb-print-agent-macos-arm64"
    sha256 "bbf45fd7acd10ac3cc058169ae4e9ff988a9902fa8ec6965f4202652968643b1"
  else
    url "https://api.beefandbasil.co/downloads/print-agent/bnb-print-agent-macos-x64"
    sha256 "dc217154b6628081f148d3a1a57eae6e6aab7e3e8d56c5cbf059bad7b819cb27"
  end
  version "2.3.1"

  depends_on :macos

  def install
    binary = Hardware::CPU.arm? ? "bnb-print-agent-macos-arm64" : "bnb-print-agent-macos-x64"
    libexec.install binary => "bnb-print-agent"
    chmod 0755, libexec/"bnb-print-agent"
    # A wrapper rather than the binary on the PATH: it keeps the enrolled
    # credential in this prefix, which the person running brew owns, instead of
    # /Library/Application Support, which only root may write, and it tells the
    # agent Homebrew is what keeps it running.
    env = {
      BNB_PRINT_AGENT_HOME:    "${BNB_PRINT_AGENT_HOME:-#{var}/bnb-print-agent}",
      BNB_PRINT_AGENT_SERVICE: "homebrew",
    }
    (bin/"bnb-print-agent").write_env_script libexec/"bnb-print-agent", env
  end

  service do
    run opt_bin/"bnb-print-agent"
    keep_alive true
    log_path var/"log/bnb-print-agent.log"
    error_log_path var/"log/bnb-print-agent.log"
  end

  def caveats
    <<~EOS
      Set this Mac up once. In Printers in the console, make a setup code, then:
        bnb-print-agent enrol
      Do not use sudo for it: the service runs as you and reads what enrol keeps in
        #{var}/bnb-print-agent

      A Mac that sleeps prints nothing. Keep it awake, and starting again after a power cut:
        sudo pmset -a sleep 0 disksleep 0 autorestart 1

      Then keep it running whenever you are signed in to this Mac:
        brew services start bnb-print-agent
      Set the Mac to sign in on its own after a restart (System Settings, Users & Groups).

      It does not update itself. For a new build:
        brew upgrade bnb-print-agent && brew services restart bnb-print-agent
      What it is doing: #{var}/log/bnb-print-agent.log
    EOS
  end

  test do
    ENV["BNB_PRINT_AGENT_HOME"] = (testpath/"store").to_s
    # No network and no account: says which build it is, that it is not set up,
    # and draws a Khmer line through the font packed inside it.
    output = shell_output("#{bin}/bnb-print-agent check")
    assert_match version.to_s, output
    assert_match "Not set up yet", output
  end
end
