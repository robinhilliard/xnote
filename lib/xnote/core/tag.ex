defmodule XNote.Core.Tag do
  @moduledoc """
  Tag state snapshot
  """
  
  
  @root_id 0
  
  
  defstruct ~w[id namespace name]a
  @type t :: %__MODULE__{
               id: reference(),
               namespace: %__MODULE__{} | nil,
               name: String.t}
  
  
  @spec root() :: %__MODULE__{}
  def root() do
    %__MODULE__{
      id: @root_id,
      namespace: nil,
      name: ""
    }
  end
  
  
  @spec new(%__MODULE__{}, String.t, non_neg_integer()) :: %__MODULE__{}
  def new(name) when is_binary(name), do: new(root(), name, Id.new())
  def new(namespace, name) when is_binary(name), do: new(namespace, name, Id.new())
  def new(name, id) when is_binary(name) and is_integer(id), do: new(root(), name, id)
  def new(namespace, name, id) when is_binary(name), do: new(namespace, String.split(name, "."), id)
  def new(namespace, [], id), do: namespace
  def new(namespace, [name | rest], id) do
    new(
      %__MODULE__{
        id: id,
        namespace: namespace,
        name: name
      },
      rest,
      Id.new()
    )
  end
  
  
  @spec update_name(%__MODULE__{}, String.t) :: %__MODULE__{}
  def update_name(tag, name), do: %{tag | name: name}
  
  
  @spec qualified_name(%__MODULE__{}) :: [String.t]
  def qualified_name(%__MODULE__{id: @root_id}), do: []
  def qualified_name(%__MODULE__{namespace: ns, name: name}), do: qualified_name(ns) ++ [name]
  
  
  defimpl String.Chars, for: XNote.Core.Tag do
    def to_string(tag) do
      Enum.join(XNote.Core.Tag.qualified_name(tag), ".")
    end
  end

end
