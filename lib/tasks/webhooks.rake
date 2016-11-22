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
        webhook.last_triggered = DateTime.now
        webhook.last_error = nil
        begin
          code, msg, body = Webhook.post(webhook.url)
          if code == '200'
            puts code
          else
            webhook.last_error = "#{code} #{msg}"
            puts "<- #{code} #{msg}"
          end
        rescue => e
          webhook.last_error = e.message
          puts '!! ERROR !!'
          puts e.message
        end
        webhook.save
        puts '------------------------------------------------------------'
      end
      entry.webhook_triggered = true
      entry.save!
      puts
    end

    puts 'WEBHOOKS COMPLETE.'
  end
end
