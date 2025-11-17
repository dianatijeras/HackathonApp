Code.require_file("../domain/proyecto.ex", __DIR__)
Code.require_file("../adapters/persistencia_csv.ex", __DIR__)
defmodule Services.GestionProyectos do
  @moduledoc """
  Lógica de aplicación para gestionar proyectos desarrollados por equipos.
  Mantiene los proyectos en memoria.
  """

  alias Domain.Proyecto

  @doc """
  Registra un nuevo proyecto asociado a un equipo.
  """
  def registrar_proyecto(id, id_equipo, titulo, descripcion, categoria) do
    proyecto = Proyecto.nuevo(id, id_equipo, titulo, descripcion, categoria)
    lista = listar_proyectos()
    PersistenciaCSV.escribir_proyectos([proyecto | lista])
    {:ok, proyecto}
  end

end
