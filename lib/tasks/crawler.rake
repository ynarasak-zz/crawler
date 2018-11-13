# encoding: utf-8
# bundle exec rake crawler:process
require 'capybara'
require 'capybara/poltergeist'
require 'selenium-webdriver'
require 'capybara/dsl'

module CrawlerTask
  extend Rake::DSL
  extend self

  # set driver
  Capybara.current_driver = :selenium

  namespace :crawler do
    desc "googleへクローリングを実行します" #=> 説明

    def create_file_path totalCount, keyword, key
      #saveFileName = "tmp/1_"+prefix+"_screenshot#{Time.now.strftime("%Y%m%d%H%M%S")}.png"
      'tmp/%d_%s_%s_screenshot.png' % [totalCount, key, keyword.gsub(" ","").gsub('"', "")] 
    end

    def save_page keyword, session, totalCount, limit, key
      #flList = session.all(:xpath, '//*[@class="fl"]')
      session.all(:xpath, '//*[@class="fl"]').each do | v |
        if totalCount > limit && v.text.eql?(key)
          session.visit v["href"]
          session.save_screenshot(create_file_path(totalCount, keyword, key), full: true)
          break
        end
      end
      session
    end

    task :process => :environment do
      # create capybara session
      session = Capybara::Session.new(:poltergeist)

      Keyword.all.each do |target|
        compWord = '"%s" OR "%s" ' % [target.company_name, target.owner]

        Require.find_in_batches(batch_size: 16) do |require_array|
          requireWord = ""
          for var in require_array do
            if requireWord.blank?
              requireWord = '"%s"' % var["word"]
            else
              requireWord = '%s OR "%s"' % [requireWord, var["word"]]
            end
          end
          keyword = compWord + requireWord
      
          # start crawling
          session.visit URI.escape("https://www.google.co.jp/search?q=" + keyword)

          result_status = session.all("#resultStats")[0]
          count = (result_status.blank?) ? 0 : result_status.text.gsub(/[^\d]/, "").to_i

          # save image
          session.save_screenshot(create_file_path(count, keyword, "1"), full: true)
        
          session = save_page(keyword, session, count, 10, "2")
          session = save_page(keyword, session, count, 20, "3")
          #break
        end # Require
        #break
      end # Keyword
    end # process
  end # crawler
end # Module
