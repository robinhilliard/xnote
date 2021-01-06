defmodule XNote.Core.Note do
  @moduledoc """
  Note state snapshot
  """
  
  
  defstruct ~w[id tags paras]a
  @type t :: %__MODULE__{
               id: non_neg_integer(),
               tags: MapSet.t(XNote.Core.Tag),
               paras: [XNote.Core.Para]}
  
  
  @spec new(non_neg_integer | nil) :: %__MODULE__{}
  def new(id) do
    %__MODULE__{
      id: Id.new(id),
      tags: MapSet.new(),
      paras: []
    }
  end
  
  
  @spec add_tag(%__MODULE__{}, XNote.Core.Tag) :: %__MODULE__{}
  def add_tag(note, tag), do: %{note | tags: MapSet.put(note.tags, tag)}
  
  
  @spec remove_tag(%__MODULE__{}, XNote.Core.Tag) :: %__MODULE__{}
  def remove_tag(note, tag), do: %{note | tags: MapSet.delete(note.tags, tag)}
  
  
  @spec insert_para(%__MODULE__{}, XNote.Core.Para, non_neg_integer()) :: %__MODULE__{}
  def insert_para(note, para, index), do: %{note | paras: List.insert_at(note.paras, index, para)}
  
  
  @spec remove_para(%__MODULE__{}, non_neg_integer()) :: %__MODULE__{}
  def remove_para(note, index), do: %{note | paras: List.delete_at(note.paras, index)}
  
  
  @spec swap_paras(%__MODULE__{}, non_neg_integer(), non_neg_integer()) :: %__MODULE__{}
  def swap_paras(note,index_a, index_b) do
    {min_index, max_index} = if index_a < index_b, do: {index_a, index_b}, else: {index_b, index_a}
    {para, _paras} = List.pop_at(note.paras, max_index)
    insert_para(note, para, min_index)
  end

end
