defmodule Book do
  @moduledoc """
  An Order Book typically consists of three components:

  1) A list of Buy (bid) Orders - [(price, quantity) ... ]
  2) A list of Sell (ask) Orders - [(price, quantity) ... ]
  3) An Order History - [{datetime, buy_orders, sell_orders}]
  """
  require Logger

  import Event, only: [is_valid_event: 3]

  defstruct [:symbol, :bids, :asks, :time, :last_update_id]

  @doc """
  Returns a new Book with the given symbol
  """
  def new(symbol) do
    %Book{symbol: symbol}
  end

  @doc """
  Returns a new Book with the orders and last update id from the given snapshot
  """
  def apply_snapshot(%Book{} = book, snapshot) do
    %{"lastUpdateId" => last_update_id, "asks" => asks, "bids" => bids} = snapshot

    %Book{book | asks: asks, bids: bids, last_update_id: last_update_id}
  end

  @doc """
  Returns a tuple containing a new Book with the events from the supplied
  buffer applied and a new Buffer
  """
  def apply_buffer(%Book{} = book, buffer) do
    events = Buffer.to_list(buffer)

    book = Enum.reduce(events, book, &apply_event/2)

    {book, Buffer.new()}
  end

  @doc """
  Returns a new book with the given event replayed provided the event ids are
  valid for the current book state
  """
  def apply_event(
        %Event{first: first_id, last: last_id} = event,
        %Book{last_update_id: update_id} = book
      )
      when is_valid_event(first_id, last_id, update_id) do
    %Event{asks: new_asks, bids: new_bids, time: time} = event

    asks = Enum.reduce(new_asks, book.asks, &update_or_delete_price/2)
    bids = Enum.reduce(new_bids, book.bids, &update_or_delete_price/2)

    %{book | asks: asks, bids: bids, time: time, last_update_id: last_id}
  end

  def apply_event(_event, %Book{} = book) do
    book
  end

  defp update_or_delete_price([price, "0.00000000"], orders) do
    Enum.reject(orders, fn [p1, _] -> p1 == price end)
  end

  defp update_or_delete_price([price, quantity], orders) do
    Enum.map(orders, fn
      [p1, _] when p1 == price -> [price, quantity]
      other -> other
    end)
  end

  @doc """
  Returns the latest time the book was updated
  """
  def get_time(book) do
    case DateTime.from_unix(book.time, :millisecond) do
      {:ok, t} ->
        t |> DateTime.to_naive() |> to_string

      _other ->
        "Invalid Timestamp"
    end
  end
end
