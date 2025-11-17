Code.require_file("../domain/mensaje.ex", __DIR__)
Code.require_file("../adapters/persistencia_csv.ex", __DIR__)

defmodule Services.GestionChats do
  @moduledoc """
  Gestiona el almacenamiento y consulta de mensajes de chat por equipo.
  """

  alias Domain.Mensaje
  alias Adapters.PersistenciaCSV

  # Guarda un mensaje en el historial CSV
  def registrar_mensaje(equipo_id, autor, contenido) do
    timestamp = DateTime.utc_now() |> DateTime.to_string()
    id = :erlang.unique_integer([:positive]) |> Integer.to_string()

    mensaje = %Mensaje{
      id: id,
      equipo_id: equipo_id,
      autor: autor,
      contenido: contenido,
      timestamp: timestamp
    }

    PersistenciaCSV.escribir_mensaje(mensaje)
    {:ok, mensaje}
  end

  # Devuelve historial completo del equipo
  def obtener_historial(equipo_id) do
    PersistenciaCSV.leer_mensajes()
    |> Enum.filter(fn msg -> msg.equipo_id == equipo_id end)
  end
end
