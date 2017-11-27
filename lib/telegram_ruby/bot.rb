require 'virtus'
require 'inflecto'
require 'logger'
require 'json'
require 'faraday'

require 'telegram_ruby/bot/types'
require 'telegram_ruby/bot/exceptions'
require 'telegram_ruby/bot/api'
require 'telegram_ruby/bot/null_logger'
require 'telegram_ruby/bot/client'
require 'telegram_ruby/bot/version'
require 'telegram_ruby/bot/configuration'

module TelegramRuby
  module Bot
    class << self
      attr_writer :configuration
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield(configuration)
    end
  end
end
