defmodule ParaTest do
  use ExUnit.Case
  alias XNote.Core.Para
  alias XNote.Core.Tag

  
  test "new Para default id" do
    assert  %Para{
              id: _,
              text: "",
              tag_refs: []
            } = Para.new()
  end
  
  
  test "new Para specific id" do
    assert  %Para{
              id: 123,
              text: "",
              tag_refs: []
            } = Para.new(123)
  end
  
  
  test "insert text into empty text" do
    assert  %Para{
              id: _,
              text: "One to all",
              tag_refs: []
    } = Para.new()
        |> Para.insert_text("One to all")
  end
  
  
  test "insert text into non empty text" do
    assert  %Para{
              id: _,
              text: "One ring to rule them all",
              tag_refs: []
    } = Para.new()
        |> Para.insert_text("One to all")
        |> Para.insert_text("ring ", 4)
        |> Para.insert_text("rule them ", 12)
  end
  
  
  test "insert text at start of non empty text" do
    assert %Para{
             id: _,
             text: "One does not simply walk into Mordor",
             tag_refs: []
    } = Para.new()
        |> Para.insert_text("walk into Mordor")
        |> Para.insert_text("One does not simply ")
  end
  
  
  test "insert text at end of non empty text" do
    assert %Para{
      id: _,
      text: "One does not simply walk into Mordor",
      tag_refs: []
    } = Para.new()
        |> Para.insert_text("One does not simply")
        |> Para.insert_text(" walk into Mordor", -1)
        
  end
  
  
  test "remove all text" do
    assert %Para{
      id: _,
      text: "",
      tag_refs: []
    } = Para.new()
    |> Para.insert_text("We hates it")
    |> Para.remove_text(0, 10)
  end
  
  test "remove all text negative last index" do
    assert %Para{
      id: _,
      text: "",
      tag_refs: []
    } = Para.new()
    |> Para.insert_text("We hates it")
    |> Para.remove_text(0, -1)
  end
  
  test "remove from start" do
    assert %Para{
      id: _,
      text: "hates it",
      tag_refs: []
    } = Para.new()
    |> Para.insert_text("We hates it")
    |> Para.remove_text(0, 2)
  end
  
  test "remove from end" do
    assert %Para{
      id: _,
      text: "We hates",
      tag_refs: []
    } = Para.new()
    |> Para.insert_text("We hates it")
    |> Para.remove_text(8, 10)
  end
  
  test "remove from end negative indexes" do
    assert %Para{
      id: _,
      text: "We hates",
      tag_refs: []
    } = Para.new()
    |> Para.insert_text("We hates it")
    |> Para.remove_text(-3, -1)
  end
  
  test "remove from middle" do
    assert %Para{
      id: _,
      text: "We it",
      tag_refs: []
    } = Para.new()
    |> Para.insert_text("We hates it")
    |> Para.remove_text(3, 8)
  end
  
  test "remove from middle negative last index" do
    assert %Para{
      id: _,
      text: "We it",
      tag_refs: []
    } = Para.new()
    |> Para.insert_text("We hates it")
    |> Para.remove_text(3, -3)
  end
  
  test "remove with nonsense indexes" do
    assert {:error, :indexes_out_of_range} =
    Para.new()
    |> Para.insert_text("We hates it")
    |> Para.remove_text(-3, 3)
  end
  
  test "insert tag reference" do
    assert %Para{
              id: _,
              tag_refs: [
                {
                  6,
                  10,
                  %Tag{
                    id: _,
                    name: "Green",
                    namespace: %Tag{
                      id: _,
                      name: "Colours",
                      namespace: %Tag{
                        id: 0,
                        name: "",
                        namespace: nil}
                      }
                  }
                }
              ],
              text: "a far green country under a swift sunrise"
            } = Para.new()
                |> Para.insert_text("a far green country under a swift sunrise")
                |> Para.add_tag_ref(Tag.new("Colours.Green"), 6, 10)
  end
  
  test "insert adjacent tag references" do
    assert %Para{
             id: _,
             tag_refs: [
               {0, 3, %Tag{id: _, name: "Moon", namespace: %Tag{id: 0, name: "", namespace: nil}}},
               {4, 8, %Tag{id: _, name: "Light", namespace: %Tag{id: 0, name: "", namespace: nil}}}
             ],
             text: "Moonlight"} =
    Para.new()
    |> Para.insert_text("Moonlight")
    |> Para.add_tag_ref(Tag.new("Moon"), 0, 3)
    |> Para.add_tag_ref(Tag.new("Light"), 4, 8)
  end
  
  test "insert overlapping tag references" do
    assert {:error, :overlapping_tag_refs} =
    Para.new()
    |> Para.insert_text("Moonlight")
    |> Para.add_tag_ref(Tag.new("On"), 2, 3)
    |> Para.add_tag_ref(Tag.new("Nli"), 3, 5)
  end
  
  test "Tag reference indexes unchanged by appending text" do
    assert %Para{
             id: _,
             tag_refs: [
               {
                 6,
                 10,
                 %Tag{
                   id: _,
                   name: "Green",
                   namespace: %Tag{id: 0, name: "", namespace: nil}
                 }
               }
             ], text: "a far green country under a swift sunrise"
           } =
    Para.new()
    |> Para.insert_text("a far green country")
    |> Para.add_tag_ref(Tag.new("Green"), 6, 10)
    |> Para.insert_text(" under a swift sunrise", -1)
  end
  
  test "Tag reference indexes changed by prepending text" do
    assert %Para{
             id: _,
             tag_refs: [
               {
                 28,
                 32,
                 %Tag{
                   id: _,
                   name: "Swift",
                   namespace: %Tag{id: 0, name: "", namespace: nil}
                 }
               }
             ], text: "a far green country under a swift sunrise"
           } =
    Para.new()
    |> Para.insert_text("under a swift sunrise")
    |> Para.add_tag_ref(Tag.new("Swift"), 8, 12)
    |> Para.insert_text("a far green country ", 0)
  end
  
  test "remove tag reference directly" do
    assert %Para{
              id: _,
              tag_refs: [],
              text: "a far green country under a swift sunrise"
            } = Para.new()
                |> Para.insert_text("a far green country under a swift sunrise")
                |> Para.add_tag_ref(Tag.new("Colours.Green"), 6, 10)
                |> Para.remove_tag_ref(0)
  end
  
  test "remove tag reference by removing text" do
    assert %Para{
              id: _,
              tag_refs: [],
              text: "a far country under a swift sunrise"
            } = Para.new()
                |> Para.insert_text("a far green country under a swift sunrise")
                |> Para.add_tag_ref(Tag.new("Colours.Green"), 6, 10)
                |> Para.remove_text(6, 11)
  end
  
  test "adjust tag reference by removing starting text" do
    assert %Para{
              id: _,
              tag_refs: [
                {
                  6,
                  7,
                  %Tag{
                    id: _,
                    name: "Green",
                    namespace: %Tag{
                      id: _,
                      name: "Colours",
                      namespace: %Tag{id: 0, name: "", namespace: nil}
                    }
                  }
                }
              ],
                    #0123456789
              text: "a far en country under a swift sunrise"
            } = Para.new()
                                    #01234567890
                |> Para.insert_text("a far green country under a swift sunrise")
                |> Para.add_tag_ref(Tag.new("Colours.Green"), 6, 10)
                |> Para.remove_text(6, 8)
  end
 
  test "adjust tag reference by removing ending text" do
    assert %Para{
              id: _,
              tag_refs: [
                {
                  6,
                  8,
                  %Tag{
                    id: _,
                    name: "Green",
                    namespace: %Tag{
                      id: _,
                      name: "Colours",
                      namespace: %Tag{id: 0, name: "", namespace: nil}
                    }
                  }
                }
              ],
                    #0123456789
              text: "a far gre country under a swift sunrise"
            } = Para.new()
                                    #01234567890
                |> Para.insert_text("a far green country under a swift sunrise")
                |> Para.add_tag_ref(Tag.new("Colours.Green"), 6, 10)
                |> Para.remove_text(9, 10)
  end
  
  test "adjust tag reference by removing enclosed text" do
    assert %Para{
              id: _,
              tag_refs: [
                {
                  6,
                  8,
                  %Tag{
                    id: _,
                    name: "Green",
                    namespace: %Tag{
                      id: _,
                      name: "Colours",
                      namespace: %Tag{id: 0, name: "", namespace: nil}
                    }
                  }
                }
              ],
                    #0123456789
              text: "a far grn country under a swift sunrise"
            } = Para.new()
                                    #01234567890
                |> Para.insert_text("a far green country under a swift sunrise")
                |> Para.add_tag_ref(Tag.new("Colours.Green"), 6, 10)
                |> Para.remove_text(8, 9)
  end
  
  
  
#  test "Para implements String.Chars" do
#    assert  "#{Para.root
#            |> Para.new("Characters")
#            |> Para.new("Frodo")}" ==
#              "Characters.Frodo"
#  end
  
end
