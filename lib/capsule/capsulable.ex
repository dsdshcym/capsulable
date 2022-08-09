defprotocol Capsule.Capsulable do
  @fallback_to_any true

  @spec put(t(), any(), any()) :: t()
  def put(capsulable, key, value)

  @spec fetch(t(), any()) :: {:ok, any()} | :error
  def fetch(capsulable, key)
end

defimpl Capsule.Capsulable, for: Any do
  def put(%Ecto.Changeset{data: %Oban.Job{}} = oban_job_changeset, key, value) do
    old_meta = Ecto.Changeset.get_field(oban_job_changeset, :meta, %{})

    new_capsule =
      old_meta
      |> Map.get("__capsule__", %{})
      |> put_in_capsule(key, serialize(value))

    new_meta = Map.put(old_meta, "__capsule__", new_capsule)

    Ecto.Changeset.put_change(oban_job_changeset, :meta, new_meta)
  end

  def put(%Plug.Conn{} = conn, key, value) do
    new_capsule =
      conn.private
      |> Map.get(:__capsule__, %{})
      |> put_in_capsule(key, value)

    Plug.Conn.put_private(conn, :__capsule__, new_capsule)
  end

  def put(any, _key, _value) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: any,
      description:
        "Capsule.put/3 by default only supports %Plug.Conn{} and %Ecto.Changeset{data: %Oban.Job{}}"
  end

  def fetch(%Plug.Conn{} = conn, key) do
    conn.private
    |> Map.get(:__capsule__, %{})
    |> fetch_from_capsule(key)
  end

  def fetch(%Oban.Job{} = oban_job, key) do
    with {:ok, value} <-
           oban_job.meta
           |> Map.get("__capsule__", %{})
           |> fetch_from_capsule(key) do
      {:ok, deserialize(value)}
    end
  end

  def fetch(any, _key) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: any,
      description: "Capsule.fetch/2 by default only supports %Plug.Conn{} and %Oban.Job{}"
  end

  defp put_in_capsule(capsule, key, value) do
    Map.merge(capsule, %{key => value})
  end

  defp fetch_from_capsule(capsule, key) do
    case capsule do
      %{^key => value} -> {:ok, value}
      _ -> :error
    end
  end

  defp serialize(term) do
    term
    |> :erlang.term_to_binary()
    |> Base.encode64()
  end

  defp deserialize(binary) do
    binary
    |> Base.decode64!()
    |> :erlang.binary_to_term()
  end
end
