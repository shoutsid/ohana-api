# frozen_string_literal: true

# The browser and driver the walk installed as a pair. Selenium reads this hook when the
# driver is created, and a local executable wins over `webdrivers`' download. A machine with
# no system driver falls through to the gem unchanged.
if File.executable?("/usr/bin/chromedriver") &&
    defined?(Selenium::WebDriver::Chrome::Service)
  Selenium::WebDriver::Chrome::Service.driver_path = "/usr/bin/chromedriver"
end
if File.executable?("/usr/bin/chromium") && defined?(Selenium::WebDriver::Chrome) &&
    Selenium::WebDriver::Chrome.respond_to?(:path=)
  Selenium::WebDriver::Chrome.path = "/usr/bin/chromium"
end

# A container is not a desktop: Chromium's sandbox needs a user namespace the era
# container does not grant, and `/dev/shm` is the default 64 MB. Without both flags the
# browser exits before writing DevToolsActivePort, which Selenium reports as a crash.
if defined?(Selenium::WebDriver::Chrome::Options)
  module AgentsFyiContainerChrome
    def initialize(*args, **kwargs)
      super
      add_argument("--no-sandbox")
      add_argument("--disable-dev-shm-usage")
    end
  end
  Selenium::WebDriver::Chrome::Options.prepend(AgentsFyiContainerChrome)
end
