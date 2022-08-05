defimpl Capsule.Capsulable, for: Plug.Conn do
  def put(conn, key, value) do
    Plug.Conn.put_private(conn, key, value)
  end

  def fetch(conn, key) do
    case conn.private[key] do
      nil -> :error
      value -> {:ok, value}
    end
  end
end
