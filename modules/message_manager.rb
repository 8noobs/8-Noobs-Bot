require './modules/util'
require './constants'
# ======================================================================
# =============== Metodos para el manejo de los mensajes ===============
module Message_Manager
  # Metodo de envio del boton para ir a las normas
  def self.normas(_bot, msj)
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
    Util.send_message(chat_id: msj.chat.id,
                      text: 'Haz click abajo para ver las normas en privado',
                      reply_markup: markup)
  end

  # Metodo para hacer la peticion de envio de normas
  def self.envio_normas(bot, msj)
    if Util.is_admin(msj)
      case msj.text
      when /^([Hh]uginn|[Mm]uninn), env(i|ía)a las normas/i
        normas(bot, msj)
      end
    end
  end

  # Metodo para el envio del repositorio en el que se encuentra el bot
  def self.envio_repo(bot, msj)
    case msj.text
    when Util.bot_order('env(i|í)a tu repo')
      url = 'https://github.com/8noobs/8-Noobs-Bot'
      Util.send_message(bot, msj.chat.id, url)
    end
  end

  # Metodo para dar la bienvenida a nuevos miembros y referirle las normas
  def self.welcome_message(bot, name, msj)
    Util.send_message(chat_id: msj.chat.id,
                      text: "Bienvenido a 8Noob, #{name}.")
    normas(bot, msj)
  end

  # Metodo para el envio de las normas del grupo
  def self.start(_bot, message)
    if message.chat.id != Constants::ID_GROUP && message.text.include?('/start')
      Util.send_message(chat_id: message.chat.id, text: Constants::NORMAS,
                        parse_mode: 'Markdown')
    end
  end

  # Metodo para el envio de numeros de mensajes que ha enviado un usuario concreto
  def self.user_statistics(bot, message)
    if Util.is_admin(message)
      case message.text
      when Util.bot_order('estad(i|í)stic(as|a) de')
        case message.reply_to_message
        when nil
          username = message.text.split(' ')[3].delete('@')
          if Util.exist_alias(username)
            query = Data_Select.alias_query(username)
            id = query['id']
            nombre = query['nombre']
            num = DBCon.num_messages('id_user', id)
            msj_bot = "Alias: @#{username}, Nombre: #{nombre}. Numero de mensajes: #{num}"
            msj_bot += ". Fotos: #{Data_Select.num_photo(id)}. Videos: #{Data_Select.num_video(id)}. Audios: #{Data_Select.num_audio(id)}. Documentos: #{Data_Select.num_doc(id)}"
            Util.send_message(bot, message.chat.id, msj_bot)
          elsif exist_name(username)
            query = Data_Select.name_query(username)
            case query.size
            when 1
              id = query.first['id']
              name = query.first['nombre']
              num = DBCon.num_messages('id_user', id)
              msj_bot = "Nombre: #{name}. Numero de mensajes: #{num}"
              msj_bot += ". Fotos: #{Data_Select.num_photo(id)}. Videos: #{Data_Select.num_video(id)}. Audios: #{Data_Select.num_audio(id)}. Documentos: #{Data_Select.num_doc(id)}"
              Util.send_message(bot, message.chat.id, msj_bot)
            else
              Util.send_message(bot, message.chat.id, 'Mi memoria me dice que en nuestro clan hay más de un miembro con ese nombre. Mis señores serán los encargados de dilucidar quien es quien.')
              sleep(2)
              i = 1
              query.each do |array|
                id = array['id']
                name = array['nombre']
                num = DBCon.num_messages('id_user', id)
                msj_bot = "Nombre: #{name}. Numero de mensajes: #{num}"
                msj_bot += ". Fotos: #{Data_Select.num_photo(id)}. Videos: #{Data_Select.num_video(id)}. Audios: #{Data_Select.num_audio(id)}. Documentos: #{Data_Select.num_doc(id)}"
                i += 1
                Util.send_message(bot, message.chat.id, msj_bot)
                sleep(2)
              end
            end
          else
            Util.no_user(bot, message)
          end
        else
          id_user = message.reply_to_message.from.id
          hash = Data_Select.id_query(id_user)
          username = hash['alias']
          nombre = hash['nombre']
          msj_bot = !username.empty? ? "Alias: @#{username}, Nombre: #{nombre}" : "Nombre: #{nombre}."
          msj_bot += ". Número de mensajes: #{DBCon.num_messages('id_user', id_user)}"
          msj_bot += ". Fotos: #{Data_Select.num_photo(id_user)}. Videos: #{Data_Select.num_video(id_user)}. Audios: #{Data_Select.num_audio(id_user)}. Documentos: #{Data_Select.num_doc(id_user)}"
          Util.send_message(bot, message.chat.id, msj_bot)
        end
      end
    end
  end

  # Metodo que hace que el bot envie el numero de días que un usuario
  # está sin escribir
  def self.last_message(bot, message)
    if Util.is_admin(message)
      case message.text
      when Util.bot_order('ultimo mensaje de')
        case message.reply_to_message
        when nil
          username = message.text.split(' ')[4].delete('@')
          if Util.exist_alias(username)
            query = Data_Select.alias_query(username)
            id = query['id']
            nombre = query['nombre']
            date = DBCon.last_message(id)
            msj_bot = "Alias: @#{username}, Nombre: #{nombre}. #{date}"
            Util.send_message(bot, message.chat.id, msj_bot)
          elsif exist_name(username)
            query = Data_Select.name_query(username)
            case query.size
            when 1
              id = query.first['id']
              name = query.first['nombre']
              date = DBCon.last_message(id)
              msj_bot = "Nombre: #{name}. #{date}"
              Util.send_message(bot, message.chat.id, msj_bot)
            else
              Util.send_message(bot, message.chat.id, 'Mi memoria me dice que en nuestro clan hay más de un miembro con ese nombre. Mis señores serán los encargados de dilucidar quien es quien.')
              sleep(2)
              i = 1
              query.each do |array|
                id = array['id']
                name = array['nombre']
                date = DBCon.last_message(id)
                msj_bot = "#{i}. Nombre: #{name}. #{date}"
                i += 1
                Util.send_message(bot, message.chat.id, msj_bot)
                sleep(2)
              end
            end
          else
            Util.no_user(bot, message)
          end

        else
          id_user = message.reply_to_message.from.id
          hash = Data_Select.id_query(id_user)
          msj_bot = 'Este usuario no está en la base de datos'
          unless hash.nil?
            username = hash['alias']
            nombre = hash['nombre']
            msj_bot = !username.empty? ? "Alias: @#{username}, Nombre: #{nombre}" : "Nombre: #{nombre}."
            msj_bot += '. ' + DBCon.last_message(id_user)
            Util.send_message(bot, message.chat.id, msj_bot)
          end
        end
      end
    end
  end

  # Mensaje que envía si un miembro está inactivo
  def self.inactive_member(bot, message)
    if Util.is_admin(message)
      case message.text
      when Util.bot_order('est(a|á) inactivo')
        case message.reply_to_message
        when nil
          username = message.text.split(' ')[3].delete('@')
          if Util.exist_alias(username)
            query = Data_Select.alias_query(username)
            id = query['id']
            name = query['nombre']
            Util.inactivo(bot, message, id, [username, name])
          elsif Util.exist_name(username)
            query = Data_Select.name_query(username)
            case query.size
            when 1
              id = query.first['id']
              name = query.first['nombre']
              Util.inactivo(bot, message, id, [name])
            else
              Util.send_message(bot, message.chat.id, 'Mi memoria me dice que en
              nuestro clan hay más de un miembro con ese nombre.
              Mis señores serán los encargados de dilucidar quien es quien.')
              sleep(2)
              i = 1
              query.each do |array|
                id = array['id']
                name = array['nombre']
                Util.inactivo(bot, message, id, [name])
                i += 1
                sleep(2)
              end
            end
          else
            Util.no_user(bot, message)
          end
        else
          id_user = message.reply_to_message.from.id
          hash = Data_Select.id_query(id_user)
          msj_bot = 'Este usuario no está en la base de datos'
          unless hash.nil?
            username = hash['alias']
            name = hash['nombre']
            msj_bot = !username.empty? ? Util.inactivo(bot, message, id, [name]) :
                                         Util.inactivo(bot, message, id, [username, name])
          end
        end
      end
    end
  end

  # Envio de mensaje con lista de miembros inactivos
  def self.inactive_members(bot, message)
    if Util.is_admin(message)
      case message.text
      when Util.Util.bot_order('mu(e|é)strame los inactivos')
        query = DBCon.users_query.select { |x| DBCon.last_date(x['id']) > 20 }
        msj = 'Miembros inactivos'
        if query.empty?
          Util.send_message(bot, message.chat.id, 'No hay miembros inactivos')
        else
          query.each do |hash|
            if hash['alias'].empty?
              msj += "\n Nombre: #{hash['nombre']}.Hace #{DBCon.last_date(hash['id'])} días."
            else
              msj += "\n Alias: @#{hash['alias']}, Nombre: #{hash['nombre']}. Hace #{DBCon.last_date(hash['id'])} días."
            end
          end
        end
        Util.send_message(bot, message.chat.id, msj)
      end
    end
  end

  def self.count_members(bot, message)
    if Util.is_admin(message)
      case message.text
      when Util.bot_order('a cu(a|á)ntos conoces')
        query = DBCon.users_query
        total = bot.api.getChatMembersCount(chat_id: Constants::ID_GROUP)
        Util.send_message(bot, message.chat.id, "De #{total['result']} miembros solo conozco a #{query.size}")
        sleep(2)
        Util.send_message(bot, message.chat.id, 'Estos son ...')
        sleep(2)
        msj = ''
        query.each { |hash| msj += hash['nombre'].delete('?') + "\n" }
        Util.send_message(bot, message.chat.id, msj)
      when Util.bot_order('estadisticas ')
      end
    end
  end

  def self.bot_age(bot, message)
    if Util.is_admin(message)
      case message.text
      when Util.bot_order('dias activo')
        num = Time.now.to_date - Constants::TIME_BEGIN
        Util.send_message(bot, message.chat.id, "#{num.to_i} días.")
      end
    end
  end
end
#========================================================================
