defmodule Rumbl.MultimediaTest do
  use Rumbl.DataCase, async: true

  alias Rumbl.Multimedia
  alias Rumbl.Multimedia.Category

  describe "categories" do
    test "list_alphabetical_categories/0" do
      for name <- ~w(Drama Action Comedy) do
        Multimedia.create_category!(name)
      end

      alpha_names =
        for %Category{name: name} <-
          Multimedia.list_alphabetical_categories() do
            name
          end
      assert alpha_names == ~w(Action Comedy Drama)
    end
  end

  describe "videos" do
    alias Rumbl.Multimedia.Video

    @valid_attrs %{description: "desc", title: "title", url: "http://local"}
    @invalid_attrs %{description: nil, title: nil, url: nil}

    test "list_videos/0 returns all videos" do
      owner = user()
      %Video{id: id1} = video(owner)
      assert [%Video{id: ^id1}] = Multimedia.list_videos()
      %Video{id: id2} = video(owner)
      assert [%Video{id: ^id1}, %Video{id: ^id2}] = Multimedia.list_videos()
    end

    test "get_video!/1 returns the video with the given id" do
      owner = user()
      %Video{id: id} = video(owner)
      assert %Video{id: ^id} = Multimedia.get_video!(id)
    end

    test "create_video/2 with valid data creates a video" do
      owner = user()
      assert {:ok, %Video{} = video} = Multimedia.create_video(owner, @valid_attrs)
      assert "desc" = video.description
      assert "title" = video.title
      assert "http://local" = video.url
    end

    test "create_video/2 with invalid data returns error changeset" do
      owner = user()
      assert {:error, %Ecto.Changeset{}} = Multimedia.create_video(owner, @invalid_attrs)
    end

    test "update_video/2 with valid data updates the video" do
      owner = user()
      video = video(owner)
      assert {:ok, video} = Multimedia.update_video(video, %{title: "updated title"})
      assert %Video{} = video
      assert "updated title" = video.title
    end

    test "update_video/2 with invalid data returns error changeset" do
      owner = user()
      %Video{id: id} = video = video(owner)

      assert {:error, %Ecto.Changeset{}} = Multimedia.update_video(video, @invalid_attrs)
      assert %Video{id: ^id} = Multimedia.get_video!(id)
    end

    test "delete_video/1 deletes the video" do
      owner = user()
      video = video(owner)
      assert {:ok, %Video{}} = Multimedia.delete_video(video)
      assert [] = Multimedia.list_videos()
    end

    test "change_video/1 returns a video changeset" do
      video = video(user())
      assert %Ecto.Changeset{} = Multimedia.change_video(video)
    end
  end
end
