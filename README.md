# Technical Assignment

## Task: write a piece of software to detect buy or sell walls in the marketplace

[Base repository](https://github.com/acuityinnovations/radar) has been set up to remove overhead work. Feel free to start a new repository if you prefer to work from a blank slate.

### Requirements

You must demonstrate the following:

- you are able to write clean and legible code
- you are able to write performant code
- you are able to organise, document your code and your commits
- you are able to write tests that backs application code

### Pre-requisites:

- basic understanding of [Order Book](https://www.investopedia.com/terms/o/order-book.asp) and its [Depth Chart](https://hackernoon.com/depth-chart-and-its-significance-in-trading-bdbfbbd23d33)
- basic understanding of WebSocket
- understanding of [buy/sell walls](https://www.yurikoval.com/blog/2018/10/understanding-buy-and-sell-walls/)

### Sample Unit Breakdown:

- Fetch WebSocket feed from marketplace - [`feed.ex`](lib/radar/feed.ex)
- Construct order book from orders feed
- Analyse order book and print price points at which walls exist

### Example output:

```sh
$ mix run --no-halt
[2018-01-01 16:01:04.796] BTC/USD 3 sell walls detected at 6500.00, 6550.00, 6600.00
[2018-01-01 16:01:06.243] BTC/USD 5 buy walls detected at 6400.00, 6350.00, 6300.00, 6200.00, 6100.00
[2018-01-01 16:01:10.543] BTC/USD 4 sell walls detected at 6450.00, 6500.00, 6550.00, 6600.00
[2018-01-01 16:01:25.758] BTC/USD 4 buy walls detected at 6350.00, 6300.00, 6200.00, 6100.00
```

### Binance Ticker Stream

Partial Book Depth Streams
Top <levels> bids and asks, pushed every second. Valid <levels> are 5, 10, or 20.

Stream Name: <symbol>@depth<levels>

Payload:

```
{
  "lastUpdateId": 160,  // Last update ID
  "bids": [             // Bids to be updated
    [
      "0.0024",         // Price level to be updated
      "10"              // Quantity
    ]
  ],
  "asks": [             // Asks to be updated
    [
      "0.0026",         // Price level to be updated
      "100"            // Quantity
    ]
  ]
}
```
