defmodule Schedulex.Models.AppboyAttribute do
  use Ecto.Schema
  alias Schedulex.Repo
  alias Schedulex.Models.AppboyAttribute
  import Ecto.Query, only: [from: 2]

  schema "appboy_attributes" do
    field :user_id, :integer
    field :attribute_name, :string
    field :data_value, :string
    field :status, :string
    field :date_sent, :utc_datetime
  end

  @doc """
  Find by condition -- For the love of Active Record
  Examples

      iex> Schedulex.Models.AppboyAttribute.find_by("appboy_user_events", email: "email@example.com")
      %Schedulex.Models.User{}
  """
  def find_by(tbl, conditions) do
    Repo.get_by {tbl, AppboyAttribute}, conditions
  end

  @doc """
  Select clause
  Examples

      iex> Schedulex.Models.AppboyAttribute.users_in(table_name, user_ids)
      %Schedulex.Models.User{}
  """
  def users_in(tbl, user_ids) do
    from(
      p in {tbl, AppboyAttribute},
      where: [user_id: user_ids]
    ) |> Repo.all
  end

  @doc """
  Update status
  Examples

      iex> Schedulex.Models.AppboyAttribute.users_in(table_name, user_ids)
      %Schedulex.Models.User{}
  """
  def set_status_for_users_in(tbl, user_ids, status) do
    from(
      p in {tbl, AppboyAttribute},
      where: [user_id: user_ids],
      update: [set: [status: ^status]]
    )
  end
end
