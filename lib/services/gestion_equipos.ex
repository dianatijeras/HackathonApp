Code.require_file("../domain/equipo.ex", __DIR__)
Code.require_file("../adapters/persistencia_csv.ex", __DIR__)

defmodule Services.GestionEquipos do
  @moduledoc """
  Lógica de aplicación para manejar equipos de la hackathon.
  Todo se mantiene en memoria durante la ejecución.
  """

  alias Domain.Equipo


  @doc """
  Crea un nuevo equipo y lo guarda en memoria.
  """
  def crear_equipo(id, nombre, tema) do
    equipo = Equipo.nuevo(id, nombre, tema)
    lista = listar_equipos()
    PersistenciaCSV.escribir_equipos([equipo | lista])
    {:ok, equipo}
  end

end
