defmodule Cookie do
  @longitud_llave 128

  @doc """
  Genera y muestra una llave segura codificada en Base64.
  """
  def main() do
    :crypto.strong_rand_bytes(@longitud_llave)
    |> Base.encode64()
    |> Util.mostrar_mensaje()
  end
end

Cookie.main()
