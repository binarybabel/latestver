namespace :catalog do

  desc 'Refresh latest version of catalog entries'
  task :refresh, [:filter] => :environment do |t, args|
    puts 'Refreshing latest version of catalog entries:'
    puts

    filter = args[:filter]

    CatalogEntry.all.each do |entry|
      if filter
        if filter.match(/\A[0-9]+\Z/)
          next unless entry.id.to_s == filter
        else
          next unless entry.name.to_s.match(Regexp.new(filter, 'i'))
        end
      end

      puts "Refreshing #{entry.label} ..."
      begin
        old_version = entry.version
        entry.refresh!
        if old_version != entry.version
          puts "-> WAS #{old_version || '(null)'}"
        end
        puts "-> NOW #{entry.version}"
      rescue => e
        puts '!! ERROR !!'
        puts e.message
      end
      puts
    end

    puts 'REFRESH COMPLETE.'
  end
end
