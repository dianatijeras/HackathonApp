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
end
