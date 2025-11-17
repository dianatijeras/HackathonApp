defmodule Domain.Equipo do
  @moduledoc """
  Representa un equipo participante en la hackathon.

  """

  defstruct [:id, :nombre, :tema, :integrantes]

  @type t :: %__MODULE__{
          id: String.t(),
          nombre: String.t(),
          tema: String.t(),
          integrantes: [String.t()]
        }

  @doc """
  Crea un nuevo equipo vacío.
  """
  def nuevo(id, nombre, tema) do
    %__MODULE__{
      id: id,
      nombre: nombre,
      tema: tema,
      integrantes: []
    }
  end

  @doc """
  Agrega un participante al equipo (si no está repetido).
  """
  def agregar_integrante(%__MODULE__{integrantes: lista} = equipo, id_usuario) do
    if id_usuario in lista do
      equipo
    else
      %{equipo | integrantes: lista ++ [id_usuario]}
    end
  end
end
