defprotocol Capsule.Capsulable do
  @fallback_to_any true

  @spec put(t(), any(), any()) :: t()
  def put(capsulable, key, value)

  @spec fetch(t(), any()) :: {:ok, any()} | :error
  def fetch(capsulable, key)
end

defimpl Capsule.Capsulable, for: Any do
  def put(%Plug.Conn{} = conn, key, value) do
    case conn.private[:__capsule__] do
      nil ->
        Plug.Conn.put_private(conn, :__capsule__, %{key => value})

      capsule ->
        Plug.Conn.put_private(conn, :__capsule__, Map.merge(capsule, %{key => value}))
    end
  end

  def fetch(%Plug.Conn{} = conn, key) do
    case conn.private[:__capsule__] do
      %{^key => value} -> {:ok, value}
      _ -> :error
    end
  end
end
