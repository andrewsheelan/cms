defmodule Schedulex.TrackPostAppboyEvents do
  @moduledoc """
  Documentation for Schedulex.TrackPostAppboy
  """

  @doc """
  Performs Track Post Appboy task for listener.

  ## Examples

      iex> Exq.enqueue(Exq, "appboy", Schedulex.TrackPostAppboy, ["123123-123-123", "tbl_name", [1,2,3,4]])
      {:ok, 7645}

  """
  def perform(appboy_group_id, tbl, ids) do
    IO.inspect ids
    result = Schedulex.Models.AppboyEvent.users_in(tbl, ids)
    {_, response} = Schedulex.Appboy.send_bulk_events(appboy_group_id, result)
    if response.status_code == 201 do
      Schedulex.Models.AppboyEvent.set_status_for_users_in(tbl, ids, "COMPLETED")
    else
      Schedulex.Models.AppboyEvent.set_status_for_users_in(tbl, ids, response.body)
    end
  end
end
