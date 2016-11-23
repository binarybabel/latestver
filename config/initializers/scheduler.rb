require 'rake'
require 'rufus-scheduler'

Rake::Task.clear
Rails.application.load_tasks

scheduler = Rufus::Scheduler::singleton

if CatalogEntry.autorefresh?
  unless defined?(Rails::Console)
    puts "Autorefresh enabled... (#{CatalogEntry.autorefresh_interval})"

    scheduler.in '10s' do
      Rake::Task['catalog:refresh'].invoke
      Rake::Task['webhooks:trigger'].invoke
    end

    scheduler.every (CatalogEntry.autorefresh_interval) do
      Rake::Task['catalog:refresh'].execute
      Rake::Task['webhooks:trigger'].execute
    end
  end
end
