defmodule Telemed.Appointment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "appointments" do
    field :status, :string
    field :scheduled_at, :naive_datetime
    field :notes, :string

    belongs_to :doctor, Telemed.Accounts.User
    belongs_to :patient, Telemed.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(appointment, attrs) do
    appointment
    |> cast(attrs, [:scheduled_at, :status, :notes, :doctor_id, :patient_id])
    |> validate_required([:scheduled_at, :status])
  end
end
