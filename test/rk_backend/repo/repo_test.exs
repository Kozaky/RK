defmodule RkBackend.Repo.RepoTest do
  use RkBackend.DataCase

  alias RkBackend.Repo

  describe "repo" do
    @map_with_associations %{
      email: "some email",
      full_name: "some full_name",
      password: "password",
      password_confirmation: "password",
      role: %{
        type: "ADMIN"
      },
      reklama: %{
        title: "title",
        content: "content",
        images: [
          %{
            name: "image2",
            reklama: %{
              title: "title",
              user: %{
                name: "name",
                surname: "surname",
                role: [
                  %{
                    type: %{
                      type: "type"
                    },
                    order: %{
                      name: "command"
                    }
                  },
                  %{
                    type: %{
                      type: "type"
                    },
                    command: %{
                      command: "command"
                    }
                  }
                ]
              }
            }
          },
          %{
            name: "image1",
            reklama: %{
              title: "title"
            }
          }
        ],
        topic: %{
          title: "title",
          image: %{
            name: "topicImage"
          }
        }
      }
    }

    @simple_map %{
      id: 1,
      name: "name",
      images: [
        %{
          name: "image1"
        }
      ]
    }

    @map_without_associations %{
      id: 1,
      name: "name"
    }

    test "gen_preload_list/1 struct with complex associations" do
      list = Repo.gen_preload(@map_with_associations)

      assert [
               role: [],
               reklama: [
                 topic: [image: []],
                 images: [reklama: [user: [role: [order: [], command: [], type: []]]]]
               ]
             ] = list
    end

    test "gen_preload_list/1 struct with simple associations" do
      list = Repo.gen_preload(@simple_map)

      assert [
               images: []
             ] = list
    end

    test "gen_preload_list/1 struct without associations" do
      list = Repo.gen_preload(@map_without_associations)

      assert [] = list
    end
  end
end
