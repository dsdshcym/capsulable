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

    test "allows setting multiple key-value pairs" do
      conn =
        build_conn()
        |> Capsule.put(:dep1, :value1)
        |> Capsule.put("dep2", "value2")

      assert Capsule.fetch(conn, :dep1) == {:ok, :value1}
      assert Capsule.fetch(conn, "dep2") == {:ok, "value2"}
    end

    test "returns :error if the key-value pair HAS NOT been put" do
      assert build_conn()
             |> Capsule.fetch(:dep_key) == :error
    end

    test "does not overwrite previous set private value" do
      conn =
        build_conn()
        |> Plug.Conn.put_private(:dep_key, :original_value)
        |> Capsule.put(:dep_key, :dep_value)

      assert conn.private[:dep_key] == :original_value
      assert Capsule.fetch(conn, :dep_key) == {:ok, :dep_value}
    end
  end
end
