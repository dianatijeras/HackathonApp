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


  # MENÚ DEL PARTICIPANTE

  defp menu_participante do
    IO.puts("""
    ===== MENÚ PARTICIPANTE =====
    1. Listar Participantes
    2. Crear equipo
    3. Listar equipos
    4. Agregar integrante a equipo
    5. Registrar proyecto
    6. Listar proyectos
    7. Agregar avance al proyecto
    8. Buscar proyectos por categoría
    9. Buscar proyectos por estado
    10. Enviar consulta a mentor
    11. Abrir chat del quipo
    12. Entrar al canal general
    13. Enviar anuncio
    14. Crear sala temática
    15. Unirse a una sala
    16. Chatear en una sala
    0. Cerrar sesión
    """)

    opcion = IO.gets("Seleccione una opción: ") |> String.trim()

    case opcion do
      "1" -> listar_participantes()
      "2" -> crear_equipo()
      "3" -> listar_equipos()
      "4" -> agregar_integrante()
      "5" -> registrar_proyecto()
      "6" -> listar_proyectos()
      "7" -> agregar_avance()
      "8" -> buscar_por_categoria()
      "9" -> buscar_por_estado()
      "10" -> enviar_consulta()
      "11" -> abrir_chat_equipo()
      "12" -> entrar_canal_general()
      "13" -> enviar_anuncio()
      "14" -> crear_sala_tematica()
      "15" -> unirse_sala_tematica()
      "16" -> chatear_sala_tematica()
      "0" -> iniciar()
      _ -> IO.puts("Opción no válida\n"); menu_participante()
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

  defp crear_equipo do
    id = IO.gets("ID del equipo: ") |> String.trim()
    nombre = IO.gets("Nombre del equipo: ") |> String.trim()
    tema = IO.gets("Tema o afinidad del equipo: ") |> String.trim()
    {:ok, equipo} = GestionEquipos.crear_equipo(id, nombre, tema)
    IO.puts("Equipo creado con ID: #{equipo.id}")
    continuar(&menu_participante/0)
  end

  defp listar_equipos do
    equipos = GestionEquipos.listar_equipos()

    if equipos == [] do
      IO.puts("No hay equipos registrados.")
    else
      Enum.each(equipos, fn e ->
        IO.puts("ID: #{e.id} | Nombre: #{e.nombre} | Integrantes: #{Enum.join(e.integrantes, ", ")}")
      end)
    end

    continuar(&menu_participante/0)
  end

  defp agregar_integrante do
    id_equipo = IO.gets("ID del equipo: ") |> String.trim()
    id_participante = IO.gets("ID del participante: ") |> String.trim()

    case GestionEquipos.agregar_integrante(id_equipo, id_participante) do
      {:ok, _} -> IO.puts("Integrante agregado correctamente.")
      {:error, msg} -> IO.puts("Error: #{msg}")
    end

    continuar(&menu_participante/0)
  end

  defp registrar_proyecto do
    id = IO.gets("ID del proyecto: ") |> String.trim()
    id_equipo = IO.gets("ID del equipo: ") |> String.trim()
    titulo = IO.gets("Título del proyecto: ") |> String.trim()
    descripcion = IO.gets("Descripción: ") |> String.trim()
    categoria = IO.gets("Categoría: ") |> String.trim()
    {:ok, proyecto} = GestionProyectos.registrar_proyecto(id, id_equipo, titulo, descripcion, categoria)
    IO.puts("Proyecto registrado con ID: #{proyecto.id}")
    continuar(&menu_participante/0)
  end

  defp listar_proyectos do
    proyectos = GestionProyectos.listar_proyectos()

    if proyectos == [] do
      IO.puts("No hay proyectos registrados.")
    else
      Enum.each(proyectos, fn p ->
        IO.puts("""
        ID: #{p.id}
        Equipo: #{p.id_equipo}
        Título: #{p.titulo}
        Categoría: #{p.categoria}
        Avances: #{Enum.join(p.avances, "; ")}
        """)
      end)
    end
    continuar(&menu_participante/0)
  end

  defp listar_participantes do
    participantes = GestionParticipantes.listar_participantes()

    if participantes == [] do
      IO.puts("No hay participantes registrados.")
    else
      Enum.each(participantes, fn p ->
        IO.puts("""
        ID: #{p.id}
        Nombre: #{p.nombre}
        Correo: #{p.correo}
        """)
      end)
    end
    continuar(&menu_participante/0)
  end

  defp agregar_avance do
    id_proyecto = IO.gets("ID del proyecto: ") |> String.trim()
    texto = IO.gets("Nuevo avance: ") |> String.trim()

    case GestionProyectos.agregar_avance(id_proyecto, texto) do
      {:ok, _} -> IO.puts("Avance agregado correctamente.")
      {:error, msg} -> IO.puts("Error: #{msg}")
    end
    continuar(&menu_participante/0)
  end

  defp buscar_por_categoria do
    categoria = IO.gets("Ingrese la categoría: ") |> String.trim()
    proyectos = GestionProyectos.buscar_por_categoria(categoria)
    mostrar_proyectos(proyectos)
    continuar(&menu_participante/0)
  end

  defp buscar_por_estado do
    estado = IO.gets("Ingrese el estado (en_desarrollo/finalizado): ") |> String.trim() |> String.to_atom()
    proyectos = GestionProyectos.buscar_por_estado(estado)
    mostrar_proyectos(proyectos)
    continuar(&menu_participante/0)
  end

  defp enviar_consulta do
    id_equipo = IO.gets("ID del equipo: ") |> String.trim()
    id_mentor = IO.gets("ID del mentor: ") |> String.trim()
    mensaje = IO.gets("Mensaje o consulta: ") |> String.trim()

    {:ok, consulta} = GestionConsultas.registrar_consulta(id_equipo, id_mentor, mensaje)
    IO.puts("Consulta registrada con ID #{consulta.id}")
    continuar(&menu_participante/0)
  end

  defp mostrar_proyectos(proyectos) do
    if proyectos == [] do
      IO.puts("No se encontraron proyectos.")
    else
      Enum.each(proyectos, fn p ->
        IO.puts("ID: #{p.id} | Título: #{p.titulo} | Estado: #{p.estado} | Categoría: #{p.categoria}")
      end)
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

  @doc """
  funcion para entrar al modo comandos del sistema
  """
  defp modo_comandos do
    IO.puts("""
    ==== MODO COMANDO ====
    Escribe /help para ver los comandos disponibles.
    """)

    loop_comandos()
  end

  @doc """
  funcion que inicia un ciclo interactivo que permite al usuario ingresar comandos
  de manera continua desde la terminal.
  """
  defp loop_comandos do
    input = IO.gets("> ") |> String.trim()
    ejecutar_comando(input)
    loop_comandos()
  end

  @doc """
  funcion que ejecuta los diferentes comandos
  """
  defp ejecutar_comando(comando) do
    cond do
      comando == "/help" ->
        IO.puts("""
        ==== COMANDOS DISPONIBLES ====
        /teams                → Listar equipos registrados
        /project nombre       → Mostrar proyecto de un equipo
        /join equipo          → Unirse a un equipo existente
        /chat equipo          → Entrar al canal de chat del equipo
        /exit                 → Salir del modo comando
        """)

      comando == "/teams" ->
        equipos = Services.GestionEquipos.listar_equipos()
        if equipos == [] do
          IO.puts("No hay equipos registrados.")
        else
          Enum.each(equipos, fn e ->
            IO.puts("• #{e.nombre} (ID: #{e.id}) — Integrantes: #{Enum.join(e.integrantes, ", ")}")
          end)
        end

      comando == "/exit" ->
        IO.puts("Saliendo del modo comando...\n")
        iniciar()

      String.starts_with?(comando, "/project") ->
        case String.split(comando, " ", parts: 2) do
          [_cmd, nombre_equipo] ->
            proyectos = Services.GestionProyectos.listar_proyectos()

            proyecto = Enum.find(proyectos, fn p ->
              equipo = Services.GestionEquipos.buscar_equipo_por_id(p.id_equipo)
              equipo && equipo.nombre == nombre_equipo
            end)

            if proyecto do
              IO.puts("""
              Proyecto del equipo #{nombre_equipo}:
              Título: #{proyecto.titulo}
              Descripción: #{proyecto.descripcion}
              Categoría: #{proyecto.categoria}
              Avances: #{Enum.join(proyecto.avances, "; ")}
              """)
            else
              IO.puts("No se encontró proyecto para el equipo '#{nombre_equipo}'.")
            end

          _ ->
            IO.puts("Uso correcto: /project nombre_equipo")
        end

      String.starts_with?(comando, "/join") ->
        case String.split(comando, " ", parts: 2) do
          [_cmd, nombre_equipo] ->
            id_participante = IO.gets("Tu ID de participante: ") |> String.trim()
            equipo = Services.GestionEquipos.buscar_por_nombre(nombre_equipo)

            if equipo do
              case Services.GestionEquipos.agregar_integrante(equipo.id, id_participante) do
                {:ok, _} -> IO.puts("Te has unido al equipo #{nombre_equipo}.")
                {:error, msg} -> IO.puts("Error: #{msg}")
              end
            else
              IO.puts("No se encontró el equipo '#{nombre_equipo}'.")
            end

          _ ->
            IO.puts("Uso correcto: /join nombre_equipo")
        end

      String.starts_with?(comando, "/chat") ->
        case String.split(comando, " ", parts: 2) do
          [_cmd, nombre_equipo] ->
            IO.puts("Entrando al chat del equipo #{nombre_equipo} (simulación)...")
            IO.puts("Escribe /salir para volver.\n")
            chat_loop(nombre_equipo)

          _ ->
            IO.puts("Uso correcto: /chat nombre_equipo")
        end

      true ->
        IO.puts("Comando no reconocido: #{comando}")
    end
  end
end
