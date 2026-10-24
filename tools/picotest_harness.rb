module PicotestHarness
  REPO_ROOT     = File.expand_path("..", __dir__)
  PICORUBY_ROOT = ENV["PICORUBY_ROOT"] || File.join(REPO_ROOT, "vendor", "R2P2-darwin", "vendor", "picoruby")
  PICORUBY_VM   = File.join(REPO_ROOT, "build", "picotest", "host-picotest", "bin", "picoruby")

  BLE_BOUND      = File.join(REPO_ROOT, "mrblib", "phomemo_thermal_printer", "transport.rb")
  MRBLIB         = Dir[File.join(REPO_ROOT, "mrblib", "**", "*.rb")].sort - [BLE_BOUND]
  FAKE_TRANSPORT = File.join(REPO_ROOT, "test", "mock", "fake_transport.rb")

  LOAD_FILES = [*MRBLIB, FAKE_TRANSPORT]

  module_function

  def run(filter: nil)
    require File.join(PICORUBY_ROOT, "mrbgems", "picoruby-picotest", "mrblib", "picotest.rb")
    ENV["RUBY"] = ENV["PICOTEST_VM"] || PICORUBY_VM

    puts "== picotest suite =="
    Picotest::Runner.new(
      File.join(REPO_ROOT, "test"),
      filter: filter,
      load_path: nil,
      load_files: LOAD_FILES.select { |f| File.exist?(f) },
    ).run
  end
end
