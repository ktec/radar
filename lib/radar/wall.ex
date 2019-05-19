defmodule Wall do
  @moduledoc """

  """

  defstruct [:price, :total, :precision]

  alias __MODULE__

  @doc """
  Returns a list of walls identified in the given list of orders for
  the given precision.

  sell walls are returned sorted by price increasing
  buy walls are returned sorted by price decreasing
  """
  def detect(orders, opts) when is_list(orders) do
    order_type = Keyword.fetch!(opts, :type)
    precision = Keyword.get(opts, :precision, 0)
    threshold = Keyword.get(opts, :threshold, 1.0)
    sorter = sort_by(order_type)

    {results, _} =
      orders
      |> group_by(precision, order_type)
      |> sort_by_price(sorter)
      |> reduce_to_walls(precision, threshold)

    results
  end

  def detect(_, _), do: []

  defp group_by(orders, precision, order_type) do
    Enum.reduce(orders, %{}, fn [price, quantity], acc ->
      key = parse_price(price, precision, order_type)
      value = parse_quantity(quantity)

      if value > 0 do
        if Map.has_key?(acc, key) do
          Map.update(acc, key, value, &(&1 + value))
        else
          Map.put(acc, key, value)
        end
      else
        acc
      end
    end)
  end

  defp reduce_to_walls(orders, precision, threshold) do
    Enum.reduce(orders, {[], 1.0}, fn
      {price, total}, {result, acc} ->
        ratio = total / acc

        if ratio >= threshold do
          wall = %Wall{price: price, total: total, precision: precision}

          {[wall | result], total}
        else
          {result, total}
        end
    end)
  end

  defp sort_by_price(list, asc) do
    Enum.sort_by(list, &elem(&1, 0), asc)
  end

  defp parse_price(string, precision, :bid) when is_binary(string) do
    string |> String.to_float() |> Float.floor(precision)
  end

  defp parse_price(string, precision, :ask) when is_binary(string) do
    string |> String.to_float() |> Float.ceil(precision)
  end

  defp parse_quantity(string) when is_binary(string) do
    string |> String.to_float()
  end

  def sort_by(:bid), do: &>=/2
  def sort_by(:ask), do: &<=/2
end
