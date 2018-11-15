# encoding: utf-8
# bundle exec rake crawler:process
require 'capybara'
require 'capybara/poltergeist'
require 'selenium-webdriver'
require 'capybara/dsl'
require 'google_drive'
require 'date'

module CrawlerTask
  extend Rake::DSL
  extend self

  # set driver
  Capybara.current_driver = :selenium
  @googleSession = GoogleDrive::Session.from_config("config.json")
  @sp = @googleSession.spreadsheet_by_url("https://docs.google.com/spreadsheets/d/1bfeuj0sWTI5WzNU_ZSACc6gnIgSKjdsPjrl3af7c2bg/edit#gid=0")

  namespace :crawler do
    desc "googleへクローリングを実行します" #=> 説明
    def logger
      sleep 30
      Rails.logger
    end

    def create_file_path totalCount, keyword, key
      #saveFileName = "tmp/1_"+prefix+"_screenshot#{Time.now.strftime("%Y%m%d%H%M%S")}.png"
      'tmp/%d_%s_%s_screenshot.png' % [totalCount, key, keyword.gsub("allintitle:","").gsub(" ","").gsub('"', "")] 
    end

    def save_page session, totalCount, limit, keyword, key
      #flList = session.all(:xpath, '//*[@class="fl"]')
      session.all(:xpath, '//*[@class="fl"]').each do | v |
        if totalCount > limit && v.text.eql?(key)
          href = v["href"]
          session.visit href
          logger.info href
          session.save_screenshot(create_file_path(totalCount, keyword, key), full: true)
          break
        end
      end
      session
    end

    def crawler_process session, targets
      compWord = ""
      targets.each do | target |
        if compWord.blank?
          compWord = 'allintitle:%s' % target
        else
          compWord = '"%s" "%s"' % [compWord, target]
        end
        patrol_risk session, compWord
      end
    end

    def patrol_risk session, compWord
      Require.find_in_batches(batch_size: 16) do |require_array|
        requireWord = ""
        for var in require_array do
          if requireWord.blank?
            requireWord = '"%s"' % var["word"]
          else
            requireWord = '%s OR "%s"' % [requireWord, var["word"]]
          end
        end
        keyword = compWord + " " + requireWord
      
        # start crawling
        url = "https://www.google.co.jp/search?q=" + keyword
        session.visit URI.escape(url)
        logger.info url

        result_status = session.all("#resultStats")[0]
        count = (result_status.blank?) ? 0 : result_status.text.gsub(/[^\d]/, "").to_i

        # save image
        session.save_screenshot(create_file_path(count, keyword, "1"), full: true)
        
        #session = save_page(session, count, 10, keyword, "2")
        #session = save_page(session, count, 20, keyword, "3")
        #break
      end # Require
    end

    task :process => :environment do
      # create capybara session
      session = Capybara::Session.new(:poltergeist)
      ws = @sp.worksheet_by_title("list")
      now = DateTime.now.strftime("%Y年%m月%d日 %H:%M:%S")
      ws[1, 2] = now # B1
      ws.save
      rowNumMax = ws.num_rows
      for row in 3..rowNumMax do
        company_name = ws[row, 2] #B get company_name
        owner = ws[row, 3] #C get owner
        flg = ws[row, 4] #D get date
        if flg.blank?
          crawler_process session, [company_name]
          crawler_process session, [owner]
          ws[row, 4] = DateTime.now.strftime("%Y年%m月%d日 %H:%M:%S")
          break
        else
          next
        end
      end

      # From MySQL
      #Keyword.all.each do |target|
      #  crawler_process session, [target.company_name, target.owner]
      #  break
      #end # Keyword

      ws[1, 3] = "実行完了" # C1 
      ws.save
      #break
    end # process
  
  end # crawler

end # Module
