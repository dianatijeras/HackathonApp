Code.require_file("../domain/consulta.ex", __DIR__)
Code.require_file("../adapters/persistencia_csv.ex", __DIR__)

defmodule Services.GestionConsultas do

  alias Domain.Consulta

  @doc "Registra una nueva consulta enviada por un equipo a un mentor."
  def registrar_consulta(id_equipo, id_mentor, mensaje) do
    numero = :rand.uniform(9999) - 1

    id_num = :io_lib.format("~4..0B", [numero]) |> List.to_string()
    id = "C-" <> id_num
    timestamp = NaiveDateTime.local_now() |> NaiveDateTime.to_string()

    consulta = %Consulta{
      id: id,
      id_equipo: id_equipo,
      id_mentor: id_mentor,
      mensaje: mensaje,
      respuesta: nil,
      timestamp: timestamp
    }

    consultas = Adapters.PersistenciaCSV.leer_consultas()
    nuevas = [consulta | consultas]
    Adapters.PersistenciaCSV.escribir_consultas(nuevas)

    {:ok, consulta}
  end

  @doc "Permite que el mentor responda una consulta."
  def responder_consulta(id_consulta, respuesta) do
    consultas = Adapters.PersistenciaCSV.leer_consultas()

    case Enum.find(consultas, fn c -> c.id == id_consulta end) do
      nil ->
        {:error, "Consulta no encontrada"}

      consulta ->
        actualizada = %{consulta | respuesta: respuesta}

        nuevas =
          [actualizada |
          Enum.reject(consultas, fn c -> c.id == id_consulta end)]

        Adapters.PersistenciaCSV.escribir_consultas(nuevas)

        # Registrar en proyecto como avance
        Services.GestionProyectos.agregar_avance(
          consulta.id_equipo,
          "Retroalimentación del mentor #{consulta.id_mentor}: #{respuesta}"
        )

        {:ok, actualizada}
    end
  end

  @doc """
  lista todas las consultas asignadas a un mentor
  """
  def listar_por_mentor(id_mentor) do
    Adapters.PersistenciaCSV.leer_consultas()
    |> Enum.filter(fn c -> c.id_mentor == id_mentor end)
  end

end
