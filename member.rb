require 'json'
require './constants'

# Clases para la creacion del objeto miembro y su manejo
# para guardar los datos
class Member
  attr_accessor :id, :nombre, :alias_user, :fecha_msj
  def initialize(id, nombre, alias_user, fecha_msj)
    @id = id
    @nombre = nombre
    @alias_user = alias_user
    @fecha_msj = fecha_msj
  end

  # Metodo para insertar los datos de los nuevos miembros
  # en el fichero .json
  def insert
    hash = JSON.parse(File.read(Constants::JSON_FILE))
    if hash.keys.include?@id
      hash[@id] = { 'alias' => @alias_user,
                    'nombre' => @nombre,
                    'mensajes' => hash[@id]['mensajes'].push(@fecha_msj) }
    else
      hash[@id] = { 'alias' => @alias_user, 'nombre' => @nombre,
                    'mensajes' => [@fecha_msj] }
    end
    f = File.new(Constants::JSON_FILE, 'w')
    f.write(JSON.pretty_generate(hash))
    f.close
  end
end
