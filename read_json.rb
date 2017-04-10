require 'json'
require 'date'
require './constants.rb'
# Conjunto de funcionalidades para manejar las estadisticas del grupo
# Las estadisticas estaran almacenadas en un archivo .json
module ReadJSON
  # Cargamos el fichero .json.
  DATA_FILE = File.read('data.json')
  # Convertimos el contenido del fichero en un hash
  # (diccionario o array asociativo)
  DATA_HASH = JSON.parse(DATA_FILE)

  # Metodo para conocer el numero de mensajes que un usuario ha escrito
  def self.num_messages_user(user)
    return DATA_HASH[search_user('alias', user)]['mensajes'].size unless search_user('alias', user).nil?
    return DATA_HASH[search_user('nombre', user)]['mensajes'].size unless search_user('nombre', user).nil?
    0
  end

  # Metodo para conocer cuantos dias lleva sin hablar un usuario
  def self.last_message(user)
    # Buscamos al usuario por su alias y guardamos su id
    id_username = search_user('alias', user)
    unless id_username.nil?
      date = DATA_HASH[id_username]['mensajes'].last.split(' ').first.split('-').map(&:to_i)
      last_date = Time.new(date[0], date[1], date[2])
      return (last_date.to_date - Time.now.to_date).to_i
    end
    # Buscamos al usuario por su nombre y guardamos su id. En caso de que no
    # hayamos encontrado al usuario por su alias (algunos no tienen)
    id_username = search_user('nombre', user)
    unless id_username.nil?
      date = DATA_HASH[id_username]['mensajes'].last.split(' ').first.split('-').map(&:to_i)
      last_date = Time.new(date[0], date[1], date[2])
      return (last_date.to_date - Time.now.to_date).to_i
    end
    # Si no encontramos al usuario ni por nombre ni por alias calcularemos
    # el tiempo que lleva sin hablar desde que el bot esta en funcionamiento
    # hasta ahora
    (Time.now.to_date - Constants::TIME_BEGIN).to_i
  end

  # Metodo que nos dice si un miembro (guardado en el fichero .json)
  # esta inactivo (La inactividad son > 20 dias sin escribir)
  def self.inactive_member(user)
    username = search_user('alias', user)
    nombre = search_user('nombre', user)
    if username.nil? && nombre.nil?
      return true
    else
      return last_message(user) > 20
    end
  end

  def self.inactive_members
    DATA_HASH.keys.select { |key| inactive_member(search_user_id(key)) }.map { |e| search_user_id(e) }
  end

  # Metodo para encontrar el id de un usuario, viendo si coincide
  # la clave para el valor pasado por parametros (key, value)
  # Es un metodo privado que nos ahorrara codigo  a la hora de buscar a los
  # usuarios de nuestro grupo y conocer sus estadisticas
  def self.search_user(key, value)
    DATA_HASH.keys.find { |id| DATA_HASH[id][key] == value }
  end

  # Metodo para encontrar el alias (en su defecto el nombre) de un usuario
  # por su id
  def self.search_user_id(id)
    DATA_HASH[id]['alias'] unless DATA_HASH[id]['alias'].nil?
    DATA_HASH[id]['nombre']
  end
end
