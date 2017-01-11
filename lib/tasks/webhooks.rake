namespace :webhooks do

  desc 'Trigger webhooks based on recent catalog changes'
  task :trigger => :environment do |t, args|
    puts 'Triggering webhooks:'
    puts

    CatalogLogEntry.where('webhook_triggered != 1 AND webhook_triggered != "t"').each do |entry|
      puts "[#{entry.catalog_entry.label}]"
      entry.catalog_entry.catalog_webhooks.each do |webhook|
        puts '------------------------------------------------------------'
        puts "-> #{webhook.url}"
        webhook.trigger!
        if webhook.last_error
          puts '!! ERROR !!'
          puts webhook.last_error
        else
          puts 'OK'
        end
        puts '------------------------------------------------------------'
      end
      entry.webhook_triggered = true
      entry.save!
      puts
    end

    puts 'WEBHOOKS COMPLETE.'
  end
end
