defmodule Printer do
  @doc """
  Returns a string describing the given walls.
  """
  def pretty(time, symbol, sell_walls, buy_walls) do
    """
    [#{time}] #{symbol} #{pretty(sell_walls, :ask)}
    [#{time}] #{symbol} #{pretty(buy_walls, :bid)}\
    """
  end

  def pretty(walls, :bid), do: pretty(walls, "buy")
  def pretty(walls, :ask), do: pretty(walls, "sell")

  def pretty(walls, buy_or_sell) do
    count = length(walls)

    prices =
      walls
      |> Enum.map(fn %{price: price} -> :erlang.float_to_binary(price, [{:decimals, 1}]) end)
      |> Enum.join(", ")

    "#{count} #{buy_or_sell} #{pluralize("wall", count)} detected at #{prices}"
  end

  def pluralize(word, 1), do: word
  def pluralize(word, _), do: "#{word}s"
end
