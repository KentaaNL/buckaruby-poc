BUCKAROO = {
  website: ENV['BUCKAROO_WEBSITE'],
  secret: ENV['BUCKAROO_SECRET'],
  hash_method: ENV['BUCKAROO_HASH_METHOD'],
  mandate_prefix: ENV['BUCKAROO_MANDATE_PREFIX']
}.freeze

Buckaruby::Gateway.mode = :test
