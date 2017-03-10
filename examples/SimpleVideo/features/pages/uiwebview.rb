require 'calabash-cucumber/ibase'
require File.join(File.dirname(__FILE__), '..', 'support', 'wait_options')

module WebViewApp
  class UIWebView < Calabash::IBase
    include WebViewApp::WaitOpts

    def trait
      "UIWebView {accessibilityIdentifier LIKE 'landing page'}"
    end

    def await(wait_opts={})
      wait_for(wait_options("UIWebView 'landing page'", wait_opts)) do
        !query(trait).empty?
      end

      wait_for(wait_options('Page HTML to load', wait_opts)) do
        !query("UIWebView css:'ul'").empty?
      end
    end

    def query_str(criteria=nil)
      if criteria.nil? || criteria == ''
        'UIWebView'
      else
        "UIWebView #{criteria}"
      end
    end
  end
end
