Code.require_file("../domain/mentor.ex", __DIR__)
Code.require_file("../adapters/persistencia_csv.ex", __DIR__)
defmodule Services.GestionMentores do
  @moduledoc """
  Lógica para gestionar mentores registrados en la hackathon.
  Mantiene los datos en memoria.
  """

  alias Domain.Mentor

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

end
