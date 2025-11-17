Code.require_file("../domain/participante.ex", __DIR__)
Code.require_file("../adapters/persistencia_csv.ex", __DIR__)
defmodule Services.GestionParticipantes do
  @moduledoc """
  Lógica de aplicación para manejar usuarios dentro de la hackathon.
  """

  alias Domain.Participante
  alias Adapters.PersistenciaCSV


  @doc """
  Registra un nuevo usuario (participante o mentor).
  """
  def registrar_participante(id, nombre, correo, contrasenia) do
    participantes = PersistenciaCSV.leer_participantes()

    if Enum.any?(participantes, fn p -> p.correo == correo end) do
      {:error, "El correo ya está registrado"}
    else
      nuevo = %Participante{id: id, nombre: nombre, correo: correo, contrasenia: contrasenia}
      PersistenciaCSV.escribir_participantes([nuevo | participantes])
      {:ok, nuevo}
    end
  end

  @doc """
  Devuelve la lista completa de usuarios registrados.
  """
  def listar_participantes do
    PersistenciaCSV.leer_participantes()
  end

  @doc """
  Busca un usuario por su ID.
  """
  def buscar_usuario(id) do
    listar_participantes()
    |> Enum.find(fn u -> u.id == id end)
  end

  @doc """
  Busca un usuario por su ID en la lista de usuarios registrados.
  """
  def buscar_usuario_por_id(id) do
    lista = Process.get(:usuarios, [])
    Enum.find(lista, fn u -> u.id == id end)
  end

  @doc """
  Autentica a un usuario por correo y contraseña.
  """
  def autenticar_participante(correo, contrasenia) do
    participantes = PersistenciaCSV.leer_participantes()

    case Enum.find(participantes, fn p ->
      String.trim(p.correo) == String.trim(correo) and
      String.trim(p.contrasenia) == String.trim(contrasenia)
    end) do
      nil -> {:error, "Credenciales incorrectas"}
      participante -> {:ok, participante}
    end
  end

end
