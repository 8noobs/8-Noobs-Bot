#==============================================================================
#=================== METODOS PARA RECOGER DATOS ===============================
require "../db/db_con"
module Data_Select
  # Metodo que nos devuelve la informacion de un usuario por su id
  def self.id_query(id)
    DBCon.single_user_query('id', id).first
  end

  # Metodo que nos devuelve la informacion de un usuario buscandolo por su alias
  def self.alias_query(alias_user)
    DBCon.single_user_query('alias', "'#{alias_user}'").first
  end

  # Metodo que nos devuelve la informacion de todos los usuarios con cierto nombre
  def self.name_query(name)
    DBCon.single_user_query('nombre', "'#{name}'")
  end

  # Informacion de todos los mensajes de un usuario por su id
  def self.msg_query(id_user)
    DBCon.msj_query_user('id_user', id_user)
  end

  # Numero de mensajes que contenian fotos, de un usuario, por su id
  def self.num_photo(id_user)
    msg_query(id_user).map { |msg| msg['foto'] }.sum
  end

  # Numero de mensajes que contenian video, de un usuario, por su id
  def self.num_video(id_user)
    msg_query(id_user).map { |msg| msg['video'] }.sum
  end

  # Numero de mensajes que contenian audio, de un usuario, por su id
  def self.num_audio(id_user)
    msg_query(id_user).map { |msg| msg['audio'] }.sum
  end

  # Numero de mensajes que contenian docuento, de un usuario por su id
  def self.num_doc(id_user)
    msg_query(id_user).map { |msg| msg['documento'] }.sum
  end
end
#==============================================================================
