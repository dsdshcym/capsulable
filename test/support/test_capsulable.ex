defmodule TestCapsulable do
  defstruct capsulable: %{}

  def new do
    %TestCapsulable{capsulable: %{}}
  end
end

defimpl Capsulable, for: TestCapsulable do
  def put(capsulable, key, value) do
    %TestCapsulable{capsulable: Map.put(capsulable.capsulable, key, value)}
  end

  def fetch(capsulable, key) do
    Map.fetch(capsulable.capsulable, key)
  end
end
