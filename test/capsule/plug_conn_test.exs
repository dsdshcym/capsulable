defmodule Capsule.PlugConnTest do
  use ExUnit.Case, async: true

  defp build_conn do
    Plug.Test.conn(:get, "/")
  end

  describe "Capsule.fetch(conn, key)" do
    test "returns {:ok, value} if the key-value pair HAS been put before" do
      assert build_conn()
             |> Capsule.put(:dep_key, :dep_value)
             |> Capsule.fetch(:dep_key) == {:ok, :dep_value}
    end

    test "returns :error if the key-value pair HAS NOT been put" do
      assert build_conn()
             |> Capsule.fetch(:dep_key) == :error
    end
  end
end
