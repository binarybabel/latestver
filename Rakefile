# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

task :start do
  refresh = ENV['REFRESH_ENABLED']
  ENV['REFRESH_ENABLED'] = nil

  begin
    Rake::Task['db:setup'].invoke
  rescue ActiveRecord::ProtectedEnvironmentError
    # Ignore, db already setup.
  end

  Rake::Task['db:migrate'].invoke

  ENV['REFRESH_ENABLED'] = refresh
  system 'rm -f tmp/pids/server.pid'
  exec 'rails s -p 3333 -b "0.0.0.0"'
end
