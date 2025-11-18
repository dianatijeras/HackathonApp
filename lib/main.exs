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

  #MENU DEL MENTOR
   defp menu_mentor do
    IO.puts("""
    ===== MENÚ MENTOR =====
    1. Listar mentores
    2. Ver consultas recibidas
    3. Responder consulta
    0. Cerrar sesión
    """)

    opcion = IO.gets("Seleccione una opción: ") |> String.trim()

    case opcion do
      "1" -> listar_mentores()
      "2" -> ver_consultas_recibidas()
      "3" -> responder_consulta()
      "0" -> iniciar()
      _ -> IO.puts("Opción no válida\n"); menu_mentor()
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

  defp abrir_chat_equipo do
    id_equipo = IO.gets("Ingrese el ID del equipo para abrir el chat: ") |> String.trim()
    nombre_usuario = IO.gets("Ingrese su nombre de usuario para el chat: ") |> String.trim()

    case Services.GestionEquipos.buscar_equipo_por_id(id_equipo) do
      nil ->
        IO.puts("No existe un equipo con ese ID.")
        continuar(&menu_participante/0)

      equipo ->
        IO.puts("Abriendo chat del equipo #{equipo.nombre}...")

        nodo_local = pedir_nombre_nodo_local()
        nodo_servidor = pedir_nombre_nodo_servidor()

        case arrancar_y_conectar(nodo_local, nodo_servidor) do
          {:ok, nodo_servidor_atom} ->

            listener_pid = spawn(fn -> recibir_mensajes_loop() end)

            send({:servidor_mensajeria, nodo_servidor_atom}, {:conectar, listener_pid, {:equipo, id_equipo}})

            IO.puts("""
            Conectado al chat del equipo #{equipo.nombre} en #{nodo_servidor_atom}.
            Escribe tus mensajes y presiona ENTER.
            Escribe /salir para abandonar el chat.
            """)

            enviar_bucle = fn enviar_bucle ->
              mensaje =
                IO.gets("[#{nombre_usuario}] > ")
                |> case do
                  nil -> ""
                  s -> String.trim(s)
                end

              cond do
                mensaje == "/salir" ->
                  send({:servidor_mensajeria, nodo_servidor_atom}, {:desconectar, listener_pid})
                  send(listener_pid, :salir)
                  IO.puts("Saliendo del chat del equipo #{equipo.nombre}...\n")

                mensaje == "" ->
                  enviar_bucle.(enviar_bucle)

                true ->
                  send({:servidor_mensajeria, nodo_servidor_atom}, {:mensaje, listener_pid, {:equipo, id_equipo}, mensaje})
                  enviar_bucle.(enviar_bucle)
              end
            end

            enviar_bucle.(enviar_bucle)
            continuar(&menu_participante/0)

          {:error, :no_conectado} ->
            IO.puts("No se pudo conectar con el servidor. Verifica la red y la dirección.")
            continuar(&menu_participante/0)
        end
    end
  end

  #implementacion: comunicacion en tiempo real

  defp pedir_nombre_nodo_local do
    IO.gets("Ingrese el nombre de su nodo (ej: cliente1@192.168.0.12): ") |> String.trim()
  end

  defp pedir_nombre_nodo_servidor do
    IO.gets("Ingrese el nombre del nodo servidor (ej: servidor@192.168.0.5): ") |> String.trim()
  end

  defp arrancar_y_conectar(nodo_local_str, nodo_servidor_str) do
    nodo_local = String.to_atom(nodo_local_str)
    nodo_servidor = String.to_atom(nodo_servidor_str)

    case Node.start(nodo_local) do
      {:ok, _} -> :ok
      {:error, {:already_started, _}} -> :ok
      _ -> :ok
    end

    Node.set_cookie(:my_cookie)

    case Node.connect(nodo_servidor) do
      true -> {:ok, nodo_servidor}
      false -> {:error, :no_conectado}
    end
  end

  # 12
  defp entrar_canal_general do
    nodo_local = pedir_nombre_nodo_local()
    nodo_servidor = pedir_nombre_nodo_servidor()

    case arrancar_y_conectar(nodo_local, nodo_servidor) do
      {:ok, nodo_servidor_atom} ->

        listener_pid = spawn(fn -> recibir_mensajes_loop() end)

        send({:servidor_mensajeria, nodo_servidor_atom}, {:conectar, listener_pid, :general})

        IO.puts("""
        Conectado al CANAL GENERAL en #{nodo_servidor_atom}.
        Escribe tus mensajes y presiona ENTER para enviarlos.
        Escribe /salir para abandonar el chat.
        """)

        enviar_bucle = fn enviar_bucle ->
          mensaje =
            IO.gets("[general] > ")
            |> case do
              nil -> ""
              s -> String.trim(s)
            end

          cond do
            mensaje == "/salir" ->
              send({:servidor_mensajeria, nodo_servidor_atom}, {:desconectar, listener_pid})
              send(listener_pid, :salir)
              IO.puts("Saliendo del canal general...\n")

            mensaje == "" ->
              enviar_bucle.(enviar_bucle)

            true ->

              send({:servidor_mensajeria, nodo_servidor_atom}, {:mensaje, listener_pid, :general, mensaje})
              enviar_bucle.(enviar_bucle)
          end
        end

        enviar_bucle.(enviar_bucle)
        continuar(&menu_participante/0)

      {:error, :no_conectado} ->
        IO.puts("No se pudo conectar con el servidor. Verifica la red y la dirección.")
        continuar(&menu_participante/0)
    end
  end

  defp recibir_mensajes_loop do
    receive do
      {:nuevo_mensaje, :general, _pid_remoto, contenido} ->
        IO.write("\r\n[GENERAL] #{contenido}\n[general] > ")
        recibir_mensajes_loop()

      {:nuevo_mensaje, {:sala, sala}, _pid_remoto, contenido} ->
        IO.write("\r\n[SALA #{sala}] #{contenido}\n[sala #{sala}] > ")
        recibir_mensajes_loop()

      :salir ->
        :ok

      _other ->
        recibir_mensajes_loop()
    end
  end


  # 13
  defp enviar_anuncio do
    nodo_local = pedir_nombre_nodo_local()
    nodo_servidor = pedir_nombre_nodo_servidor()

    case arrancar_y_conectar(nodo_local, nodo_servidor) do
      {:ok, nodo_servidor_atom} ->
        anuncio = IO.gets("Escribe el anuncio para enviar al canal general: ") |> String.trim()
        send({:servidor_mensajeria, nodo_servidor_atom},
              {:mensaje, self(), :general, "[ANUNCIO] #{anuncio}"})
        IO.puts("Anuncio enviado.")
        continuar(&menu_participante/0)

      {:error, :no_conectado} ->
        IO.puts("No se pudo conectar con el servidor. Verifica la red y la dirección.")
        continuar(&menu_participante/0)
    end
  end


  # 14
  defp crear_sala_tematica do
    nodo_local = pedir_nombre_nodo_local()
    nodo_servidor = pedir_nombre_nodo_servidor()

    case arrancar_y_conectar(nodo_local, nodo_servidor) do
      {:ok, nodo_servidor_atom} ->
        nombre_sala = IO.gets("Nombre de la sala temática (ej: AI, Docker, Frontend): ") |> String.trim()
        send({:servidor_mensajeria, nodo_servidor_atom}, {:crear_sala, self(), nombre_sala})
        IO.puts("Solicitud enviada para crear la sala: #{nombre_sala}")
        continuar(&menu_participante/0)

      {:error, :no_conectado} ->
        IO.puts("No se pudo conectar con el servidor. Verifica la red y la dirección.")
        continuar(&menu_participante/0)
    end
  end

  # 15
  defp unirse_sala_tematica do
    nodo_local = pedir_nombre_nodo_local()
    nodo_servidor = pedir_nombre_nodo_servidor()

    case arrancar_y_conectar(nodo_local, nodo_servidor) do
      {:ok, nodo_servidor_atom} ->
        nombre_sala = IO.gets("Nombre de la sala a unirse: ") |> String.trim()
        send({:servidor_mensajeria, nodo_servidor_atom}, {:conectar, self(), {:sala, nombre_sala}})
        IO.puts("Te has unido (solicitud enviada) a la sala #{nombre_sala}. Presiona ENTER para volver.")
        IO.gets("")
        continuar(&menu_participante/0)

      {:error, :no_conectado} ->
        IO.puts("No se pudo conectar con el servidor. Verifica la red y la dirección.")
        continuar(&menu_participante/0)
    end
  end

  # 16
  defp chatear_sala_tematica do
    nodo_local = pedir_nombre_nodo_local()
    nodo_servidor = pedir_nombre_nodo_servidor()

    case arrancar_y_conectar(nodo_local, nodo_servidor) do
      {:ok, nodo_servidor_atom} ->
        nombre_sala = IO.gets("Nombre de la sala para chatear: ") |> String.trim()

        listener = spawn(fn -> recibir_mensajes_loop() end)

        send({:servidor_mensajeria, nodo_servidor_atom}, {:conectar, listener, {:sala, nombre_sala}})

        IO.puts("Entrando al chat de la sala #{nombre_sala}. Escribe /salir para terminar.\n")

        enviar_mensajes_sala(nombre_sala, nodo_servidor_atom, listener)

        continuar(&menu_participante/0)

      {:error, :no_conectado} ->
        IO.puts("No se pudo conectar con el servidor. Verifica la red y la dirección.")
        continuar(&menu_participante/0)
    end
  end

  defp enviar_mensajes_sala(nombre_sala, nodo_servidor_atom, listener) do
    texto = IO.gets("[#{nombre_sala}] > ") |> String.trim()

    cond do
      texto == "/salir" ->
        send({:servidor_mensajeria, nodo_servidor_atom}, {:desconectar, listener})
        send(listener, :salir)
        IO.puts("Saliendo del chat de #{nombre_sala}...")

      texto == "" ->
        enviar_mensajes_sala(nombre_sala, nodo_servidor_atom, listener)

      true ->
        # enviamos el listener como PID emisor
        send({:servidor_mensajeria, nodo_servidor_atom}, {:mensaje, listener, {:sala, nombre_sala}, texto})
        enviar_mensajes_sala(nombre_sala, nodo_servidor_atom, listener)
    end
  end

  # Funciones mentor

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

  defp listar_mentores do
    mentores = GestionMentores.listar_mentores()

    if mentores == [] do
      IO.puts("No hay mentores registrados.")
    else
      Enum.each(mentores, fn m ->
        IO.puts("ID: #{m.id} | Nombre: #{m.nombre} | Especialidad: #{m.especialidad}")
      end)
    end
    continuar(&menu_mentor/0)
  end

  defp ver_consultas_recibidas do
    id_mentor = IO.gets("Ingrese su ID de mentor: ") |> String.trim()
    consultas = GestionConsultas.listar_por_mentor(id_mentor)

    if consultas == [] do
      IO.puts("No hay consultas asignadas a este mentor.")
    else
      Enum.each(consultas, fn c ->
        IO.puts("""
        [#{c.id}] De equipo #{c.id_equipo}:
        Mensaje: #{c.mensaje}
        Respuesta: #{c.respuesta || "Pendiente"}
        """)
      end)
    end
    continuar(&menu_mentor/0)
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
