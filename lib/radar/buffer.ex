defmodule Buffer do
  @moduledoc """
  Buffer queue for events
  """

  @doc """
  Create a new Buffer
  """
  def new() do
    {[], []}
  end

  @doc """
  Add a new item to the Buffer
  """
  def push({left, right}, value) do
    {left, [value | right]}
  end

  @doc """
  Look at the next item in the Buffer without removing it
  """
  def peak({head, {left, right}}) do
    {head, {[head | left], right}}
  end

  @doc """
  Get the next item from the Buffer
  """
  def pop({[], right}) do
    case Enum.reverse(right) do
      [] -> :empty
      [head | left] -> {head, {left, []}}
    end
  end

  def pop({[head | left], right}) do
    {head, {left, right}}
  end

  @doc """
  Get the size of the Buffer
  """
  def size({left, right}) do
    length(left) + length(right)
  end

  @doc """
  Drop items from the Buffer until the given predicate returns truthy
  """
  def drop_until(queue, predicate) do
    {v, queue} = pop(queue)

    if predicate.(v) do
      queue
    else
      drop_until(queue, predicate)
    end
  end

  @doc """
  Return all items in the Buffer within a List
  """
  def to_list({left, right}) do
    Enum.reverse(left ++ right)
  end
end
