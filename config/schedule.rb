set :output, error: '/var/log/arium-cron-error.log', standard: '/var/log/arium-cron.log'
dir = File.expand_path('..', File.expand_path(File.dirname(__FILE__)))

every 5.minutes do
  command "cd #{dir} && bundle exec bin/arium_desktop"
end
