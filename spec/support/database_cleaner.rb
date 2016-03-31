DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.before :each do
    DatabaseCleaner.start
    #load "#{Rails.root}/db/seeds.rb"
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end
