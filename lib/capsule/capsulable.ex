defprotocol Capsule.Capsulable do
  @fallback_to_any true

  @spec put(t(), any(), any()) :: t()
  def put(capsulable, key, value)

  @spec fetch(t(), any()) :: {:ok, any()} | :error
  def fetch(capsulable, key)
end

defimpl Capsule.Capsulable, for: Any do
  def put(%Ecto.Changeset{data: %Oban.Job{}} = oban_job_changeset, key, value) do
    new_args =
      oban_job_changeset
      |> Ecto.Changeset.get_field(:args, %{})
      |> Map.put(key, value)

    Ecto.Changeset.put_change(oban_job_changeset, :args, new_args)
  end

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

  def fetch(%Oban.Job{} = oban_job, key) do
    Map.fetch(oban_job.args, key)
  end

  def fetch(any, _key) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: any,
      description: "Capsule.fetch/2 by default only supports %Plug.Conn{} and %Oban.Job{}"
  end
end
