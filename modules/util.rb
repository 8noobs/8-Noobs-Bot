
#==============================================================================
#======================= METODOS DE UTILIDAD ==================================
module Util
  # Le pasamos un alias a este metodo y el nos devuelve un booleano
  # true -> Existe un usuario con ese alias
  # false -> no existe
  def self.exist_alias(alias_user)
    DBCon.single_user_query('alias', "'#{alias_user}'").size == 1
  end

  # Analogo al anterior pero para el nombre
  def self.exist_name(name_user)
    !DBCon.single_user_query('nombre', "'#{name_user}'").empty?
  end

  def self.no_user(bot, message)
    send_message(bot, message.chat.id, 'No tengo datos sobre este usuario')
  end

  # Metodo que devuelve true si entra nuevo miembro
  def self.new_member(message)
    !message.new_chat_member.nil?
  end

  # Metodo que devuelve true si es del tipo Message
  def self.is_message(message)
    case message
    when Telegram::Bot::Types::Message
      true
    else
      false
    end
  end

  def self.is_callback_query(message)
    case message
    when Telegram::Bot::Types::CallbackQuery
      true
    else
      false
    end
  end

  # Metodo que devuelve true si es el mensaje de un admin
  def self.is_admin(message)
    Constants::ADMINS.include? message.from.id
  end

  # Metodo que devuelve true si el mensaje es mio
  def self.is_me(message)
    message.from.username == 'TuorTurambar'
  end

  def self.not_defined(bot, message)
    random = (rand * 4).to_i
    msg = ['Estamos trabajando en ello', 'Funcionalidad en construcción, colega',
           'Aun no he aprendido a hacer eso', 'Mi creador aun no me ha dado ese poder'][random]
    send_message(bot, message.chat.id, msg)
  end

  def self.send_message(bot, chat, msj)
    bot.api.send_message(chat_id: chat, text: msj)
  end

  # Metodo que devolvera una expresion regular a partir de una string
  # Sera una expresion regular que no distinguira entre mayusculas y minusculas
  # y comenzara exactamente con str
  def self.reg_exp(str)
    /^#{str}/i
  end

  # Metodo que devolvera una expresion regular con el nombre del bot y una orden
  # pasada por parametro
  def self.bot_order(order)
    str = "(huginn|muninn), #{order}"
    reg_exp(str)
  end

  # Metodo para saber si un miembro está inactivo o no
  # y enviar el mensaje correspondiente
  def self.inactivo(bot, message, id, opc)
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
end
#============================================================================
