defmodule Schedulex.TrackPostAppboy do
  @moduledoc """
  Documentation for Schedulex.TrackPostAppboy
  """

  @doc """
  Performs Track Post Appboy task for listener.

  ## Examples

      iex> Exq.enqueue(Exq, "appboy", Schedulex.TrackPostAppboy, ["123123-123-123", "tbl_name", [1,2,3,4]])
      {:ok, 7645}

  """
  def perform(appboy_group_id, tbl, user_ids) do
    result = Schedulex.Models.AppboyAttribute.users_in(tbl, user_ids)
    response = Schedulex.Appboy.send_bulk_attributes(appboy_group_id, result)
    if response.status == 201 do
      Schedulex.Models.AppboyAttribute.set_status_for_users_in(tbl, user_ids, "COMPLETED")
    else
      Exq.enqueue(
        Exq, "appboy", Schedulex.TrackPostAppboy, [appboy_group_id, tbl, user_ids]
      )
    end
  end
end
