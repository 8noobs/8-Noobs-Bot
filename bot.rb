# Importamos la libreria de telegram-bot
# Para instalarla en tu maquina:
require 'telegram/bot'
require './constants'
require './db/db_con'
require './member'

# Token de nuestro bot. String proporcionado por BotFather
# Por motivos de seguridad no lo colocamos aqui
token = Constants::TOKEN

# ======================================================================
# =============== Metodos para el manejo de los mensajes ===============

# Metodo de envio del boton para ir a las normas
def normas(bot, msj)
  # kb es un array con la construccion de lo botones de un teclado
  # inline. En este caso solo hay una opcion "Normas"
  kb = [Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Normas',
                                                       callback_data: 'normas')]
  # markup es la variable que contiene el objeto teclado
  # al que le pasamos la variable con la lista de opciones
  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  # Aqui mandamos el mensaje con el teclado para que el usuario clicke
  bot.api.send_message(chat_id: msj.chat.id,
                       text: 'Haz click abajo para ver las normas en privado',
                       reply_markup: markup)
end

# Metodo para hacer la peticion de envio de normas
def envio_normas(bot, msj)
  case Constants::ADMINS.include?msj.from.username
  when true
    case msj.text
    when /bot, envia las normas/
      normas(bot, msj)
    end
  end
end

# Metodo para el envio del repositorio en el que se encuentra el bot
def envio_repo(bot, msj)
  case msj.text
	when /bot, envia tu repo/
	  url = 'https://github.com/8noobs/8-Noobs-Bot'
    bot.api.send_message(chat_id: msj.chat.id,
						              text: url)
													
	end
end
# Metodo para dar la bienvenida a nuevos miembros y referirle las normas
def welcome_message(bot, name, msj)
  bot.api.send_message(chat_id: msj.chat.id,
                       text: "Bienvenido a 8Noob, #{name}.")
  normas(bot, msj)
end

# Metodo para el envio de las normas del grupo
def start(bot, message)
  if message.chat.id != Constants::ID_GROUP && message.text.include?('/start')
    bot.api.forward_message(chat_id: message.chat.id,
                            # Se separan los numeros con _ para dar legibilidad
                            from_chat_id: 209_566_334,
                            message_id: 384)
  end
end
# Metodo para el envio de numeros de mensajes que ha enviado un usuario concreto
def num_messages(bot, message)
  if Constants::ADMINS.include?message.from.username
    case message.text
    when /bot, numero de mensajes de/

    end
  end
end

def last_message(bot, message)
  if Constants::ADMINS.include?message.from.username
    case message.text
    when /bot, ultimo mensaje de/

    end
  end
end

def inactive_member(bot, message)
  if Constants::ADMINS.include?message.from.username
    case message.text
    when /bot, esta inactivo/

    end
  end
end

def inactive_members(bot, message)
  if Constants::ADMINS.include?message.from.username
    case message.text
    when /bot, muestrame los inactivos/

    end
  end
end

def insert_member(message)
  unless message.chat.id != Constants::ID_GROUP

  end
end

def insert_user(message)
  id = message.from.id
  first_name = message.from.first_name
  username = message.from.username
  case DBCon.user_query.map { |hash| hash['id'] == id }.any?
  when true
    DBCon.update_user(id, username, first_name)
  when false
    DBCon.insert_user(id, username, first_name)
  end
end

def insert_msj(message)
  id_user = message.from.id
  id = message.message_id
  text = message.text
  date = Time.at(message.date)
  video = message.video.nil? ? 0 : 1
  photo = message.photo.empty? ? 0 : 1
  voice = message.voice.nil? ? 0 : 1
  document = message.document.nil? ? 0 : 1
  if DBCon.msj_query(id).size.zero?
    DBCon.insert_msj(id, text, date, voice, document, video, photo, id_user)
  end
end
#==============================================================================

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
            welcome_message(bot, first_name, message)
          end
        end
        # Cuando el texto del mensaje no es nulo, manejamos los diferentes
        # comandos o mensajes enviados.
        unless message.text.nil?
          start(bot, message)
          num_messages(bot, message)
          last_message(bot, message)
          inactive_member(bot, message)
          inactive_members(bot, message)
					envio_normas(bot, message)
		      envio_repo(bot, message)
        end
        unless message.from.id.nil?
          begin
            insert_user(message)
            insert_msj(message)
          rescue Mysql2::Error => e
            puts e.exception
            puts e.backtrace
          end
        end
      rescue NoMethodError => e
        puts e.exception
        puts e.backtrace
      end

    # Aqui vemos si el mensaje recibido es de tipo CallbackQuery.
    # Por ejemplo cuando pulsamos el boton 'ver normas', estamos mandando
    # un mensaje de tipo CallbackQuery
    when Telegram::Bot::Types::CallbackQuery
      begin
        if message.data == 'normas'
          puts message.id
          bot.api.answerCallbackQuery(callback_query_id: message.id,
                                      url: 'http://telegram.me/OchoNoobsBot?start=XXXX')
        end
      rescue StandardError => e
        puts e.exception
        puts e.backtrace
      end
    end
  end
end
