defmodule Event do
  @moduledoc """
  An Event is a message update received from the stream
  """

  defstruct [:type, :time, :symbol, :first, :last, :asks, :bids]

  @doc """
  Create an Event from a websocket frame
  """
  def from_frame(frame) when is_binary(frame) do
    frame |> Jason.decode!() |> from_frame()
  end

  def from_frame(frame) when is_map(frame) do
    %{
      "e" => type,
      "E" => time,
      "s" => symbol,
      "U" => first,
      "u" => last,
      "a" => asks,
      "b" => bids
    } = frame

    %Event{
      type: type,
      time: time,
      symbol: symbol,
      asks: asks,
      bids: bids,
      first: first,
      last: last
    }
  end

  @doc """
  Ensure given update_id is bounded by given first and last ids
  """
  defguard is_valid_event(first_id, last_id, update_id)
           when first_id <= update_id + 1 and last_id >= update_id + 1
end
