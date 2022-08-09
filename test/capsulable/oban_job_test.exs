defmodule Capsulable.ObanJobTest do
  use ExUnit.Case, async: true

  defmodule TestWorker do
    use Oban.Worker

    def perform(_job) do
    end
  end

  defp fake_insert!(oban_job_changeset) do
    oban_job_changeset
    |> Ecto.Changeset.apply_action!(:insert)
    |> Map.update!(:args, &(&1 |> Jason.encode!() |> Jason.decode!()))
  end

  describe "Capsulable.fetch(oban_job, key)" do
    test "returns {:ok, value} if key-value pair HAS BEEN put after Worker.new" do
      assert TestWorker.new(%{arg1: 1})
             |> Capsulable.put("dep_key", "dep_value")
             |> fake_insert!()
             |> Capsulable.fetch("dep_key") == {:ok, "dep_value"}
    end

    test "allows setting multiple key-value pairs" do
      job =
        TestWorker.new(%{})
        |> Capsulable.put("dep1", "value1")
        |> Capsulable.put("dep2", "value2")
        |> fake_insert!()

      assert Capsulable.fetch(job, "dep1") == {:ok, "value1"}
      assert Capsulable.fetch(job, "dep2") == {:ok, "value2"}
    end

    test "does not overwrite user's arguments in job.args" do
      job =
        TestWorker.new(%{"arg1" => "original_value"})
        |> Capsulable.put("arg1", "dep_value")
        |> fake_insert!()

      assert job.args["arg1"] == "original_value"
      assert Capsulable.fetch(job, "arg1") == {:ok, "dep_value"}
    end

    test "stores and retrieves runtime values" do
      pid = self()

      assert TestWorker.new(%{})
             |> Capsulable.put("pid", pid)
             |> fake_insert!()
             |> Capsulable.fetch("pid") == {:ok, pid}
    end

    test "returns :error if key-value pair HAS NOT BEEN set after Worker.new" do
      assert TestWorker.new(%{arg1: 1})
             |> fake_insert!()
             |> Capsulable.fetch("dep_key") == :error
    end
  end
end
