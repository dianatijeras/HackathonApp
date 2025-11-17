Code.require_file("../domain/mentor.ex", __DIR__)
Code.require_file("../adapters/persistencia_csv.ex", __DIR__)
defmodule Services.GestionMentores do
  @moduledoc """
  Lógica para gestionar mentores registrados en la hackathon.
  Mantiene los datos en memoria.
  """

  alias Domain.Mentor
  alias Adapters.PersistenciaCSV

  @doc """
  Registra un nuevo mentor en el sistema.
  """
  def registrar_mentor(id, nombre, especialidad, correo, contrasenia) do
    mentores = PersistenciaCSV.leer_mentores()

    if Enum.any?(mentores, fn m -> m.correo == correo end) do
      {:error, "El correo ya está registrado"}
    else
      nuevo = %Mentor{id: id, nombre: nombre, especialidad: especialidad, correo: correo, contrasenia: contrasenia}
      PersistenciaCSV.escribir_mentores([nuevo | mentores])
      {:ok, nuevo}
    end
  end

  @doc """
  Devuelve todos los mentores registrados.
  """
  def listar_mentores do
    PersistenciaCSV.leer_mentores()
  end

  @doc """
  Autentica a los mentores registrados
  """
  def autenticar_mentores(correo, contrasenia) do
    mentores = PersistenciaCSV.leer_mentores()

    case Enum.find(mentores, fn m ->
      String.trim(m.correo) == String.trim(correo) and
      String.trim(m.contrasenia) == String.trim(contrasenia)
    end) do
      nil -> {:error, "Credenciales incorrectas"}
      mentor -> {:ok, mentor}
    end
  end

end
