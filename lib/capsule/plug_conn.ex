defimpl Capsule.Capsulable, for: Plug.Conn do
  def put(conn, key, value) do
    case conn.private[:__capsule__] do
      nil ->
        Plug.Conn.put_private(conn, :__capsule__, %{key => value})

      capsule ->
        Plug.Conn.put_private(conn, :__capsule__, Map.merge(capsule, %{key => value}))
    end
  end

  def fetch(conn, key) do
    case conn.private[:__capsule__] do
      %{^key => value} -> {:ok, value}
      _ -> :error
    end
  end
end
