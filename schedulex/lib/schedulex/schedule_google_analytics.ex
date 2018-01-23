require Logger
defmodule Schedulex.ScheduleGoogleAnalytics do
  @moduledoc """
  Documentation for Schedulex.ScheduleTrackAppboy
  """

  @doc """
  Performs Track Post Appboy task for listener.

  ## Examples

      iex> Exq.enqueue(Exq, "scheduler", Schedulex.ScheduleGoogleAnalytics, [82980236, "NuMi Production Web"])
      {:ok, 7645}

  """
  def perform(args) do
    %{ "view_id" => view_id, "view_name" => view_name } = args
    metrics = ["ga:sessions", "ga:1dayUsers", "ga:7dayUsers", "ga:30dayUsers"]
    created_date = Timex.today
    url = "https://analyticsreporting.googleapis.com/v4/reports:batchGet"
    url = "#{url}?access_token=#{access_token()}"
    Logger.info("Generating report for #{view_name} => #{view_id}")
    for metric <- metrics do
      data = response_for(url, view_id, metric)
      Schedulex.Models.GoogleReport.clear_records(
        view_id, metric, created_date
      )
      Schedulex.Models.GoogleReport.insert_records(
        view_name, view_id, metric, created_date, data
      )
      Logger.info("Completed report for #{view_name}")
    end
    Logger.info("Completing report for #{view_name} => #{view_id}")
  end


  defp access_token do
    url = "https://www.googleapis.com/oauth2/v3/token"
    parameters = %{
      client_id: System.get_env("GOOGLE_CLIENT_ID"),
      client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
      scope: "https://www.googleapis.com/auth/analytics.readonly",
      refresh_token: System.get_env("GOOGLE_REFRESH_TOKEN"),
      grant_type: "refresh_token"
    }
    IO.puts inspect(parameters)

    case HTTPoison.post(url, URI.encode_query(parameters), ["Content-Type": "application/x-www-form-urlencoded"]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {_, %{"access_token" => token}}= Poison.decode(body)
        token
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts "Error fetching access token -- #{IO.inspect reason}"
        ""
    end
  end

  defp response_for(url, view_id, report) do
    try do
      IO.puts Poison.encode!(request_body(view_id, report))
      {_, resp} = HTTPoison.post url, Poison.encode!(
        request_body(view_id, report)
      ), [recv_timeout: 50000]
      Poison.decode!(resp.body)
    rescue
      _ ->
        response_for(url, view_id, report)
    end
  end

  defp request_body(view_id, metric) do
    %{
      reportRequests: [%{
        viewId: Integer.to_string(view_id),
          dateRanges: [%{
          startDate: "7daysAgo",
          endDate: "yesterday"
        }],
        metrics: [%{
          expression: metric
        }],
        dimensions: [%{
          name: "ga:date"
        }]
      }]
    }
  end
end
