defmodule RockPaperEx.Repo do
  use Ecto.Repo,
    otp_app: :rock_paper_ex,
    adapter: Ecto.Adapters.Postgres
end
