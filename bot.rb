# Importamos la libreria de telegram-bot
# Para instalarla en tu maquina:
require 'telegram/bot'
require './constants'
# Token de nuestro bot. String proporcionado por BotFather
# Por motivos de seguridad no lo colocamos aqui
token = Constants::TOKEN

# El metodo run pondra a nuestro bot en funcionamiento
# Se trata de un loop infinito en el que el bot va procesando
# los mensajes que le llegan
Telegram::Bot::Client.run(token) do |bot|
  # el bot escucha en cada iteracion del ciclo
  bot.listen do |message|
    case message
    # Aqui la condicion  que imponemos es que el mensaje sea de tipo texto
    # Message => Tipo texto plano
    when Telegram::Bot::Types::Message
      # Esta condicion es para verificar que el mensaje es de que un nuevo
      # miembro ha entrado al grupo
      if message.new_chat_member.class != nil.class
        # Condicion de que el usuario nuevo tenga username (alias)
        if !message.new_chat_member.username.nil?
          usr = '@' + message.new_chat_member.username
          msj = 'Bienvenido a 8Noobs, ' + usr
          bot.api.send_message(chat_id: message.chat.id, text: msj)
          # kb es un array con la construccion de lo botones de un teclado
          # inline. En este caso solo hay una opcion "Normas"
          kb = [Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Normas',
                                                               callback_data: 'normas')]
          # markup es la variable que contiene el objeto teclado
          # al que le pasamos la variable con la lista de opciones
          markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
          # Aqui mandamos el mensaje con el teclado para que el usuario clicke
          bot.api.send_message(chat_id: message.chat.id,
                               text: 'Haz click abajo para ver las normas en privado',
                               reply_markup: markup)
        else
          # Lo mismo que el bloque anterior pero con el nombre en vez del alias
          usr = message.new_chat_member.first_name
          msj = 'Bienvenido a 8Noobs, ' + usr
          bot.api.send_message(chat_id: message.chat.id, text: msj)
          kb = [Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Normas', callback_data: 'normas')]
          markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
          bot.api.send_message(chat_id: message.chat.id,
                               text: 'Haz click abajo para ver las normas en privado',
                               reply_markup: markup)
        end
      end
      # Esto es para que el bot no mande las reglas en el mismo grupo
      # si alguien escribe el comando /start
      # Estas lineas son las que reenvian el mensaje de normas cuando un usuario
      # escribe /start en privado.
      if !message.text.nil? && message.text.include?('/start')
        if message.chat.id != Constants::ID_GROUP
          bot.api.forward_message(chat_id: message.chat.id,
                                  from_chat_id: 209566334,
                                  message_id: 384)
        end
      end
      if !message.text.nil? && message.text.include?('bot consulta de inactivos')
        if message.from.username == 'TuorTurambar'

        end
      end
    # Aqui vemos si el mensaje recibido es de tipo CallbackQuery.
    # Por ejemplo cuando pulsamos el boton 'ver normas', estamos mandando
    # un mensaje de tipo CallbackQuery
    when Telegram::Bot::Types::CallbackQuery
      if message.data == 'normas'
        bot.api.answerCallbackQuery(callback_query_id: message.id, url: 'http://telegram.me/OchoNoobsBot')
      end
    end
  end
end
