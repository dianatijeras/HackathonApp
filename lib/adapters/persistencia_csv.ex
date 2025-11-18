Code.require_file("../domain/participante.ex", __DIR__)
Code.require_file("../domain/equipo.ex", __DIR__)
Code.require_file("../domain/mentor.ex", __DIR__)
Code.require_file("../domain/mensaje.ex", __DIR__)
Code.require_file("../domain/proyecto.ex", __DIR__)
Code.require_file("../domain/consulta.ex", __DIR__)


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

  # MENSAJES

  alias Domain.Mensaje

  @doc """
  Escribe un mensaje en el archivo CSV de mensajes.
  """
  def escribir_mensaje(%Mensaje{} = msg) do
    ensure_dir()

    linea =
      "#{msg.id},#{msg.equipo_id},#{msg.autor},#{msg.contenido},#{msg.timestamp}\n"

    File.write!(path("mensajes"), linea, [:append])
  end

  @doc """
  lee un mensaje en el archivo CSV de mensajes.
  """
  def leer_mensajes do
    case File.read(path("mensajes")) do
      {:ok, contenido} ->
        contenido
        |> String.split("\n", trim: true)
        |> Enum.map(&parse_mensaje/1)

      {:error, _} ->
        []
    end
  end


  #convierte una linea de texto del archivo csv de mensajes en una estructura de %Mensaje{}

  defp parse_mensaje(linea) do
    case String.split(linea, ",") do
      [id, equipo_id, autor, contenido, timestamp] ->
        %Mensaje{
          id: id,
          equipo_id: equipo_id,
          autor: autor,
          contenido: contenido,
          timestamp: timestamp
        }

      _ ->
        nil
    end
  end

  # EQUIPOS

  @doc """
  escribe la lista de equipos en un archivo CSV
  """
  def escribir_equipos(lista) do
    ensure_dir()
    headers = "ID,Nombre,Tema,Integrantes\n"

    contenido =
      Enum.map(lista, fn %Equipo{id: id, nombre: nombre, tema: tema, integrantes: integrantes} ->
        integrantes_str = Enum.join(integrantes, ";")
        "#{id},#{nombre},#{tema},#{integrantes_str}\n"
      end)
      |> Enum.join()

    File.write(path("equipos"), headers <> contenido)
  end

  @doc """
  Lee la lista de equipos del archivo CSV
  """
  def leer_equipos do
    case File.read(path("equipos")) do
      {:ok, contenido} ->
        String.split(contenido, "\n", trim: true)
        |> Enum.map(fn linea ->
          case String.split(linea, ",") do
            ["ID", "Nombre", "Tema", "Integrantes"] -> nil
            [id, nombre, tema, integrantes_str] ->
              integrantes =
                if integrantes_str == "", do: [], else: String.split(integrantes_str, ";")

              %Equipo{id: id, nombre: nombre, tema: tema, integrantes: integrantes}

            _ -> nil
          end
        end)
        |> Enum.filter(& &1)

      {:error, _} ->
        []
    end
  end


  # MENTORES

  @doc """
  Escribe la lista de mentores en un archivo CSV
  """
  def escribir_mentores(lista) do
    ensure_dir()
    headers = "ID,Nombre,Especialidad,correo,contraseña\n"

    contenido =
      Enum.map(lista, fn %Mentor{id: id, nombre: nombre, especialidad: especialidad, correo: correo, contrasenia: contrasenia} ->
        "#{id},#{nombre},#{especialidad}, #{correo}, #{contrasenia}\n"
      end)
      |> Enum.join()

    File.write(path("mentores"), headers <> contenido)
  end

  @doc """
  Lee la lista de mentores del archivo CSV
  """
  def leer_mentores do
    case File.read(path("mentores")) do
      {:ok, contenido} ->
        String.split(contenido, "\n", trim: true)
        |> Enum.map(fn linea ->
          case String.split(linea, ",") do
            ["ID", "Nombre", "Especialidad", "correo", "contrasenia"] -> nil
            [id, nombre, especialidad, correo, contrasenia] -> %Mentor{id: id, nombre: nombre, especialidad: especialidad, correo: correo, contrasenia: contrasenia}
            _ -> nil
          end
        end)
        |> Enum.filter(& &1)

      {:error, _} ->
        []
    end
  end

  # PROYECTOS

  @doc """
  escribe la lista de proyectos en un archivo CSV
  """
  def escribir_proyectos(lista) do
    ensure_dir()
    headers = "ID,ID_Equipo,Titulo,Descripcion,Categoria,Estado,Avances\n"

    contenido =
      Enum.map(lista, fn %Proyecto{
                            id: id,
                            id_equipo: id_equipo,
                            titulo: titulo,
                            descripcion: descripcion,
                            categoria: categoria,
                            estado: estado,
                            avances: avances
                          } ->
        "#{id},#{id_equipo},#{titulo},#{descripcion},#{categoria},#{estado},#{Enum.join(avances, ";")}\n"
      end)
      |> Enum.join()

    File.write(path("proyectos"), headers <> contenido)
  end

  @doc """
  lee la lista de proyectos del archivo CSV
  """
  def leer_proyectos do
    case File.read(path("proyectos")) do
      {:ok, contenido} ->
        String.split(contenido, "\n", trim: true)
        |> Enum.map(fn linea ->
          case String.split(linea, ",") do
            ["ID", "ID_Equipo", "Titulo", "Descripcion", "Categoria", "Estado", "Avances"] -> nil
            [id, id_equipo, titulo, descripcion, categoria, estado, avances_str] ->
              avances = if avances_str == "", do: [], else: String.split(avances_str, ";")
              %Proyecto{
                id: id,
                id_equipo: id_equipo,
                titulo: titulo,
                descripcion: descripcion,
                categoria: categoria,
                estado: String.to_atom(estado),
                avances: avances
              }

            _ -> nil
          end
        end)
        |> Enum.filter(& &1)

      {:error, _} ->
        []
    end
  end

  # CONSULTAS

  @doc """
  escribe la lista de consultas en un archivo CSV
  """
  def escribir_consultas(lista) do
    ensure_dir()
    headers = "ID,ID_Equipo,ID_Mentor,Mensaje,Respuesta\n"

    contenido =
      Enum.map(lista, fn %Consulta{id: id, id_equipo: id_equipo, id_mentor: id_mentor, mensaje: mensaje, respuesta: respuesta} ->
        "#{id},#{id_equipo},#{id_mentor},#{mensaje},#{respuesta}\n"
      end)
      |> Enum.join()

    File.write(path("consultas"), headers <> contenido)
  end

  @doc """
  lee la lista de consultas del archivo CSV
  """
  def leer_consultas do
    case File.read(path("consultas")) do
      {:ok, contenido} ->
        String.split(contenido, "\n", trim: true)
        |> Enum.map(fn linea ->
          case String.split(linea, ",") do
            ["ID", "ID_Equipo", "ID_Mentor", "Mensaje", "Respuesta"] -> nil
            [id, id_equipo, id_mentor, mensaje, respuesta] ->
              %Consulta{
                id: id,
                id_equipo: id_equipo,
                id_mentor: id_mentor,
                mensaje: mensaje,
                respuesta: if(respuesta == "", do: nil, else: respuesta)
              }

            _ -> nil
          end
        end)
        |> Enum.filter(& &1)

      {:error, _} ->
        []
    end
  end

end
