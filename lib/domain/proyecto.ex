defmodule Domain.Proyecto do
  @moduledoc """
  Representa un proyecto desarrollado por un equipo.
  """

  defstruct [:id, :id_equipo, :titulo, :descripcion, :categoria, :estado, :avances]

  @type t :: %__MODULE__{
          id: String.t(),
          id_equipo: String.t(),
          titulo: String.t(),
          descripcion: String.t(),
          categoria: String.t(),
          estado: :estado,
          avances: [String.t()]
        }

  @doc """
  Crea un nuevo proyecto asociado a un equipo.
  """
  def nuevo(id, id_equipo, titulo, descripcion, categoria) do
    %__MODULE__{
      id: id,
      id_equipo: id_equipo,
      titulo: titulo,
      descripcion: descripcion,
      categoria: categoria,
      estado: :en_desarrollo,
      avances: []
    }
  end

  @doc """
  Agrega un nuevo avance (texto) a la lista de avances.
  """
  def agregar_avance(%__MODULE__{avances: lista} = p, texto) do
    %{p | avances: lista ++ [texto]}
  end
end
