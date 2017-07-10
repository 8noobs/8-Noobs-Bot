require'./constants'
# Modulo que contiene todas las funciones necesarias
# para realizar las diferentes conexiones (leer, insertar, modificar)
# con la base de datos
module DBCon
  DATA_BASE = Constants::DB
  #===================================================================
  #============= SECCION DE METODOS DE QUERY =========================

  # Select de todos los usarios de la db
  def self.users_query
    DATA_BASE.query('Select * from Usuario').each
  end

  def self.single_user_query(field, value)
    DATA_BASE.query("Select * From Usuario where #{field} = #{value}")
  end

  def self.msj_query(id)
    DATA_BASE.query("Select * From Mensaje Where id = #{id}")
  end

  # Select de todos los mensajes de un usuario por orden de fecha
  def self.msj_query_user(field, value)
    DATA_BASE.query("Select * from Mensaje
              Where #{field} = #{value} ORDER BY 3 DESC")
  end

  def self.last_date(id)
    date = msj_query_user('id_user', id).map { |y| y['fecha'] }.max
    (Time.now.to_date - date.to_date).to_i
  end

  # Numero de dias desde su ultimo mensaje
  def self.last_message(id_user)
    case msj_query_user('id_user', id_user).count
    when 0
      'Nunca ha escrito'
    else
      last_date = last_date(id_user)
      case last_date
      when 0
        'Hoy ha estado escribiendo'
      when 1
        'Hace 1 día que no escribe'
      else
        "Hace #{last_date} días que no escribe"
      end
    end
  end

  # Numero de mensajes
  def self.num_messages(field, value)
    msj_query_user(field, value).size
  end

  #======================================================================

  #======================================================================
  #============== SECCION DE METODOS DE INSERT ==========================
  # Insercion de un usuario
  def self.insert_user(id, alias_user, nombre)
    DATA_BASE.query("INSERT INTO Usuario VALUES (#{id}, '#{alias_user}', '#{nombre}')")
  end

  # Insercion de un mensajes asociado a un usuario
  def self.insert_msj(id, texto, fecha, audio, documento, video, foto, id_user)
    # Necesitamos escapar las comillas simples
    texto = texto.gsub("'", "\\\\'") unless texto.nil?
    DATA_BASE.query("INSERT INTO Mensaje VALUES
               (#{id}, '#{texto}', '#{fecha}',
                #{audio},#{documento}, #{video}, #{foto}, #{id_user})")
  end
  #=========================================================================
  #=========================================================================
  #=================SECCION DE METODOS UPDATE ==============================
  #========================================================================

  # Usamos este método para actualizar los datos de un usuario.
  # Los usuarios pueden cambiar de alias y de nombre, pero siempre
  # tedraán la misma id. Con este metodo actualizamos esos cambios
  def self.update_user(id, alias_user, nombre)
    DATA_BASE.query("UPDATE Usuario SET alias = '#{alias_user}', nombre = '#{nombre}'
              WHERE id = #{id}")
  end
end
