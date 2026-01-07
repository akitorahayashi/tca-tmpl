
# fastlane/config.rb
# Fastlane configuration values

base_dir = ENV["FL_OUTPUT_DIR"] || "."

# === Project ===
PROJECT_PATH = "TemplateApp.xcodeproj"

# === Scheme Constants ===
SCHEMES = {
  app: "TemplateApp",
  unit_test: "TemplateAppTests",
  intg_test: "TemplateAppIntgTests",
  ui_test: "TemplateAppUITests"
}.freeze

# === Build Paths ===
BUILD_PATH = File.join(base_dir, "build")
LOGS_PATH = File.join(base_dir, "fastlane/logs")
TEST_LOGS_PATH = File.join(LOGS_PATH, "test")
BUILD_LOGS_PATH = File.join(LOGS_PATH, "build")

TEST_RESULTS_PATH = File.join(BUILD_PATH, "test-results")
UNIT_TEST_RESULT_PATH = File.join(TEST_RESULTS_PATH, "unit/TestResults.xcresult")
INTG_TEST_RESULT_PATH = File.join(TEST_RESULTS_PATH, "intg/TestResults.xcresult")
UI_TEST_RESULT_PATH = File.join(TEST_RESULTS_PATH, "ui/TestResults.xcresult")

# === Archive Paths ===
ARCHIVE_ROOT_PATH = File.join(base_dir, "fastlane/build")
DEBUG_ARCHIVE_PATH = File.join(ARCHIVE_ROOT_PATH, "debug/archive/TemplateApp.xcarchive")
RELEASE_ARCHIVE_PATH = File.join(ARCHIVE_ROOT_PATH, "release/archive/TemplateApp.xcarchive")

# === Build DerivedData Paths ===
DERIVED_DATA_ROOT_PATH = File.join(base_dir, "build")
TEST_DERIVED_DATA_PATH = File.join(base_dir, "fastlane/build/test-results/DerivedData")
DEBUG_BUILD_DERIVED_DATA_PATH = File.join(base_dir, "fastlane/build/debug/archive/DerivedData")
RELEASE_BUILD_DERIVED_DATA_PATH = File.join(base_dir, "fastlane/build/release/archive/DerivedData")

# === Configurations ===
CONFIGURATIONS = {
  debug: "Debug",
  release: "Release",
}.freeze

# === Export Methods ===
EXPORT_METHODS = {
  app_store: "app-store",
  ad_hoc: "ad-hoc",
  enterprise: "enterprise",
  development: "development"
}.freeze
