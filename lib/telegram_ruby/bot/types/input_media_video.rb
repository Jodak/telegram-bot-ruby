module TelegramRuby
  module Bot
    module Types
      class InputMediaVideo < Base
        attribute :type, String
        attribute :media, String
        attribute :caption, String
        attribute :width, Integer
        attribute :height, Integer
        attribute :duration, Integer
      end
    end
  end
end
