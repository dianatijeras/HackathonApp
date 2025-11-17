defmodule NodoServidorMensajes do
  @nodo_servidor :"servidor@Dianatijeras"
  @nombre_proceso :servidor_mensajeria

  @doc """
  inicia el nodo servidor de mensajes y establece el estado inicial
  """
  def main() do
    IO.puts("SERVIDOR DE CHAT INICIADO")
    Node.start(@nodo_servidor)
    Node.set_cookie(:my_cookie)
    Process.register(self(), @nombre_proceso)

    estado = %{
      general: MapSet.new(),
      equipos: %{},
      salas: %{}
    }

    loop(estado)
  end

  @doc """
  bucle principal que maneja los mensajes recibidos y actualiza el estado
  """
  defp loop(estado) do
    receive do
      {:conectar, pid, :general} ->
        nuevo = Map.update!(estado, :general, &MapSet.put(&1, pid))
        loop(nuevo)

      {:conectar, pid, {:equipo, id_equipo}} ->
        nuevo = put_in_estado(estado, :equipos, id_equipo, pid)
        loop(nuevo)

      {:conectar, pid, {:sala, sala}} ->
        nuevo = put_in_estado(estado, :salas, sala, pid)
        loop(nuevo)

      {:mensaje, pid, destino, contenido} ->
        reenviar(estado, destino, pid, contenido)
        loop(estado)

      {:desconectar, pid} ->
        loop(eliminar_pid(estado, pid))
    end
  end

  @doc """
  actualiza el estado agregando un PID a un conjunto especifico dentro del estado
  """
  defp put_in_estado(estado, tipo, nombre, pid) do
    mapa = Map.get(estado, tipo)
    set = Map.get(mapa, nombre, MapSet.new()) |> MapSet.put(pid)
    Map.put(estado, tipo, Map.put(mapa, nombre, set))
  end

  @doc """
  elimina el PID de todos los conjuntos dentro del estado
  """
  defp eliminar_pid(estado, pid) do
    limpiar = fn set -> MapSet.delete(set, pid) end

    %{
      general: limpiar.(estado.general),
      equipos: Enum.into(estado.equipos, %{}, fn {k, v} -> {k, limpiar.(v)} end),
      salas: Enum.into(estado.salas, %{}, fn {k, v} -> {k, limpiar.(v)} end)
    }
  end

  @doc """
  envia un mensaje a todos los PID conectados en el destino especifico
  """
  defp reenviar(estado, :general, pid, texto) do
    Enum.each(estado.general, fn cliente ->
      send(cliente, {:nuevo_mensaje, :general, pid, texto})
    end)
  end

  @doc """
    envia un mensaje a todos los PID conectados en el destino especifico
  """
  defp reenviar(estado, {:equipo, id}, pid, texto) do
    Enum.each(estado.equipos[id] || [], fn cliente ->
      send(cliente, {:nuevo_mensaje, {:equipo, id}, pid, texto})
    end)
  end

  @doc """
  reenvia un mensaje a todos los PID conectados en el destino especificado
  """
  defp reenviar(estado, {:sala, sala}, pid, texto) do
    Enum.each(estado.salas[sala] || [], fn cliente ->
      send(cliente, {:nuevo_mensaje, {:sala, sala}, pid, texto})
    end)
  end
end

NodoServidorMensajes.main()
