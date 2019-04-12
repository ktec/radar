defmodule BufferTest do
  use ExUnit.Case

  doctest Buffer

  describe "new/2" do
    test "creates a buffer" do
      b = Buffer.new()

      b2 = Buffer.push(b, 16)
      b3 = Buffer.push(b2, 42)

      assert Buffer.size(b3) == 2

      {v1, b4} = Buffer.pop(b3)
      {v2, b5} = Buffer.pop(b4)
      :empty = Buffer.pop(b5)

      assert v1 == 16
      assert v2 == 42
    end
  end

  describe "drop_until/1" do
    test "clears the buffer until condition is true" do
      b =
        Buffer.new()
        |> Buffer.push(1)
        |> Buffer.push(2)
        |> Buffer.push(3)
        |> Buffer.push(4)

      assert Buffer.size(b) == 4

      b = Buffer.drop_until(b, &(&1 == 3))

      assert Buffer.size(b) == 1
    end
  end

  describe "to_list/1" do
    test "returns the buffer as a list" do
      b =
        Buffer.new()
        |> Buffer.push(1)
        |> Buffer.push(2)
        |> Buffer.push(3)
        |> Buffer.push(4)

      assert Buffer.size(b) == 4

      assert Buffer.to_list(b) == [1, 2, 3, 4]
    end

    test "returns an empty buffer as an empty list" do
      b = Buffer.new()

      assert Buffer.size(b) == 0

      assert Buffer.to_list(b) == []
    end

    test "returns a single buffer as a single list" do
      b = Buffer.new() |> Buffer.push(1)

      assert Buffer.size(b) == 1

      assert Buffer.to_list(b) == [1]
    end
  end
end
