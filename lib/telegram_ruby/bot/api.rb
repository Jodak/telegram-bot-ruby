module TelegramRuby
  module Bot
    class Api
      ENDPOINTS = %w(
        getUpdates setWebhook deleteWebhook getWebhookInfo getMe sendMessage
        forwardMessage sendPhoto sendAudio sendDocument sendVideo sendVoice
        sendVideoNote sendMediaGroup sendLocation editMessageLiveLocation
        stopMessageLiveLocation sendVenue sendContact sendChatAction
        getUserProfilePhotos getFile kickChatMember unbanChatMember
        restrictChatMember promoteChatMember leaveChat getChat
        getChatAdministrators exportChatInviteLink setChatPhoto deleteChatPhoto
        setChatTitle setChatDescription pinChatMessage unpinChatMessage
        getChatMembersCount getChatMember setChatStickerSet deleteChatStickerSet
        answerCallbackQuery editMessageText editMessageCaption
        editMessageReplyMarkup deleteMessage sendSticker getStickerSet
        uploadStickerFile createNewStickerSet addStickerToSet
        setStickerPositionInSet deleteStickerFromSet answerInlineQuery
        sendInvoice answerShippingQuery answerPreCheckoutQuery
        sendGame setGameScore getGameHighScores
      ).freeze
      REPLY_MARKUP_TYPES = [
        TelegramRuby::Bot::Types::ReplyKeyboardMarkup,
        TelegramRuby::Bot::Types::ReplyKeyboardRemove,
        TelegramRuby::Bot::Types::ForceReply,
        TelegramRuby::Bot::Types::InlineKeyboardMarkup
      ].freeze
      INLINE_QUERY_RESULT_TYPES = [
        TelegramRuby::Bot::Types::InlineQueryResultArticle,
        TelegramRuby::Bot::Types::InlineQueryResultPhoto,
        TelegramRuby::Bot::Types::InlineQueryResultGif,
        TelegramRuby::Bot::Types::InlineQueryResultMpeg4Gif,
        TelegramRuby::Bot::Types::InlineQueryResultVideo,
        TelegramRuby::Bot::Types::InlineQueryResultAudio,
        TelegramRuby::Bot::Types::InlineQueryResultVoice,
        TelegramRuby::Bot::Types::InlineQueryResultDocument,
        TelegramRuby::Bot::Types::InlineQueryResultLocation,
        TelegramRuby::Bot::Types::InlineQueryResultVenue,
        TelegramRuby::Bot::Types::InlineQueryResultContact,
        TelegramRuby::Bot::Types::InlineQueryResultGame,
        TelegramRuby::Bot::Types::InlineQueryResultCachedPhoto,
        TelegramRuby::Bot::Types::InlineQueryResultCachedGif,
        TelegramRuby::Bot::Types::InlineQueryResultCachedMpeg4Gif,
        TelegramRuby::Bot::Types::InlineQueryResultCachedSticker,
        TelegramRuby::Bot::Types::InlineQueryResultCachedDocument,
        TelegramRuby::Bot::Types::InlineQueryResultCachedVideo,
        TelegramRuby::Bot::Types::InlineQueryResultCachedVoice,
        TelegramRuby::Bot::Types::InlineQueryResultCachedAudio
      ].freeze

      attr_reader :token

      def initialize(token)
        @token = token
      end

      def method_missing(method_name, *args, &block)
        endpoint = method_name.to_s
        endpoint = camelize(endpoint) if endpoint.include?('_')

        ENDPOINTS.include?(endpoint) ? call(endpoint, *args) : super
      end

      def respond_to_missing?(*args)
        method_name = args[0].to_s
        method_name = camelize(method_name) if method_name.include?('_')

        ENDPOINTS.include?(method_name) || super
      end

      def call(endpoint, raw_params = {})
        params = build_params(raw_params)
        response = conn.post("/bot#{token}/#{endpoint}", params)
        if response.status == 200
          JSON.parse(response.body)
        else
          raise Exceptions::ResponseError.new(response),
                'Telegram API has returned the error.'
        end
      end

      private

      def build_params(h)
        h.each_with_object({}) do |(key, value), params|
          params[key] = sanitize_value(value)
        end
      end

      def sanitize_value(value)
        jsonify_inline_query_results(jsonify_reply_markup(value))
      end

      def jsonify_reply_markup(value)
        return value unless REPLY_MARKUP_TYPES.include?(value.class)
        value.to_compact_hash.to_json
      end

      def jsonify_inline_query_results(value)
        return value unless
          value.is_a?(Array) &&
          value.all? { |i| INLINE_QUERY_RESULT_TYPES.include?(i.class) }
        value.map { |i| i.to_compact_hash.select { |_, v| v } }.to_json
      end

      def camelize(method_name)
        words = method_name.split('_')
        words.drop(1).map(&:capitalize!)
        words.join
      end

      def conn
        @conn ||= Faraday.new(url: 'https://api.telegram.org') do |faraday|
          faraday.request :multipart
          faraday.request :url_encoded
          faraday.adapter TelegramRuby::Bot.configuration.adapter
        end
      end
    end
  end
end
