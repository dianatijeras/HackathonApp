defmodule Domain.Participante do
  @moduledoc """
  Representa un usuario del sistema. Puede ser participante o mentor.
  """

  defstruct [:id, :nombre, :correo, :contrasenia]

  @type t :: %__MODULE__{
          id: String.t(),
          nombre: String.t(),
          correo: String.t(),
          contrasenia: String.t()
        }

  @doc """
  Crea un nuevo usuario.
  """
  def nuevo(id, nombre, correo, contrasenia) do
    %__MODULE__{
      id: id,
      nombre: nombre,
      correo: correo,
      contrasenia: contrasenia
    }
  end
end
