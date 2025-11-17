defmodule Domain.Consulta do
  @moduledoc "Consulta enviada por un equipo a un mentor durante la hackathon."

  @type t :: %__MODULE__{
          id: String.t(),
          id_equipo: String.t(),
          id_mentor: String.t(),
          mensaje: String.t(),
          respuesta: String.t() | nil,
          timestamp: String.t()
        }

  defstruct [
    :id,
    :id_equipo,
    :id_mentor,
    :mensaje,
    respuesta: nil,
    timestamp: nil
  ]
end
