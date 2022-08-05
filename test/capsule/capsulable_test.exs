defmodule Capsule.CapsulableTest do
  use ExUnit.Case, async: true

  describe "fallback to Any" do
    test "put/3 raises Protocol.UndefinedError when we don't support this data type" do
      assert_raise Protocol.UndefinedError, fn ->
        Capsule.Capsulable.put(:atom, :dep_key, :dep_value)
      end
    end

    test "fetch/2 raises Protocol.UndefinedError when we don't support this data type" do
      assert_raise Protocol.UndefinedError, fn ->
        Capsule.Capsulable.fetch(:atom, :dep_key)
      end
    end
  end
end
