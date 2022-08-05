defmodule Capsule.ObanJobTest do
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

  describe "Capsule.fetch(oban_job, key)" do
    test "returns {:ok, value} if key-value pair HAS BEEN put after Worker.new" do
      assert TestWorker.new(%{arg1: 1})
             |> Capsule.put("dep_key", "dep_value")
             |> fake_insert!()
             |> Capsule.fetch("dep_key") == {:ok, "dep_value"}
    end

    test "returns :error if key-value pair HAS NOT BEEN set after Worker.new" do
      assert TestWorker.new(%{arg1: 1})
             |> fake_insert!()
             |> Capsule.fetch("dep_key") == :error
    end
  end
end