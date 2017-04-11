# Modulo que contiene todas las funciones necesarias
# para realizar las diferentes conexiones (leer, insertar, modificar)
# con la base de datos
module DBCon
  DB = Constants::DB
  #===================================================================
  #============= SECCION DE METODOS DE QUERY =========================

  # Select de todos los usarios de la db
  def self.user_query
    DB.query('Select * from Usuario').each
  end

  def self.msj_query(id)
    DB.query("Select * From Mensaje Where id = #{id}")
  end

  # Select de todos los mensajes de un usuario por orden de fecha
  def self.msj_query_user(field, value)
    DB.query("Select * from Mensaje
              Where #{field} = #{value} ORDER BY 3 DESC")
  end

  # Numero de dias desde su ultimo mensaje
  def self.last_message(field, value)
    case msj_query(field, value).count
    when 0
      'Nunca'
    else
      dates = []
      msj_query(field, value).map { |hash| dates.push(hash['fecha']) }
      -(dates.max.to_date - Time.now.to_date).to_i
    end
  end

  # Numero de mensajes
  def self.num_messages(field, value)
    msj_query(field, value).size
  end

  #======================================================================

  #======================================================================
  #============== SECCION DE METODOS DE INSERT ==========================
	
  # Insercion de un usuario 
  def self.insert_user(id, alias_user, nombre)
    DB.query("INSERT INTO Usuario VALUES (#{id}, '#{alias_user}', '#{nombre}')")
  end
  # Insercion de un mensajes asociado a un usuario
  def self.insert_msj(id, texto, fecha, audio, documento, video, foto, id_user)
    # Necesitamos escapar las comillas simples
    texto = texto.gsub("'", "\\\\'") unless texto.nil?
    DB.query("INSERT INTO Mensaje VALUES
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
    DB.query("UPDATE Usuario SET alias = '#{alias_user}', nombre = '#{nombre}'
              WHERE id = #{id}")
  end
end
