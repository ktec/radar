defmodule BookTest do
  @moduledoc """
  How to manage a local order book correctly

  1) Open a stream to wss://stream.binance.com:9443/ws/bnbbtc@depth
  2) Buffer the events you receive from the stream
  3) Get a depth snapshot from https://www.binance.com/api/v1/depth?symbol=BNBBTC&limit=1000
  4) Drop any event where u is <= lastUpdateId in the snapshot
  5) The first processed event should have U <= lastUpdateId+1 AND u >= lastUpdateId+1
  6) While listening to the stream, each new event's U should be equal to the previous event's u+1
  7) The data in each event is the absolute quantity for a price level
  8) If the quantity is 0, remove the price level
  9) Receiving an event that removes a price level that is not in your local order book can happen and is normal.
  """

  use ExUnit.Case
  doctest Book

  describe "apply_buffer/2" do
    test "updates the book with events from the buffer" do
      event1 = %Event{first: 1, last: 3, asks: [], bids: []}
      event2 = %Event{first: 4, last: 6, asks: [], bids: []}

      buffer =
        Buffer.new()
        |> Buffer.push(event1)
        |> Buffer.push(event2)

      last_update_id = 3
      book = Book.new("btcusdt")

      book = Book.apply_snapshot(book, snapshot(last_update_id))

      {updated_book, updated_buffer} = Book.apply_buffer(book, buffer)

      assert updated_book != book
      assert updated_buffer == Buffer.new()
    end
  end

  defp snapshot(last_update_id) do
    %{
      "lastUpdateId" => last_update_id,
      "bids" => [
        ["3.1", "0.16"],
        ["2.1", "0.12"],
        ["1.1", "0.00"]
      ],
      "asks" => [
        ["4.7", "0.23"],
        ["5.7", "0.25"],
        ["6.7", "0.00"]
      ]
    }
  end

  describe "apply_event/2" do
    test "updates order quantity in book" do
      book = %Book{
        bids: [["1", "0.1"]],
        asks: [["3", "0.1"]],
        last_update_id: 0
      }

      event = %Event{
        first: 1,
        last: 2,
        bids: [["1", "0.5"]],
        asks: [["3", "0.5"]]
      }

      updated_book = Book.apply_event(event, book)

      assert updated_book.bids == [["1", "0.5"]]
      assert updated_book.asks == [["3", "0.5"]]
      assert updated_book.last_update_id == 2
    end

    test "removes both ask and bid orders" do
      book = %Book{
        bids: [["1", "0.1"]],
        asks: [["3", "0.1"]],
        last_update_id: 0
      }

      event = %Event{
        first: 1,
        last: 2,
        asks: [["3", "0.00000000"]],
        bids: [["1", "0.00000000"]]
      }

      book = Book.apply_event(event, book)

      assert book == %Book{
               bids: [],
               asks: [],
               last_update_id: 2
             }
    end

    test "delete price that doesnt exist in book" do
      book = %Book{
        bids: [["1", "0.1"]],
        asks: [["3", "0.1"]],
        last_update_id: 0
      }

      event = %Event{
        first: 1,
        last: 2,
        asks: [["4", "0.00000000"]],
        bids: [["2", "0.00000000"]]
      }

      updated_book = Book.apply_event(event, book)

      assert updated_book.bids == book.bids
      assert updated_book.asks == book.asks
      assert updated_book.last_update_id == 2
    end
  end
end
