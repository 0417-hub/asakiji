class LineBotController < ApplicationController
  def callback
    body = request.body.read
    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          uri = URI('https://zenn-api.vercel.app/trendTech.json')
          # リダイレクトをフォローするための設定
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = (uri.scheme == 'https')

          request = Net::HTTP::Get.new(uri)
          # リダイレクトをフォローしてレスポンスを取得
          response = http.request(request)
          
          if response.code == '200'
            parsed_response = JSON.parse(response.body)
            message = []
          client.reply_message(event['replyToken'], message)
        end
      end
    end
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
