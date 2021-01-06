defmodule TagTest do
  use ExUnit.Case
  alias XNote.Core.Tag

  
  test "new tag default id" do
    assert  %Tag{
              id: _,
              name: "Test",
              namespace: %Tag{
                id: 0,
                name: "",
                namespace: nil
              }
            } = Tag.new("Test")
  end
  
  
  test "new tag specific id" do
    assert  %Tag{
              id: 123,
              name: "Test",
              namespace: %Tag{
                id: 0,
                name: "",
                namespace: nil
              }
            } = Tag.new("Test", 123)
  end
  
  test "new qualified tag" do
    assert %Tag{
             id: _,
             name: "Green",
             namespace: %Tag{
               id: _,
               name: "Colours",
               namespace: %Tag{
                 id: 0,
                 name: "",
                 namespace: nil
               }
             }
           } = Tag.new("Colours.Green")
  end
  
  test "update tag name" do
    assert  %Tag{
              id: _,
              name: "Gollum",
              namespace: %Tag{
                id: 0,
                name: "",
                namespace: nil
              }
    } = Tag.new("Smeagol")
        |> Tag.update_name("Gollum")
    
  end
  
  
  test "tag implements String.Chars" do
    assert  "#{Tag.new("Characters") |> Tag.new("Frodo")}" ==
              "Characters.Frodo"
  end
  
end
