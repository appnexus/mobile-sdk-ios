require 'calabash-cucumber/ibase'
require File.join(File.dirname(__FILE__), '..', 'support', 'wait_options')

module WebViewApp
  class WKWebView < Calabash::IBase
    include WebViewApp::WaitOpts

    def trait
      "WKWebView {accessibilityIdentifier LIKE 'landing page'}"
    end

    def await(wait_opts={})
      wait_for(wait_options("WKWebView 'landing page'", wait_opts)) do
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
      if criteria.nil? || criteria == ''
        'WKWebView'
      else
        "WKWebView #{criteria}"
      end
    end
  end
end
