defmodule NoteTest do
  use ExUnit.Case
  alias XNote.Core.Note
  alias XNote.Core.Tag
  alias XNote.Core.Para
  
  test "new note" do
    assert %Note{
      id: _,
      tags: %MapSet{},
      paras: []
    } = Note.new()
  end
  
  test "add a tag" do
    tag = Tag.new("Nothing")
    tags = MapSet.new([tag])
    assert %Note{
      id: _,
      tags: ^tags,
      paras: []
    } = Note.new()
        |> Note.add_tag(tag)
  end
  
  test "remove a tag" do
    tag_a = Tag.new("A")
    tag_b = Tag.new("B")
    tags = MapSet.new([tag_b])
    assert %Note{
      id: _,
      tags: ^tags,
      paras: []
    } = Note.new()
        |> Note.add_tag(tag_a)
        |> Note.add_tag(tag_b)
        |> Note.remove_tag(tag_a)
  end
  
  test "insert a paragraph" do
    para = Para.new() |> Para.insert_text("All alone")
    assert %Note{
      id: _,
      tags: %MapSet{},
      paras: [para]
    } = Note.new()
      |> Note.insert_para(para, 0)
  end

  test "remove a paragraph" do
    para = Para.new() |> Para.insert_text("All alone")
    assert %Note{
      id: _,
      tags: %MapSet{},
      paras: []
    } = Note.new()
      |> Note.insert_para(para, 0)
      |> Note.remove_para(0)
  end
  
  test "swap paragraphs" do
    para_a = Para.new() |> Para.insert_text("A")
    para_b = Para.new() |> Para.insert_text("B")
    assert %Note{
      id: _,
      tags: %MapSet{},
      paras: [para_b, para_a]
    } = Note.new()
      |> Note.insert_para(para_a, 0)
      |> Note.insert_para(para_b, 1)
      |> Note.swap_paras(0, 1)
  end
  
end
