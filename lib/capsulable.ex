defprotocol Capsulable do
  @fallback_to_any true

  @spec put(t(), any(), any()) :: t()
  def put(capsulable, key, value)

  @doc """
  Capsulable.fetch(capsulable, key)

  - Returns {:ok, value} if key-value has been set:

    ```
    iex> TestCapsulable.new()
    iex> |> Capsulable.put(:a, 1)
    iex> |> Capsulable.fetch(:a)
    {:ok, 1}
    ```

  - Returns :error if key-value has NOT been set:

    ```
    iex> TestCapsulable.new()
    iex> |> Capsulable.fetch(:a)
    :error
    ```
  """
  @spec fetch(t(), any()) :: {:ok, any()} | :error
  def fetch(capsulable, key)

  @doc """
  Capsulable.get(capsulable, key, default)

  - Returns value if key-value has been set:

    ```
    iex> TestCapsulable.new()
    iex> |> Capsulable.put(:a, 1)
    iex> |> Capsulable.get(:a, :default_value)
    1
    ```

  - Returns value generated from default_fn if key-value has NOT been set:

    ```
    iex> TestCapsulable.new()
    iex> |> Capsulable.put(:a, 1)
    iex> |> Capsulable.get(:b, :default_value)
    :default_value
    ```
  """
  Kernel.def get(capsulable, key, default) do
    case fetch(capsulable, key) do
      {:ok, value} -> value
      :error -> default
    end
  end

  @doc """
  Capsulable.get_lazy(capsulable, key, default_fn)

  - Returns value if key-value has been set:

    ```
    iex> TestCapsulable.new()
    iex> |> Capsulable.put(:a, 1)
    iex> |> Capsulable.get_lazy(:a, fn -> raise("default_fn should not be called") end)
    1
    ```

  - Returns value generated from default_fn if key-value has NOT been set:

    ```
    iex> TestCapsulable.new()
    iex> |> Capsulable.get_lazy(:a, fn -> 2 end)
    2
    ```
  """
  Kernel.def get_lazy(capsulable, key, default_fn) do
    case fetch(capsulable, key) do
      {:ok, value} -> value
      :error -> default_fn.()
    end
  end
end

defimpl Capsulable, for: Any do
  if Code.ensure_loaded?(Oban.Job) && Code.ensure_loaded?(Ecto.Changeset) do
    def put(%Ecto.Changeset{data: %Oban.Job{}} = oban_job_changeset, key, value) do
      old_meta = Ecto.Changeset.get_field(oban_job_changeset, :meta, %{})

      new_capsulable =
        old_meta
        |> Map.get("__capsulable__", %{})
        |> put_in_capsulable(key, serialize(value))

      new_meta = Map.put(old_meta, "__capsulable__", new_capsulable)

      Ecto.Changeset.put_change(oban_job_changeset, :meta, new_meta)
    end
  end

  if Code.ensure_loaded?(Plug.Conn) do
    def put(%Plug.Conn{} = conn, key, value) do
      new_capsulable =
        conn.private
        |> Map.get(:__capsulable__, %{})
        |> put_in_capsulable(key, value)

      Plug.Conn.put_private(conn, :__capsulable__, new_capsulable)
    end
  end

  def put(any, _key, _value) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: any,
      description:
        "Capsulable.put/3 by default only supports %Plug.Conn{} and %Ecto.Changeset{data: %Oban.Job{}}"
  end

  if Code.ensure_loaded?(Plug.Conn) do
    def fetch(%Plug.Conn{} = conn, key) do
      conn.private
      |> Map.get(:__capsulable__, %{})
      |> fetch_from_capsulable(key)
    end
  end

  if Code.ensure_loaded?(Oban.Job) do
    def fetch(%Oban.Job{} = oban_job, key) do
      with {:ok, value} <-
             oban_job.meta
             |> Map.get("__capsulable__", %{})
             |> fetch_from_capsulable(key) do
        {:ok, deserialize(value)}
      end
    end
  end

  def fetch(any, _key) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: any,
      description: "Capsulable.fetch/2 by default only supports %Plug.Conn{} and %Oban.Job{}"
  end

  defp put_in_capsulable(capsulable, key, value) do
    Map.merge(capsulable, %{key => value})
  end

  defp fetch_from_capsulable(capsulable, key) do
    case capsulable do
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
