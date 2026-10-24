desc "Run the picotest suite, the CRuby tool tests and the BLE write path check"
task test: ["test:ruby", "test:tools", "check:send_paths"]

namespace :test do
  desc "Run the picotest suite on the test VM. FILTER=<file substring>"
  task ruby: "picotest:ensure_vm" do
    $LOAD_PATH.unshift File.join(ROOT, "tools")
    require "picotest_harness"
    errors = PicotestHarness.run(filter: ENV["FILTER"])
    abort "picotest failed: #{errors} error(s)" unless errors == 0
  end

  desc "Run the CRuby minitest files under tools/test"
  task :tools do
    Dir[File.join(ROOT, "tools", "test", "*_test.rb")].sort.each do |file|
      sh RbConfig.ruby, file
    end
  end
end
