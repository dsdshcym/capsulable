defmodule CapsulableTest do
  use ExUnit.Case, async: true
  doctest Capsulable

  describe "fallback to Any" do
    test "put/3 raises Protocol.UndefinedError when we don't support this data type" do
      assert_raise Protocol.UndefinedError, fn ->
        Capsulable.put(:atom, :dep_key, :dep_value)
      end
    end

    test "fetch/2 raises Protocol.UndefinedError when we don't support this data type" do
      assert_raise Protocol.UndefinedError, fn ->
        Capsulable.fetch(:atom, :dep_key)
      end
    end
  end
end
