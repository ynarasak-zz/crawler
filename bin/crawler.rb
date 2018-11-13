#! /usr/bin/env ruby

require 'capybara'
require 'capybara/poltergeist'
require 'selenium-webdriver'
require 'capybara/dsl'

Capybara.current_driver = :selenium

module Crowler
  class Google
    include Capybara::DSL

    def hit_num keyword
      session = Capybara::Session.new(:poltergeist)
      session.visit URI.escape("https://www.google.co.jp/search?q=" + keyword)
      session.save_screenshot "tmp/"+keyword.gsub(" ","")+"_screenshot#{Time.now.strftime("%Y%m%d%H%M%S")}.png"

      #result_status = all("#resultStats")[0]
      #unless result_status.nil?
      #  result_status.text.match(/(\d+,)*\d+/)[0].gsub(",","").to_i
      #else
      #  0
      #end
    end

  end
end

Require.find_in_batches(batch_size: 16){|require_array|
  for var in require_array do
   p var["word"]
  end
}

blowser = Crowler::Google.new
print blowser.hit_num "Capybara Selenium"
