defmodule Id do
  @moduledoc "Id generation for X-Note data"
  
  @spec new(non_neg_integer() | nil) :: non_neg_integer()
  def new(), do: new(nil)
  def new(existing_id) do
    if existing_id do
      existing_id
    else
      :crypto.rand_seed()
      <<id::integer-size(128)>> = :crypto.strong_rand_bytes(16)
      id
    end
  end

end
