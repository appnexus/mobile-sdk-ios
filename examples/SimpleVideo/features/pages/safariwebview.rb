require 'calabash-cucumber/ibase'
require File.join(File.dirname(__FILE__), '..', 'support', 'wait_options')

module WebViewApp
  class SafariWebView < Calabash::IBase
    include WebViewApp::WaitOpts

    def trait
      "UIView {accessibilityIdentifier LIKE 'landing page'}"
    end

    def await(wait_opts={})
      wait_for(wait_options("UIView 'landing page'", wait_opts)) do
        !query(trait).empty?
      end

      if xamarin_test_cloud?
        timeout = 30
      else
        timeout = 15
      end

      options = {:timeout => timeout}
      wait_for(wait_options('Delegate says page is done loading', options)) do
        query('WKWebView', :UIDelegate, :loading).first != 1
      end

      wait_for(wait_options('Page HTML to load', wait_opts)) do
        !query("WKWebView css:'ul'").empty?
      end
    end

    def query_str(criteria=nil)
      "view:'_UIRemoteView' id:'RemoteViewBridge'"
    end
  end
end
