require 'telegram/bot'
require './constants'
require './db/db_con'

# Token de nuestro bot. String proporcionado por BotFather
# Por motivos de seguridad no lo colocamos implicito aquí
token = Constants::TOKEN

# ======================================================================
# =============== Metodos para el manejo de los mensajes ===============

# Metodo de envio del boton para ir a las normas
def normas(bot, msj)
  # kb es un array con la construccion de lo botones de un teclado
  # inline. En este caso solo hay una opcion "Normas"
  kb = [Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Normas en chat',
                                                       callback_data: 'normas'),
	      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Normas en web',
								                                       url: Constants::NORMAS_URL)]
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
  if is_admin(msj)    
		case msj.text
    when %r{^([Hh]uginn|[Mm]uninn), env(i|ía)a las normas}i
      normas(bot, msj)
    end
  end
end

# Metodo para el envio del repositorio en el que se encuentra el bot
def envio_repo(bot, msj)
  case msj.text
  when bot_order('env(i|í)a tu repo')
    url = 'https://github.com/8noobs/8-Noobs-Bot'
    send_message(bot, msj.chat.id, url)
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
    bot.api.send_message(chat_id: message.chat.id, text: Constants::NORMAS,
						                parse_mode: 'Markdown')
  end
end

# Metodo para el envio de numeros de mensajes que ha enviado un usuario concreto
def user_statistics(bot, message)
  if is_admin(message)
    case message.text
    when bot_order('estad(i|í)stic(as|a) de')
		  case message.reply_to_message
			when nil 
			  username = message.text.split(' ')[3].delete("@")
        if exist_alias(username) 
				  query = alias_query(username) 
		      id = query['id']
					nombre = query['nombre']
					num = DBCon.num_messages('id_user', id)
          msj_bot = "Alias: @#{username}, Nombre: #{nombre}. Numero de mensajes: #{num}"
					msj_bot += ". Fotos: #{num_photo(id)}. Videos: #{num_video(id)}. Audios: #{num_audio(id)}. Documentos: #{num_doc(id)}"  
					send_message(bot, message.chat.id, msj_bot)
			  elsif exist_name(username)
		      query = name_query(username)
		      case query.size
					when 1
            id = query.first['id']
						name = query.first['nombre']
		        num = DBCon.num_messages('id_user', id)
						msj_bot = "Nombre: #{name}. Numero de mensajes: #{num}"
						msj_bot += ". Fotos: #{num_photo(id)}. Videos: #{num_video(id)}. Audios: #{num_audio(id)}. Documentos: #{num_doc(id)}"
            send_message(bot, message.chat.id, msj_bot)
					else
            send_message(bot, message.chat.id, 'Mi memoria me dice que en nuestro clan hay más de un miembro con ese nombre. Mis señores serán los encargados de dilucidar quien es quien.')
						sleep(2)
		        i = 1
		        query.each do |array|
						  id = array['id']
							name = array['nombre']
              num = DBCon.num_messages('id_user', id)
						  msj_bot = "Nombre: #{name}. Numero de mensajes: #{num}"
						  msj_bot += ". Fotos: #{num_photo(id)}. Videos: #{num_video(id)}. Audios: #{num_audio(id)}. Documentos: #{num_doc(id)}"
							i += 1
							send_message(bot, message.chat.id, msj_bot)
		          sleep(2)
						end
					end
			  else
          no_user(bot, message)
				end
			else
        id_user = message.reply_to_message.from.id
        hash = id_query(id_user)
				username = hash['alias']
        nombre = hash['nombre']
        msj_bot = !username.empty? ? "Alias: @#{username}, Nombre: #{nombre}" : "Nombre: #{nombre}."
        msj_bot += ". Número de mensajes: #{DBCon.num_messages('id_user', id_user)}"
				msj_bot += ". Fotos: #{num_photo(id_user)}. Videos: #{num_video(id_user)}. Audios: #{num_audio(id_user)}. Documentos: #{num_doc(id_user)}"
        send_message(bot, message.chat.id, msj_bot)
		  end
    end
  end
end

# Metodo que hace que el bot envie el numero de días que un usuario
# está sin escribir
def last_message(bot, message)
  if is_admin(message)
	  case message.text
    when bot_order('ultimo mensaje de')
		  case message.reply_to_message
      when nil 
			  username = message.text.split(' ')[4].delete("@")
        if exist_alias(username) 
				  query = alias_query(username) 
		      id = query['id']
					nombre = query['nombre']
					date = DBCon.last_message(id)
          msj_bot = "Alias: @#{username}, Nombre: #{nombre}. #{date}"
					send_message(bot, message.chat.id, msj_bot)
			  elsif exist_name(username)
		      query = name_query(username)
		      case query.size
					when 1
            id = query.first['id']
						name = query.first['nombre']
            date = DBCon.last_message(id)
		        msj_bot = "Nombre: #{name}. #{date}"
            send_message(bot, message.chat.id, msj_bot)
					else
            send_message(bot, message.chat.id, 'Mi memoria me dice que en nuestro clan hay más de un miembro con ese nombre. Mis señores serán los encargados de dilucidar quien es quien.')
						sleep(2)
		        i = 1
		        query.each do |array|
						  id = array['id']
							name = array['nombre']
              date = DBCon.last_message(id)
		          msj_bot = "#{i}. Nombre: #{name}. #{date}"
							i += 1
							send_message(bot, message.chat.id, msj_bot)
		          sleep(2)
						end
					end
			  else
          no_user(bot, message)
				end

			else
        id_user = message.reply_to_message.from.id
        hash = id_query(id_user) 
        msj_bot = 'Este usuario no está en la base de datos'
				if !hash.nil?
				  username = hash['alias']
          nombre = hash['nombre']
          msj_bot = !username.empty? ? "Alias: @#{username}, Nombre: #{nombre}" : "Nombre: #{nombre}."
          msj_bot += '. '+DBCon.last_message(id_user)
					send_message(bot, message.chat.id, msj_bot)
        end  
			end
    end
  end
end

# Mensaje que envía si un miembro está inactivo 
def inactive_member(bot, message)
  if is_admin(message)
    case message.text
    when bot_order('est(a|á) inactivo') 
     case message.reply_to_message
      when nil 
			  username = message.text.split(' ')[3].delete("@")
        if exist_alias(username) 
				  query = alias_query(username) 
		      id = query['id']
					name = query['nombre']
					inactivo(bot, message, id, [username, name])
			  elsif exist_name(username)
		      query = name_query(username)
		      case query.size
					when 1
            id = query.first['id']
						name = query.first['nombre']
		        inactivo(bot, message, id, [name])
					else
            send_message(bot, message.chat.id, 'Mi memoria me dice que en nuestro clan hay más de un miembro con ese nombre. Mis señores serán los encargados de dilucidar quien es quien.')
						sleep(2)
		        i = 1
		        query.each do |array|
						  id = array['id']
							name = array['nombre']
							inactivo(bot, message, id, [name])
		          i += 1
		          sleep(2)
						end
					end
			  else
          no_user(bot, message)
				end
			else
        id_user = message.reply_to_message.from.id
        hash = id_query(id_user) 
        msj_bot = 'Este usuario no está en la base de datos'
				if !hash.nil?
				  username = hash['alias']
          nombre = hash['nombre']
          msj_bot = !username.empty? ? inactivo(bot, message, id, [name]) :
					                             inactivo(bot, message, id, [username, name])
        end  
			end   
		end
  end
end
# Envio de mensaje con lista de miembros inactivos
def inactive_members(bot, message)
  if is_admin(message)
    case message.text
    when bot_order('mu(e|é)strame los inactivos')
      query = DBCon.users_query.select { |x| DBCon.last_date(x['id']) > 20 }
			msj = 'Miembros inactivos'
			if query.empty?
			  send_message(bot, message.chat.id, "No hay miembros inactivos")
			else
        query.each do |hash|
			    if hash['alias'].empty? 
				    msj += "\n Nombre: #{hash['nombre']}.Hace #{DBCon.last_date(hash['id'])} días."
				  else
				    msj += "\n Alias: @#{hash['alias']}, Nombre: #{hash['nombre']}. Hace #{DBCon.last_date(hash['id'])} días."
				  end
			  end
			end
			send_message(bot, message.chat.id, msj)
    end
  end
end
#========================================================================

#=========================================================================
#===================== METODOS PARA GUARDAR DATOS ========================

# Metodo que inserta la informacion del usuario
# en la base de datos
def insert_user(message)
  id = message.from.id
  first_name = message.from.first_name
  username = message.from.username
  case DBCon.users_query.map { |hash| hash['id'] == id }.any?
  when true
    DBCon.update_user(id, username, first_name)
  when false
    DBCon.insert_user(id, username, first_name)
  end
end
# Metodo que inserta informacion del mensaje enviado
# en la base de datos
def insert_msj(message)
  allowed_msg = ['/start XXXX']
	id_user = message.from.id
  id = message.message_id
  text = message.text
  date = Time.at(message.date)
  video = message.video.nil? ? 0 : 1
  photo = message.photo.empty? ? 0 : 1
  voice = message.voice.nil? ? 0 : 1
  document = message.document.nil? ? 0 : 1
	if message.chat.type == 'private'
	  if allowed_msg.include?text
      DBCon.insert_msj(id, text, date, voice, document, video, photo, id_user)
		end
	else
    if DBCon.msj_query(id).size.zero?
      DBCon.insert_msj(id, text, date, voice, document, video, photo, id_user)
    end
	end
end

#==============================================================================
#=================== METODOS PARA RECOGER DATOS ===============================

# Metodo que nos devuelve la informacion de un usuario por su id
def id_query(id)
  DBCon.single_user_query('id', id).first
end

# Metodo que nos devuelve la informacion de un usuario buscandolo por su alias
def alias_query(alias_user)
  DBCon.single_user_query('alias', "'#{alias_user}'").first
end

# Metodo que nos devuelve la informacion de todos los usuarios con cierto nombre
def name_query(name)
	DBCon.single_user_query('nombre', "'#{name}'")
end

# Informacion de todos los mensajes de un usuario por su id
def msg_query(id_user)
  DBCon.msj_query_user('id_user', id_user)
end

# Numero de mensajes que contenian fotos, de un usuario, por su id
def num_photo(id_user)
  msg_query(id_user).map { |msg| msg['foto']}.sum 
end

# Numero de mensajes que contenian video, de un usuario, por su id
def num_video(id_user)
  msg_query(id_user).map { |msg| msg['video'] }.sum
end

# Numero de mensajes que contenian audio, de un usuario, por su id
def num_audio(id_user)
  msg_query(id_user).map { |msg| msg['audio'] }.sum
end
# Numero de mensajes que contenian docuento, de un usuario por su id
def num_doc(id_user)
  msg_query(id_user).map { |msg| msg['documento'] }.sum
end
#==============================================================================

#==============================================================================
#======================= METODOS DE UTILIDAD ==================================


# Le pasamos un alias a este metodo y el nos devuelve un booleano
# true -> Existe un usuario con ese alias
# false -> no existe
def exist_alias(alias_user)
  name_query = DBCon.single_user_query('alias', "'#{alias_user}'").size == 1
end
# Analogo al anterior pero para el nombre
def exist_name(name_user)
 name_query = DBCon.single_user_query('nombre', "'#{name_user}'").size > 0 
end

def no_user(bot, message)
  send_message(bot, message.chat.id,'No tengo datos sobre este usuario')
end

# Metodo que devuelve true si entra nuevo miembro
def new_member(message)
  !message.new_chat_member.nil?
end

# Metodo que devuelve true si es del tipo Message
def is_message(message)
  case message
	when Telegram::Bot::Types::Message
	  return true
	else
	  return false
	end
end

def is_callback_query(message)
  case message
	when Telegram::Bot::Types::CallbackQuery
	  true
	else
	  false
	end
end
# Metodo que devuelve true si es el mensaje de un admin
def is_admin(message)
  Constants::ADMINS.include?message.from.id
end

# Metodo que devuelve true si el mensaje es mio
def is_me(message)
  message.from.username == 'TuorTurambar'
end
def not_defined(bot, message)
	random = (rand * 4).to_i	
	msg = ["Estamos trabajando en ello", "Funcionalidad en construcción, colega",
	            "Aun no he aprendido a hacer eso", "Mi creador aun no me ha dado ese poder"][random]	
  send_message(bot, message.chat.id, msg)
end

def send_message(bot, chat, msj)
  bot.api.send_message(chat_id: chat, text: msj)
end

# Metodo que devolvera una expresion regular a partir de una string
# Sera una expresion regular que no distinguira entre mayusculas y minusculas
# y comenzara exactamente con str
def reg_exp(str)
  %r{^#{str}}i
end

# Metodo que devolvera una expresion regular con el nombre del bot y una orden
# pasada por parametro
def bot_order(order)
  str = "(huginn|muninn), #{order}"
	reg_exp(str)
end

# Metodo para saber si un miembro está inactivo o no
# y enviar el mensaje correspondiente
def inactivo(bot, message, id, opc)
  date = DBCon.last_date(id)
  case opc.size
	when 2
	  msj_bot = "Alias: @#{opc[0]}, Nombre: #{opc[1]}. No está inactivo. Días sin hablar: #{date}"
	  if date > 20
	    msj_bot = "Alias: @#{opc[0]}, Nombre: #{opc[1]}. Está inactivo. Días sin hablar: #{date}" 
	  end
	  send_message(bot, message.chat.id, msj_bot)
  when 1
	   msj_bot = "Nombre: #{opc[0]}. No está inactivo. Días sin hablar: #{date}"
	  if date > 20
	    msj_bot = "Nombre: #{opc[0]}. Está inactivo. Días sin hablar: #{date}" 
	  end
	  send_message(bot, message.chat.id, msj_bot)
  end
end

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
            welcome_message(bot, first_name, message)
          end
        end
        # Cuando el texto del mensaje no es nulo, manejamos los diferentes
        # comandos o mensajes enviados.
        unless message.text.nil?
          start(bot, message)
          user_statistics(bot, message)
          last_message(bot, message)
          inactive_member(bot, message)
          inactive_members(bot, message)
          envio_normas(bot, message)
          envio_repo(bot, message)
					case message.text
					when 'responde'
            send_message(bot, message.chat.id, 'p' )
					end

        end
        unless message.from.id.nil?
          begin
            insert_user(message)
            insert_msj(message)
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

