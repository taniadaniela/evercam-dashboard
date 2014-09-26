PumaWorkerKiller.config do |config|
  config.ram           = 512
  config.frequency     = 5
  config.percent_usage = 0.95
end

PumaWorkerKiller.start
