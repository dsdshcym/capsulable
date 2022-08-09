defmodule TestCapsulable do
  defstruct capsule: %{}

  def new do
    %TestCapsulable{capsule: %{}}
  end
end

defimpl Capsule.Capsulable, for: TestCapsulable do
  def put(capsulable, key, value) do
    %TestCapsulable{capsule: Map.put(capsulable.capsule, key, value)}
  end

  def fetch(capsulable, key) do
    Map.fetch(capsulable.capsule, key)
  end
end
