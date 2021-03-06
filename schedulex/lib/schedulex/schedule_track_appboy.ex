defmodule Schedulex.ScheduleTrackAppboy do
  @moduledoc """
  Documentation for Schedulex.ScheduleTrackAppboy
  """

  @doc """
  Performs Track Post Appboy task for listener.

  ## Examples

      iex> Exq.enqueue(Exq, "scheduler", Schedulex.ScheduleTrackAppboy, ["123123-123-123", "tbl_name", [1,2,3,4]])
      {:ok, 7645}

  """
  def perform(args) do
    %{ "appboy_group_id" => appboy_group_id, "table" => tbl, "batch_count" => batch_count } = args
    # appboy_group_id, tbl, batch_count \\ 10
    Enum.each 1..batch_count, fn(_) -> process_attributes(appboy_group_id, tbl) end
    if Map.has_key?(args, "events") do
      Enum.each 1..batch_count, fn(_) -> process_events(appboy_group_id, Map.get(args, "web_app_id"), tbl) end
    end
  end

  defp process_attributes(appboy_group_id, tbl) do
    ids = Schedulex.Models.AppboyAttribute.batch_unprocessed_users(tbl)
    unless Enum.empty?(ids) do
      Exq.enqueue(
        Exq, "appboy", Schedulex.TrackPostAppboyAttributes, [appboy_group_id, tbl, ids]
      )
      Schedulex.Models.AppboyAttribute.set_status_for_users_in(tbl, ids, "QUEUED")
    end
  end

  defp process_events(appboy_group_id, web_app_id, tbl) do
    ids = Schedulex.Models.AppboyEvent.batch_unprocessed_users(tbl)
    unless Enum.empty?(ids) do
      Exq.enqueue(
        Exq, "appboy", Schedulex.TrackPostAppboyEvents, [appboy_group_id, web_app_id, tbl, ids]
      )
      Schedulex.Models.AppboyEvent.set_status_for_users_in(tbl, ids, "QUEUED")
    end
  end
end
