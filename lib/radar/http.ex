defmodule Http do
  @moduledoc """
  Simple HTTP wrapper for httpc
  """

  @doc """
  Make an http/https GET request with the given url
  """
  def request(url) do
    # `httpc` is part of `inets`:
    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)

    case :httpc.request(:get, {String.to_charlist(url), []}, [], []) do
      {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} ->
        body

      other ->
        other
    end
  end
end
