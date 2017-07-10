require 'telegram/bot'
require './db/db_con'
require './constants'
require './modules/data_insert'
require './modules/data_select'
require './modules/message_manager'
# Token de nuestro bot. String proporcionado por BotFather
# Por motivos de seguridad no lo colocamos implicito aquí
token = Constants::TOKEN

#==============================================================================
#================== PROGRAMA PRINCIPAL ========================================

# El metodo run pondra a nuestro bot en funcionamiento
# Se trata de un loop infinito en el que el bot va procesando
# los mensajes que le llegan
Telegram::Bot::Client.run(token) do |bot|
  # El bot escucha en cada iteracion del ciclo
  bot.listen do |message|
    case message
    # Aqui la condicion  que imponemos es que el mensaje sea de tipo texto
    # Message => Tipo texto plano
    when Telegram::Bot::Types::Message
      # Este begin es el comienzo de una estructura begin/rescue
      # donde vamos a capturar los posibles errores al procesar los mensajes
      # y ahorramos mucha condicion innecesaria

      begin
        unless message.new_chat_member.nil?
          user_name = message.new_chat_member.username
          first_name = message.new_chat_member.first_name
          if !user_name.nil? # En caso de que tenga un username
            welcome_message(bot, "@#{user_name}", message)
          else # En caso de que no tenga username
            Message_Manager.welcome_message(bot, first_name, message)
          end
        end
        # Cuando el texto del mensaje no es nulo, manejamos los diferentes
        # comandos o mensajes enviados.
        unless message.text.nil?
          Message_Manager.start(bot, message)
          Message_Manager.user_statistics(bot, message)
          Message_Manager.last_message(bot, message)
          Message_Manager.inactive_member(bot, message)
          Message_Manager.inactive_members(bot, message)
          Message_Manager.envio_normas(bot, message)
          Message_Manager.envio_repo(bot, message)
					Message_Manager.count_members(bot, message)
			    Message_Manager.bot_age(bot, message)
					case message.text
					when 'responde'
            send_message(bot, message.chat.id, 'p' )
					end

        end
        unless message.from.id.nil?
          begin
            Data_Insert.insert_user(message)
            Data_Insert.insert_msj(message)
          rescue Mysql2::Error => e
            puts e.backtrace
          end
        end
      rescue NoMethodError => e
        puts e.backtrace
				puts e.exception
      end

    # Aqui vemos si el mensaje recibido es de tipo CallbackQuery.
    # Por ejemplo cuando pulsamos el boton 'ver normas', estamos mandando
    # un mensaje de tipo CallbackQuery
    when Telegram::Bot::Types::CallbackQuery
      begin
        if message.data == 'normas'
          bot.api.answerCallbackQuery(callback_query_id: message.id,
                                      url: 'http://telegram.me/OchoNoobsBot?start=XXXX')
        end
      rescue StandardError => e
        puts e.backtrace
      end
    end
  end
end
