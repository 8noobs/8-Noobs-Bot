require 'telegram/bot'

token = 'your-token-here'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message
	when Telegram::Bot::Types::Message
      if message.new_chat_member.class != nil.class
	    if message.new_chat_member.username != nil
		  usr = '@'+message.new_chat_member.username
		  msj = 'Bienvenido a 8Noobs, '+ usr  
		  bot.api.send_message(chat_id: message.chat.id, text: msj  )
		  kb = [Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Normas', callback_data: 'normas' )]
          markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
          bot.api.send_message(chat_id: message.chat.id, text: 'Haz click abajo para ver las normas en privado', reply_markup: markup)
		else
		  usr = message.new_chat_member.first_name
	      msj = 'Bienvenido a 8Noobs, '+ usr  
		  bot.api.send_message(chat_id: message.chat.id, text: msj  )
		  kb = [Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Normas', callback_data: 'normas' )]
          markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
          bot.api.send_message(chat_id: message.chat.id, text: 'Haz click abajo para ver las normas en privado', reply_markup: markup)
		end	 
      end
	  if message.text != nil and message.text.include?'/start'
	    if message.chat.id != -1001065691237
	      bot.api.forward_message(chat_id: message.chat.id, from_chat_id: 209566334, message_id: 384 )
		end
	  end
	when Telegram::Bot::Types::CallbackQuery
	  if message.data == 'normas'
	    bot.api.answerCallbackQuery(callback_query_id: message.id, url:'http://telegram.me/OchoNoobsBot')			  
	  end
	end
  end
end

