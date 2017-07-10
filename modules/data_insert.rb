require "./db/db_con"

#=========================================================================
#===================== METODOS PARA GUARDAR DATOS ========================

# Metodo que inserta la informacion del usuario
# en la base de datos
module Data_Insert
  def self.insert_user(message)
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
  def self.insert_msj(message)
    allowed_msg = ['/start XXXX']
    id_user = message.from.id
    id = message.message_id
    text = message.text
    date = Time.at(message.date) + 7200
    video = message.video.nil? ? 0 : 1
    photo = message.photo.empty? ? 0 : 1
    voice = message.voice.nil? ? 0 : 1
    document = message.document.nil? ? 0 : 1
    if message.chat.type == 'private'
      if allowed_msg.include? text
        DBCon.insert_msj(id, text, date, voice, document, video, photo, id_user)
      end
    else
      if DBCon.msj_query(id).size.zero?
        DBCon.insert_msj(id, text, date, voice, document, video, photo, id_user)
      end
    end
  end
end

#=============================================================================
