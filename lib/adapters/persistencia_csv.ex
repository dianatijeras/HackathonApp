Code.require_file("../domain/participante.ex", __DIR__)

defmodule Adapters.PersistenciaCSV do
  @moduledoc """
  Módulo encargado de la persistencia de datos en formato CSV.
  Contiene funciones para leer y escribir las entidades del sistema.
  """

  alias Domain.{Participante, Equipo, Proyecto, Mentor, Consulta}

  @dir Path.expand("../../data", __DIR__)


  # UTILIDAD
  defp ensure_dir, do: File.mkdir_p!(@dir)
  defp path(nombre), do: Path.join(@dir, "#{nombre}.csv")

  @doc """
  escribe la lista de participantes en un archivo CSV
  """
  def escribir_participantes(lista) do
    ensure_dir()
    headers = "ID,Nombre,Correo,Contraseña\n"

    contenido =
      Enum.map(lista, fn %Participante{id: id, nombre: nombre, correo: correo, contrasenia: contrasenia} ->
        "#{id},#{nombre},#{correo},#{contrasenia}\n"
      end)
      |> Enum.join()

    File.write(path("participantes"), headers <> contenido)
  end

  @doc """
  Lee la lista de participantes del archivo CSV
  """
  def leer_participantes do
    case File.read(path("participantes")) do
      {:ok, contenido} ->
        String.split(contenido, "\n", trim: true)
        |> Enum.map(fn linea ->
          case String.split(linea, ",") do
            ["ID", "Nombre", "Correo", "contraseña"] -> nil
            [id, nombre, correo, contrasenia] -> %Participante{id: id, nombre: nombre, correo: correo, contrasenia: contrasenia}
            _ -> nil
          end
        end)
        |> Enum.filter(& &1)

      {:error, _} ->
        []
    end
  end

end
