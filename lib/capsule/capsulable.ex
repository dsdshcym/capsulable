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

  def put(any, _key, _value) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: any,
      description:
        "Capsule.put/3 by default only supports %Plug.Conn{} and %Ecto.Changeset{data: %Oban.Job{}}"
  end

  def fetch(%Plug.Conn{} = conn, key) do
    case conn.private[:__capsule__] do
      %{^key => value} -> {:ok, value}
      _ -> :error
    end
  end

  def fetch(any, _key) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: any,
      description: "Capsule.fetch/2 by default only supports %Plug.Conn{} and %Oban.Job{}"
  end
end
