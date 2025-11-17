defmodule Domain.Mentor do
  @moduledoc """
  Representa un mentor de la hackathon.

  Atributos:
    - id: identificador único del mentor.
    - nombre: nombre completo.
    - especialidad: área de conocimiento o experiencia.
  """

  defstruct [:id, :nombre, :especialidad, :correo, :contrasenia]

  @type t :: %__MODULE__{
          id: String.t(),
          nombre: String.t(),
          especialidad: String.t(),
          correo: String.t(),
          contrasenia: String.t()
        }

  @doc """
  Crea un nuevo mentor.
  """
  def nuevo(id, nombre, especialidad, correo, contrasenia) do
    %__MODULE__{
      id: id,
      nombre: nombre,
      especialidad: especialidad,
      correo: correo,
      contrasenia: contrasenia
    }
  end
end
