defmodule Feed do
  use WebSockex
  require Logger

  @snapshot_delay 2_000
  @buffer_freq 100
  @report_freq 1_000

  def start_link(opts \\ []) do
    symbol = Keyword.fetch!(opts, :symbol)

    state = %{
      connected: false,
      buffer: Buffer.new(),
      book: Book.new(symbol)
    }

    url = "wss://stream.binance.com:9443/ws/#{String.downcase(symbol)}@depth"
    WebSockex.start_link(url, __MODULE__, state, opts)
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected!")

    Process.send_after(self(), :get_snapshot, @snapshot_delay)
    Process.send_after(self(), :report, @report_freq)

    {:ok, %{state | connected: true}}
  end

  def handle_frame({:text, frame}, %{buffer: buffer} = state) do
    # Logger.info("Recieved message: #{frame}")

    event = Event.from_frame(frame)
    buffer = Buffer.push(buffer, event)

    {:ok, %{state | buffer: buffer}}
  end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Local close with reason: #{inspect(reason)}")
    {:ok, %{state | connected: false}}
  end

  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end

  def handle_info(:get_snapshot, %{buffer: buffer, book: book} = state) do
    Logger.info("Getting Depth Snapshot")

    # Get Snapshot and Update OrderBook
    snapshot = get_snapshot(book.symbol)

    # 1. Create new filtered buffer
    buffer = filter_buffer(buffer, snapshot)

    # 2. Create new book from snapshot
    book = Book.apply_snapshot(book, snapshot)

    Process.send_after(self(), :process_buffer, @buffer_freq)

    {:ok, %{state | book: book, buffer: buffer}}
  end

  def handle_info(:process_buffer, %{buffer: buffer, book: book} = state) do
    {book, buffer} = Book.apply_buffer(book, buffer)

    Process.send_after(self(), :process_buffer, @buffer_freq)

    {:ok, %{state | book: book, buffer: buffer}}
  end

  def handle_info(:report, %{book: book} = state) do
    if book.time do
      sell_walls = Wall.detect(book.asks, type: :ask, precision: 0, threshold: 100)
      buy_walls = Wall.detect(book.bids, type: :bid, precision: 0, threshold: 100)

      time = Book.get_time(book)

      output = Printer.pretty(time, book.symbol, sell_walls, buy_walls)

      IO.puts(output)
    end

    Process.send_after(self(), :report, @report_freq)

    {:ok, state}
  end

  defp get_snapshot(symbol) do
    Http.request("https://www.binance.com/api/v1/depth?symbol=#{symbol}&limit=1000")
    |> Jason.decode!()
  end

  defp filter_buffer(buffer, %{"lastUpdateId" => last_update_id}) do
    Buffer.drop_until(buffer, fn %Event{last: last} -> last <= last_update_id end)
  end
end
