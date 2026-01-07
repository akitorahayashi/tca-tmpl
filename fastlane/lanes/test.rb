# fastlane/lanes/test.rb
# Test-related lanes and helpers

# === Test Lanes ===
desc "Build for testing"
lane :build_for_testing do |options|
  options ||= {}
  configuration = options[:configuration] || CONFIGURATIONS[:debug]

  scan_args = {
    project: PROJECT_PATH,
    scheme: SCHEMES[:app],
    destination: simulator_destination_from(options),
    derived_data_path: File.join(TEST_DERIVED_DATA_PATH, configuration),
    configuration: configuration,
    build_for_testing: true,
    clean: !ENV["CI"],
    buildlog_path: TEST_LOGS_PATH,
    suppress_xcode_output: true,
  }

  passed_xcargs = options[:xcargs].to_s.strip
  passed_xcargs += " -skipMacroValidation" if ENV["CI"]
  scan_args[:xcargs] = passed_xcargs unless passed_xcargs.empty?

  begin
    scan(**scan_args)
    UI.success("✅ Build-for-testing successful (output suppressed)")
  rescue => ex
    UI.error("❌ Build-for-testing failed for scheme '#{SCHEMES[:app]}'")
    print_latest_xcodebuild_log(buildlog_path: scan_args[:buildlog_path], lines: 200)
    raise ex
  end
end

desc "Run unit tests"
lane :unit_test do |options|
  options ||= {}
  test_with_scheme({ scheme: SCHEMES[:unit_test], result_path: UNIT_TEST_RESULT_PATH }.merge(options))
end

desc "Run unit tests without building"
lane :unit_test_without_building do |options|
  options ||= {}
  test_with_scheme(
    {
      scheme: SCHEMES[:unit_test],
      result_path: UNIT_TEST_RESULT_PATH,
      test_without_building: true,
    }.merge(options)
  )
end

desc "Run integration tests"
lane :intg_test do |options|
  options ||= {}
  test_with_scheme({ scheme: SCHEMES[:intg_test], result_path: INTG_TEST_RESULT_PATH }.merge(options))
end

desc "Run integration tests without building"
lane :intg_test_without_building do |options|
  options ||= {}
  test_with_scheme(
    {
      scheme: SCHEMES[:intg_test],
      result_path: INTG_TEST_RESULT_PATH,
      test_without_building: true,
    }.merge(options)
  )
end

desc "Run UI tests"
lane :ui_test do |options|
  options ||= {}
  test_with_scheme({ scheme: SCHEMES[:ui_test], result_path: UI_TEST_RESULT_PATH }.merge(options))
end

desc "Run UI tests without building"
lane :ui_test_without_building do |options|
  options ||= {}
  test_with_scheme(
    {
      scheme: SCHEMES[:ui_test],
      result_path: UI_TEST_RESULT_PATH,
      test_without_building: true,
    }.merge(options)
  )
end

desc "Run all tests (Unit, UI, Intg)"
lane :test_all do |options|
  options ||= {}
  build_for_testing(options)
  unit_test_without_building(options)
  intg_test_without_building(options)
  ui_test_without_building(options)
end

# === Private Test Helpers ===

def simulator_destination_from(options)
  destination = options[:destination].to_s.strip
  return destination unless destination.empty?

  udid = options[:udid].to_s.strip
  return "platform=iOS Simulator,id=#{udid}" unless udid.empty?

  env_destination = ENV["SIMULATOR_DESTINATION"].to_s.strip
  return env_destination unless env_destination.empty?

  selected_udid = find_available_iphone_simulator_udid
  if selected_udid.empty?
    UI.user_error!("Unable to find an available iPhone simulator on this runner.")
  end

  UI.message("Using simulator UDID: #{selected_udid}")
  "platform=iOS Simulator,id=#{selected_udid}"
end

def find_available_iphone_simulator_udid
  output = sh("xcrun simctl list devices available 'iPhone'", log: false)
  output.to_s[/[0-9A-Fa-f-]{36}/].to_s.strip
rescue StandardError
  ""
end

def print_latest_xcodebuild_log(buildlog_path:, lines:)
  log_dir = File.expand_path(buildlog_path.to_s, Dir.pwd)
  log_file = Dir.glob(File.join(log_dir, "**", "*.log")).max_by do |path|
    File.mtime(path)
  rescue StandardError
    Time.at(0)
  end

  if log_file.nil? || !File.file?(log_file)
    UI.error("Could not find xcodebuild logs under: #{log_dir}")
    return
  end

  UI.message("Showing last #{lines} lines from log: #{log_file}")
  UI.message(File.read(log_file).lines.last(lines).join)
rescue StandardError => error
  UI.error("Failed to read xcodebuild logs under #{log_dir}: #{error}")
end

private_lane :test_with_scheme do |options|
  result_path = File.expand_path(options[:result_path], Dir.pwd)
  sh("rm -rf \"#{result_path}\"")

  configuration = options[:configuration] || CONFIGURATIONS[:debug]
  derived_data_path = File.join(TEST_DERIVED_DATA_PATH, configuration)

  FileUtils.mkdir_p(File.dirname(result_path))
  FileUtils.mkdir_p(TEST_LOGS_PATH)
  FileUtils.mkdir_p(derived_data_path)

  scan_args = {
    project: PROJECT_PATH,
    scheme: options[:scheme],
    destination: simulator_destination_from(options),
    derived_data_path: derived_data_path,
    result_bundle_path: result_path,
    code_coverage: false,
    output_types: "xcresult",
    clean: false,
    buildlog_path: TEST_LOGS_PATH,
    suppress_xcode_output: true,
  }

  passed_xcargs = options[:xcargs].to_s.strip
  passed_xcargs += " -skipMacroValidation" if ENV["CI"]
  scan_args[:xcargs] = passed_xcargs unless passed_xcargs.empty?
  scan_args[:test_without_building] = true if options[:test_without_building]

  begin
    scan(**scan_args)
    UI.success("✅ Test successful for scheme '#{options[:scheme]}' (output suppressed)")
  rescue => ex
    UI.error("❌ Test failed for scheme '#{options[:scheme]}'")
    print_latest_xcodebuild_log(buildlog_path: scan_args[:buildlog_path], lines: 100)
    raise ex
  end
end
