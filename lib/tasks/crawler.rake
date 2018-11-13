# encoding: utf-8
# bundle exec rake crawler:process
require 'capybara'
require 'capybara/poltergeist'
require 'selenium-webdriver'
require 'capybara/dsl'

Capybara.current_driver = :selenium

namespace :crawler do
  desc "googleへクローリングを実行します" #=> 説明

# $ rake inactive_user:destroy_unconfirmed のように使う
# :environmentは超大事。ないとモデルにアクセスできない

  task :process => :environment do
    keyword = '"Framgia" OR "小林泰平" "捜査" OR "指名手配"'
    Keyword.all.each do |target|
      p target.company_name
      p target.owner

      # キーワードが多い事でGoogle検索エラーとなるので、一旦16上限で実行
      Require.find_in_batches(batch_size: 16) do |require_array|
        for var in require_array do
          p var["word"]
        end
        p "##########"
      end
      # create capybara session
      #session = Capybara::Session.new(:poltergeist)
      
      # start crawling
      #session.visit URI.escape("https://www.google.co.jp/search?q=" + keyword)

      # save image
      #session.save_screenshot "tmp/"+keyword.gsub(" ","")+"_screenshot#{Time.now.strftime("%Y%m%d%H%M%S")}.png"
    end
  end
end
