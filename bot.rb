# Importamos la libreria de telegram-bot
# Para instalarla en tu maquina:
require 'telegram/bot'
require './constants'
require './read_json'
require './member'
# Token de nuestro bot. String proporcionado por BotFather
# Por motivos de seguridad no lo colocamos aqui
token = Constants::TOKEN
# ======================================================================
# =============== Metodos para el manejo de los mensajes ===============

# Metodo para dar la bienvenida a nuevos miembros y referirle las normas
def welcome_message(bot, name, msj)
  bot.api.send_message(chat_id: msj.chat.id, text: "Bienvenido a 8Noob, #{name}")
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
      usr = message.text.split(' ')[5].delete('@')
      numero = ReadJSON.num_messages_user(usr)
      mensaje = "Este usuario ha escrito #{numero} mensajes"
      bot.api.send_message(chat_id: message.chat.id, text: mensaje,
                           reply_to_message_id: message.message_id)
    end
  end
end

def last_message(bot, message)
  if Constants::ADMINS.include?message.from.username
    case message.text
    when /bot, ultimo mensaje de/
      usr = message.text.split(' ')[4].delete('@')
      numero = ReadJSON.last_message(usr)
      mensaje = "Este usuario escribió por última vez hace #{numero} días"
      bot.api.send_message(chat_id: message.chat.id, text: mensaje,
                           reply_to_message_id: message.message_id)
    end
  end
end

def inactive_member(bot, message)
  if Constants::ADMINS.include?message.from.username
    case message.text
    when /bot, esta inactivo/
      msj = ''
      usr = message.text.split(' ')[3].delete('@')
      if ReadJSON.inactive_member(usr)
        msj = 'Si. El usuario lleva  20 días o más sin hablar'
      else
        msj = 'No. El usuario lleva menos de 20 días sin hablar'
      end
      bot.api.send_message(chat_id: message.chat.id,
                           text: msj,
                           reply_to_message_id: message.message_id)
    end
  end
end

def inactive_members(bot, message)
  if Constants::ADMINS.include?message.from.username
    case message.text
    when /bot, muestrame los inactivos/
      msj = ''
      ReadJSON.inactive_members.each { |x| msj = msj + x + ". #{ReadJSON.last_message(x)} días sin hablar \n" }
      if msj.empty?
        bot.api.send_message(chat_id: message.chat.id,
                             text: 'No existen miembros inactivos',
                             reply_to_message_id: message.message_id)
      else
        bot.api.send_message(chat_id: message.chat.id,
                             text: msj,
                             reply_to_message_id: message.message_id)
      end
    end
  end
end

def insert_member(message)
  unless message.chat.id != Constants::ID_GROUP
    usr = message.from
    date = Time.at(message.date).to_s
    member = Member.new(usr.id.to_s, usr.first_name, usr.username, date)
    member.insert
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
        end
        unless message.from.id.nil?
          insert_member(message)
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
