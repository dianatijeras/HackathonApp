defmodule Domain.Mensaje do
  @moduledoc """
  Representa un mensaje enviado en el chat de un equipo.
  """

  defstruct [
    :id,          # cadena única (puede ser timestamp ó secuencia)
    :equipo_id,   # a qué equipo pertenece
    :autor,       # nombre o id del participante
    :contenido,   # texto del mensaje
    :timestamp    # fecha/hora en string
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          equipo_id: String.t(),
          autor: String.t(),
          contenido: String.t(),
          timestamp: String.t()
        }
end
