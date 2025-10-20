defmodule Telemed.AppointmentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Telemed.Appointments` context.
  """

  @doc """
  Generate a appointment.
  """
  def appointment_fixture(attrs \\ %{}) do
    {:ok, appointment} =
      attrs
      |> Enum.into(%{
        notes: "some notes",
        scheduled_at: ~N[2025-06-28 02:39:00],
        status: "some status"
      })
      |> Telemed.Appointments.create_appointment()

    appointment
  end
end
