defmodule TelemedWeb.MedicalRecordControllerTest do
  use TelemedWeb.ConnCase

  import Telemed.MedicalRecordsFixtures

  @create_attrs %{description: "some description", nom: "some nom", age: 42}
  @update_attrs %{description: "some updated description", nom: "some updated nom", age: 43}
  @invalid_attrs %{description: nil, nom: nil, age: nil}

  describe "index" do
    test "lists all medical_records", %{conn: conn} do
      conn = get(conn, ~p"/medical_records")
      assert html_response(conn, 200) =~ "Listing Medical records"
    end
  end

  describe "new medical_record" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/medical_records/new")
      assert html_response(conn, 200) =~ "New Medical record"
    end
  end

  describe "create medical_record" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/medical_records", medical_record: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/medical_records/#{id}"

      conn = get(conn, ~p"/medical_records/#{id}")
      assert html_response(conn, 200) =~ "Medical record #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/medical_records", medical_record: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Medical record"
    end
  end

  describe "edit medical_record" do
    setup [:create_medical_record]

    test "renders form for editing chosen medical_record", %{conn: conn, medical_record: medical_record} do
      conn = get(conn, ~p"/medical_records/#{medical_record}/edit")
      assert html_response(conn, 200) =~ "Edit Medical record"
    end
  end

  describe "update medical_record" do
    setup [:create_medical_record]

    test "redirects when data is valid", %{conn: conn, medical_record: medical_record} do
      conn = put(conn, ~p"/medical_records/#{medical_record}", medical_record: @update_attrs)
      assert redirected_to(conn) == ~p"/medical_records/#{medical_record}"

      conn = get(conn, ~p"/medical_records/#{medical_record}")
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, medical_record: medical_record} do
      conn = put(conn, ~p"/medical_records/#{medical_record}", medical_record: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Medical record"
    end
  end

  describe "delete medical_record" do
    setup [:create_medical_record]

    test "deletes chosen medical_record", %{conn: conn, medical_record: medical_record} do
      conn = delete(conn, ~p"/medical_records/#{medical_record}")
      assert redirected_to(conn) == ~p"/medical_records"

      assert_error_sent 404, fn ->
        get(conn, ~p"/medical_records/#{medical_record}")
      end
    end
  end

  defp create_medical_record(_) do
    medical_record = medical_record_fixture()
    %{medical_record: medical_record}
  end
end
