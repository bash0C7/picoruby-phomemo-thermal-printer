R2P2_DARWIN_REPO = ENV["R2P2_DARWIN_REPO"] || "https://github.com/bash0C7/R2P2-darwin.git"
R2P2_DARWIN_REF  = ENV["R2P2_DARWIN_REF"]  || "main"

namespace :vendor do
  desc "Clone R2P2-darwin and fetch its picoruby (port-darwin head)"
  task :setup do
    sh "git clone --branch #{R2P2_DARWIN_REF} #{R2P2_DARWIN_REPO} #{RD}" unless Dir.exist?(RD)
    sh "rake", "-C", RD, "setup"
  end
end
