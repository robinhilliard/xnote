defmodule XNote.Core.Para do
  @moduledoc """
  Paragraph state snapshot
  """
  
  
  defstruct ~w[id text tag_refs]a
  @type t :: %__MODULE__{
               id: non_neg_integer(),
               text: String.t,
               tag_refs: [XPara.Core.Ref]}
  
  
  @spec new(non_neg_integer | nil) :: %__MODULE__{}
  def new(id \\ nil) do
    %__MODULE__{
      id: Id.new(id),
      text: "",
      tag_refs: []
    }
  end
  
  
  @spec insert_text(%__MODULE__{}, String.t, integer()) :: %__MODULE__{}
  def insert_text(para, insert_text), do: insert_text(para, insert_text, 0)
  def insert_text(para=%__MODULE__{text: ""}, insert_text, _index), do: %{para | text: insert_text}
  def insert_text(para=%__MODULE__{text: text}, insert_text, index) do
    len = String.length(insert_text)
    index_norm = if index < 0, do: index + String.length(para.text) + 1, else: index
    {pre, post} = String.split_at(text <> "_", index_norm)
    %{para |
      text: pre <> insert_text <> String.slice(post, 0..-2),
      tag_refs: Enum.map(
        para.tag_refs,
        fn {first, last, tag} ->
          {
            (if first >= index_norm, do: first + len, else: first),
            (if last >= index_norm, do: last + len, else: last),
            tag
          }
        end
      )
    }
  end
  
  
  @spec remove_text(%__MODULE__{}, integer(), integer()) :: %__MODULE__{}
  def remove_text(para, remove_first, remove_last) do
    len_text = String.length(para.text)
    remove_first_norm = if remove_first < 0, do: remove_first + len_text, else: remove_first
    remove_last_norm = if remove_last < 0, do: remove_last + len_text, else: remove_last
    len_removed = (remove_last_norm - remove_first_norm) + 1
    
    cond do
      remove_first_norm in 0..len_text - 1 and
      remove_last_norm in remove_first_norm..len_text - 1 ->
        %{para |
          text: cond do
            remove_first_norm == 0 and remove_last_norm == len_text - 1 ->
              ""
            remove_last_norm == len_text - 1 ->
              String.slice(para.text, 0..remove_first_norm - 1)
            remove_first_norm == 0 ->
              String.slice(para.text, remove_last_norm + 1..len_text - 1)
            true ->
              String.slice(para.text, 0..remove_first_norm - 1) <>
              String.slice(para.text, remove_last_norm + 1..len_text - 1)
          end,
        
          tag_refs: Enum.flat_map(
            para.tag_refs,
            fn {tag_first, tag_last, tag} ->
              cond do
                tag_first in remove_first_norm..remove_last_norm and tag_last in remove_first_norm..remove_last_norm ->
                  []
                tag_first < remove_first_norm and tag_last > remove_last_norm ->
                  [{tag_first, tag_last - len_removed, tag}]
                tag_first < remove_first_norm and tag_last in remove_first_norm..remove_last_norm ->
                  [{tag_first, remove_first_norm - 1, tag}]
                tag_first in remove_first_norm..remove_last_norm and tag_last > remove_last_norm ->
                  [{remove_first_norm, tag_last - len_removed, tag}]
                true ->
                  [{tag_first, tag_last, tag}]
              end
            end
          )
        }
        
      true ->
        {:error, :indexes_out_of_range}
    end
  end
  
  
  @spec add_tag_ref(%__MODULE__{}, XPara.Core.Tag,
          non_neg_integer(), non_neg_integer()) :: %__MODULE__{}
  def add_tag_ref(para, tag, first, last) when first < last do
    case check_no_overlaps(tag, first, last, para.tag_refs) do
      {:ok, tag_refs} ->
        %{para | tag_refs: tag_refs}
      error ->
        error
    end
  end
  
  
  @spec remove_tag_ref(%__MODULE__{}, non_neg_integer()) :: %__MODULE__{}
  def remove_tag_ref(para, index), do: %{para | tag_refs: List.delete_at(para.tag_refs, index)}
  

  defp check_no_overlaps(tag, first, last, tag_refs) do
    new_refs = [{first, last, tag} | tag_refs] |> Enum.sort
    if end_lt_next_start(new_refs) do
      {:ok, new_refs}
    else
      {:error, :overlapping_tag_refs}
    end
  end
  
  defp end_lt_next_start([{_, _, _}]), do: true
  defp end_lt_next_start([{_, last, _}, next={first, _, _} | rest]) when last < first do
    end_lt_next_start([next | rest])
  end
  defp end_lt_next_start(_), do: false
                                                                               
end
