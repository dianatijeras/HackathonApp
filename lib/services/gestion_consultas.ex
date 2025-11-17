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

end
