TEST_BUILD_DIR = File.join(ROOT, "build", "picotest")

def openssl_env
  ssl = `brew --prefix openssl@3 2>/dev/null`.strip
  return {} if ssl.empty?
  { "LDFLAGS" => [ENV["LDFLAGS"], "-L#{ssl}/lib"].compact.join(" "),
    "CFLAGS"  => [ENV["CFLAGS"],  "-I#{ssl}/include"].compact.join(" ") }
end

namespace :picotest do
  desc "Build the BLE-less test VM (build_config/picoruby-test.rb) into build/picotest"
  task :build do
    abort "#{PICORUBY_SRC} not found - run `rake vendor:setup` first" unless Dir.exist?(PICORUBY_SRC)
    sh({ "MRUBY_BUILD_DIR" => TEST_BUILD_DIR,
         "MRUBY_CONFIG"    => File.join(ROOT, "build_config", "picoruby-test.rb") }.merge(openssl_env),
       "rake", "-C", PICORUBY_SRC)
  end

  task :ensure_vm do
    Rake::Task["picotest:build"].invoke unless File.executable?(TEST_VM)
  end
end
