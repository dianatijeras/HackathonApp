Code.require_file("../domain/proyecto.ex", __DIR__)
Code.require_file("../adapters/persistencia_csv.ex", __DIR__)
defmodule Services.GestionProyectos do
  @moduledoc """
  Lógica de aplicación para gestionar proyectos desarrollados por equipos.
  Mantiene los proyectos en memoria.
  """

  alias Domain.Proyecto
  alias Adapters.PersistenciaCSV

  @doc """
  Registra un nuevo proyecto asociado a un equipo.
  """
  def registrar_proyecto(id, id_equipo, titulo, descripcion, categoria) do
    proyecto = Proyecto.nuevo(id, id_equipo, titulo, descripcion, categoria)
    lista = listar_proyectos()
    PersistenciaCSV.escribir_proyectos([proyecto | lista])
    {:ok, proyecto}
  end

  @doc """
  Lista todos los proyectos.
  """
  def listar_proyectos do
    PersistenciaCSV.leer_proyectos()
  end

  @doc """
  Agrega un avance de progreso a un proyecto existente.
  """
  def agregar_avance(id_proyecto, texto) do
    proyectos = PersistenciaCSV.leer_proyectos()

    case Enum.find(proyectos, fn p -> p.id == id_proyecto end) do
      nil ->
        {:error, "Proyecto no encontrado"}

      proyecto ->
        actualizado = Proyecto.agregar_avance(proyecto, texto)

        nuevos =
          proyectos
          |> Enum.reject(&(&1.id == id_proyecto))
          |> Kernel.++([actualizado])

        PersistenciaCSV.escribir_proyectos(nuevos)

        {:ok, actualizado}
    end
  end

end
