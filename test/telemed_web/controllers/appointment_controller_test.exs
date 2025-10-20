defmodule TelemedWeb.AppointmentControllerTest do
  use TelemedWeb.ConnCase

  import Telemed.AppointmentsFixtures

  @create_attrs %{status: "some status", scheduled_at: ~N[2025-06-28 02:39:00], notes: "some notes"}
  @update_attrs %{status: "some updated status", scheduled_at: ~N[2025-06-29 02:39:00], notes: "some updated notes"}
  @invalid_attrs %{status: nil, scheduled_at: nil, notes: nil}

  describe "index" do
    test "lists all appointments", %{conn: conn} do
      conn = get(conn, ~p"/appointments")
      assert html_response(conn, 200) =~ "Listing Appointments"
    end
  end

  describe "new appointment" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/appointments/new")
      assert html_response(conn, 200) =~ "New Appointment"
    end
  end

  describe "create appointment" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/appointments", appointment: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/appointments/#{id}"

      conn = get(conn, ~p"/appointments/#{id}")
      assert html_response(conn, 200) =~ "Appointment #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/appointments", appointment: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Appointment"
    end
  end

  describe "edit appointment" do
    setup [:create_appointment]

    test "renders form for editing chosen appointment", %{conn: conn, appointment: appointment} do
      conn = get(conn, ~p"/appointments/#{appointment}/edit")
      assert html_response(conn, 200) =~ "Edit Appointment"
    end
  end

  describe "update appointment" do
    setup [:create_appointment]

    test "redirects when data is valid", %{conn: conn, appointment: appointment} do
      conn = put(conn, ~p"/appointments/#{appointment}", appointment: @update_attrs)
      assert redirected_to(conn) == ~p"/appointments/#{appointment}"

      conn = get(conn, ~p"/appointments/#{appointment}")
      assert html_response(conn, 200) =~ "some updated status"
    end

    test "renders errors when data is invalid", %{conn: conn, appointment: appointment} do
      conn = put(conn, ~p"/appointments/#{appointment}", appointment: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Appointment"
    end
  end

  describe "delete appointment" do
    setup [:create_appointment]

    test "deletes chosen appointment", %{conn: conn, appointment: appointment} do
      conn = delete(conn, ~p"/appointments/#{appointment}")
      assert redirected_to(conn) == ~p"/appointments"

      assert_error_sent 404, fn ->
        get(conn, ~p"/appointments/#{appointment}")
      end
    end
  end

  defp create_appointment(_) do
    appointment = appointment_fixture()
    %{appointment: appointment}
  end
end
