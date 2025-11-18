defmodule Main do
  # Importar servicios
  alias Services.{GestionParticipantes, GestionEquipos, GestionProyectos, GestionMentores, GestionConsultas}

  # ---------------------------
  # MENÚ PRINCIPAL
  # ---------------------------
  def iniciar do

    # ===== SERVIDOR DE CHAT DISTRIBUIDO =====
    # Se inicia una sola vez en segundo plano
    spawn(fn ->
      try do
        Adapters.ChatDistribuido.ServidorChat.iniciar()
      rescue
        _ -> :ok
      end
    end)

    IO.puts("""
    ===== SISTEMA DE GESTIÓN DE HACKATHON =====
    1. Registrarse como participante
    2. iniciar sesion como participante
    3. Registrarse como mentor
    4. Iniciar sesion como mentor
    5. modo comando (/)
    0. Salir
    """)

    opcion = IO.gets("Seleccione una opción: ") |> String.trim()

    case opcion do
      "1" -> registrar_participante()
      "2" -> login_participante()
      "3" -> registrar_mentor()
      "4" -> login_mentor()
      "5" -> modo_comandos()
      "0" -> IO.puts("Saliendo del sistema...")
      _ -> IO.puts("Opción no válida\n"); iniciar()
    end
  end

  @doc """
  funcion para registrar un participante
  """
  defp registrar_participante do
    id = IO.gets("ID del participante: ") |> String.trim()
    nombre = IO.gets("Nombre: ") |> String.trim()
    correo = IO.gets("Correo: ") |> String.trim()
    contrasenia = IO.gets("Contraseña: ") |> String.trim()

    case GestionParticipantes.registrar_participante(id, nombre, correo, contrasenia) do
      {:ok, p} ->
        IO.puts("Participante registrado correctamente: #{p.nombre}")
      {:error, msg} ->
        IO.puts("Error: #{msg}")
    end

    continuar(&menu_participante/0)
    limpiar_pantalla()
  end

  @doc """
  funcion que autentica el participante para iniciar sesion
  """
  defp login_participante do
    correo = IO.gets("Correo: ") |> String.trim()
    contrasena = IO.gets("Contraseña: ") |> String.trim()

    case GestionParticipantes.autenticar_participante(correo, contrasena) do
      {:ok, participante} ->
        limpiar_pantalla()
        IO.puts("Bienvenido, #{participante.nombre}!")
        menu_participante()

      {:error, msg} ->
        IO.puts("Error: #{msg}")
        iniciar()
    end
  end

  @doc """
  funcion que registra un mentor
  """
  defp registrar_mentor do
    id = IO.gets("ID del mentor: ") |> String.trim()
    nombre = IO.gets("Nombre: ") |> String.trim()
    especialidad = IO.gets("Especialidad del mentor: ") |> String.trim()
    correo = IO.gets("Correo: ") |> String.trim()
    contrasenia = IO.gets("Contraseña: ") |> String.trim()

    case GestionMentores.registrar_mentor(id, nombre, especialidad, correo, contrasenia) do
      {:ok, m} ->
        IO.puts("Mentor registrado correctamente: #{m.nombre}")
      {:error, msg} ->
        IO.puts("Error: #{msg}")
    end

    limpiar_pantalla()
    continuar(&menu_mentor/0)
  end

  @doc """
  funcion que autentica el mentor para iniciar sesion
  """
  defp login_mentor do
    correo = IO.gets("Correo: ") |> String.trim()
    contrasena = IO.gets("Contraseña: ") |> String.trim()

    case GestionMentores.autenticar_mentores(correo, contrasena) do
      {:ok, mentor} ->
        IO.puts("Bienvenido, #{mentor.nombre}!")
        limpiar_pantalla()
        menu_mentor()

      {:error, msg} ->
        IO.puts("Error: #{msg}")
        iniciar()
    end
  end
end
