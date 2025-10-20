defmodule Telemed.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :title, :string
    field :message, :string
    field :read, :boolean, default: false
    field :type, :string
    field :notification_type, :string
    field :user_id, :id
    field :appointment_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:title, :message, :read, :type, :notification_type, :user_id, :appointment_id])
    |> validate_required([:message, :read])
  end
end
