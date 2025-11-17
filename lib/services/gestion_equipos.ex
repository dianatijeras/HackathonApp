Code.require_file("../domain/equipo.ex", __DIR__)
Code.require_file("../adapters/persistencia_csv.ex", __DIR__)

defmodule Services.GestionEquipos do
  @moduledoc """
  Lógica de aplicación para manejar equipos de la hackathon.
  Todo se mantiene en memoria durante la ejecución.
  """

  alias Domain.Equipo
  alias Adapters.PersistenciaCSV

  @doc """
  Crea un nuevo equipo y lo guarda en memoria.
  """
  def crear_equipo(id, nombre, tema) do
    equipo = Equipo.nuevo(id, nombre, tema)
    lista = listar_equipos()
    PersistenciaCSV.escribir_equipos([equipo | lista])
    {:ok, equipo}
  end

  @doc """
  Lista todos los equipos registrados.
  """
  def listar_equipos do
    PersistenciaCSV.leer_equipos()
  end

  @doc """
  Agrega un participante (por ID de usuario) al equipo especificado.
  """
  def agregar_integrante(id_equipo, id_participante) do
    equipos = listar_equipos()

    case Enum.find(equipos, &(&1.id == id_equipo)) do
      nil -> {:error, "Equipo no encontrado"}
      equipo ->
        if Enum.member?(equipo.integrantes, id_participante) do
          {:error, "El participante ya pertenece a este equipo"}
        else
          actualizado = %{equipo | integrantes: [id_participante | equipo.integrantes]}
          nueva_lista =
            [actualizado | Enum.reject(equipos, &(&1.id == id_equipo))]

          PersistenciaCSV.escribir_equipos(nueva_lista)
          {:ok, actualizado}
        end
    end
  end

end
