defmodule Domain.Mensaje do
  @moduledoc """
  Representa un mensaje enviado en el chat de un equipo.
  """

  defstruct [
    :id,
    :equipo_id,
    :autor,
    :contenido,
    :timestamp    
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          equipo_id: String.t(),
          autor: String.t(),
          contenido: String.t(),
          timestamp: String.t()
        }
end
