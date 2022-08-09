defmodule Capsule do
  defdelegate put(capsulable, key, value), to: Capsule.Capsulable

  @doc """
  Capsule.fetch(capsulable, key)

  - Returns {:ok, value} if key-value has been set:

    iex> TestCapsulable.new()
    iex> |> Capsule.put(:a, 1)
    iex> |> Capsule.fetch(:a)
    {:ok, 1}

  - Returns :error if key-value has NOT been set:

    iex> TestCapsulable.new()
    iex> |> Capsule.fetch(:a)
    :error
  """
  defdelegate fetch(capsulable, key), to: Capsule.Capsulable

  @doc """
  Capsule.get_lazy(capsulable, key, default_fn)

  - Returns value if key-value has been set:

    iex> TestCapsulable.new()
    iex> |> Capsule.put(:a, 1)
    iex> |> Capsule.get_lazy(:a, fn -> raise("default_fn should not be called") end)
    1

  - Returns value generated from default_fn if key-value has NOT been set:

    iex> TestCapsulable.new()
    iex> |> Capsule.get_lazy(:a, fn -> 2 end)
    2
  """
  def get_lazy(capsulable, key, default_fn) do
    case Capsule.Capsulable.fetch(capsulable, key) do
      {:ok, value} -> value
      :error -> default_fn.()
    end
  end
end
