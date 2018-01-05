# defmodule Schedulex.Models.User do
#   use Ecto.Schema
#
#   schema "users" do
#     field :email, :string
#     field :timezone, :string
#     has_one :profile, Schedulex.Models.Profile
#     timestamps(inserted_at: :created_at)
#   end
#
#   @doc """
#   Builds a changeset based on the `struct` and `params`.
#   """
#   def changeset(struct, params \\ %{}) do
#     struct
#     |> Ecto.Changeset.cast(params, [:email])
#     |> Ecto.Changeset.validate_required([:email])
#   end
#
#   @doc """
#   Find by condition -- For the love of Active Record
#
#   Examples
#
#       iex> Schedulex.Models.User.find_by(email: "email@example.com")
#       %Schedulex.Models.User{}
#   """
#   def find_by(conditions) do
#     Schedulex.Repo.get_by Schedulex.Models.User, conditions
#   end
#
# end
