defmodule NodoClienteMensajes do
  
  @nodo_servidor :"servidor@Dianatijeras"
  @nombre_proceso_servidor :servidor_mensajeria

  @doc """
  Inicia el cliente de chat, conectándose al servidor y permitiendo enviar y recibir mensajes.
  """
  def main(nombre_usuario, destino) do
    IO.puts("CLIENTE DE CHAT INICIADO: #{nombre_usuario}")

    # El nodo ya está iniciado por la terminal
    Node.set_cookie(:my_cookie)

    if Node.connect(@nodo_servidor) do
      send({@nombre_proceso_servidor, @nodo_servidor}, {:conectar, self(), destino})

      IO.puts("""
      Conectado a #{inspect(destino)}.
      Escribe mensajes y presiona ENTER.
      """)

      spawn(fn -> recibir_mensajes_loop() end)
      enviar_mensajes_loop(nombre_usuario, destino)
    else
      IO.puts("No se pudo conectar al servidor. Verifica el nombre del nodo.")
    end
  end

  # RECEIVER

  @doc """
  Bucle para recibir mensajes del servidor.
  """
  defp recibir_mensajes_loop do
    receive do
      {:nuevo_mensaje, _destino, _from_pid, contenido} ->
        IO.puts("\n #{contenido}")
        recibir_mensajes_loop()

      _other ->
        recibir_mensajes_loop()
    end
  end


  # SENDER

  @doc """
  Bucle para enviar mensajes al servidor.
  """
  defp enviar_mensajes_loop(nombre, destino) do
    mensaje = IO.gets("[#{nombre}] > ") |> String.trim()

    if mensaje == "/salir" do
      send({@nombre_proceso_servidor, @nodo_servidor}, {:desconectar, self()})
      IO.puts(" Sesión finalizada.")
    else
      send({@nombre_proceso_servidor, @nodo_servidor}, {:mensaje, self(), destino, mensaje})
      enviar_mensajes_loop(nombre, destino)
    end
  end
end
