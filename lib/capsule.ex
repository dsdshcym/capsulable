defmodule Capsule do
  defdelegate put(capsulable, key, value), to: Capsule.Capsulable
  defdelegate fetch(capsulable, key), to: Capsule.Capsulable
end
