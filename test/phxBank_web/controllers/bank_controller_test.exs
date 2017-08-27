defmodule PhxBankWeb.BankControllerTest do
  use PhxBankWeb.ConnCase

  test "GET /balance", %{conn: conn} do
    insert(:user)
    conn = get conn, "/api/balance/1"

    assert json = json_response(conn, 200)
    assert json["balance"] == 0
    assert json["user_id"] == 1
    assert json["user_name"] == "Felipe Tuyama"
  end  

  test "POST /operation", %{conn: conn} do
    insert(:user)

    conn = simple_debit(conn, "10.0", "2017-08-10")
    
    assert json = json_response(conn, 200)
    assert json["user_id"] == 1
    assert json["balance"] == -10.0
    assert json["transaction"]["id"] == 1
    assert json["transaction"]["description"] == "not ok"


    conn = simple_credit(conn, "20.0", "2017-08-10")
    
    assert json = json_response(conn, 200)
    assert json["user_id"] == 1
    assert json["balance"] == 10.0
    assert json["transaction"]["id"] == 2
    assert json["transaction"]["description"] == "ok"
  end

  test "GET /statement", %{conn: conn} do
    insert(:user)

    conn = simple_debit(conn, "10.0", "2017-08-10")
    conn = simple_credit(conn, "20.0", "2017-08-10")
    conn = simple_debit(conn, "5.0", "2017-08-11")
    conn = simple_debit(conn, "15.0", "2017-08-12")

    conn = get conn, "/api/statement", %{
      "user_id": "1",
      "start": "2015-08-08",
      "end": "2018-08-12"
    }
    
    assert json = json_response(conn, 200)
    assert Enum.count(json) == 3

    assert json |> Enum.at(0) |> Map.get("balance") == 10.0
    assert json |> Enum.at(0) |> Map.get("date") == "2017-08-10"

    assert json |> Enum.at(1) |> Map.get("balance") == 5.0
    assert json |> Enum.at(1) |> Map.get("date") == "2017-08-11"

    assert json |> Enum.at(2) |> Map.get("balance") == -10.0
    assert json |> Enum.at(2) |> Map.get("date") == "2017-08-12"
  end

  test "GET /debits", %{conn: conn} do
    insert(:user)

    conn = simple_debit( conn, "10.0", "2017-08-10")  # -10.0
    conn = simple_credit(conn, "20.0", "2017-08-10")  # 10.0
    conn = simple_debit( conn, "15.0", "2017-08-11")  # -5.0
    conn = simple_debit( conn, "25.0", "2017-08-13")  # -30.0
    conn = simple_credit(conn, "100.0", "2017-08-17") # 70.0
    conn = simple_debit( conn, "200.0", "2017-08-30") # -130.0

    conn = get conn, "/api/debits/1"
    
    assert json = json_response(conn, 200)
    assert Enum.count(json) == 3

    assert json |> Enum.at(2) |> Map.get("amount") == -5.0
    assert json |> Enum.at(2) |> Map.get("start_date") == "2017-08-11"
    assert json |> Enum.at(2) |> Map.get("end_date") == "2017-08-12"

    assert json |> Enum.at(1) |> Map.get("amount") == -30.0
    assert json |> Enum.at(1) |> Map.get("start_date") == "2017-08-13"
    assert json |> Enum.at(1) |> Map.get("end_date") == "2017-08-16"

    assert json |> Enum.at(0) |> Map.get("amount") == -130.0
    assert json |> Enum.at(0) |> Map.get("start_date") == "2017-08-30"
    assert json |> Enum.at(0) |> Map.get("end_date") == nil
  end

  defp simple_debit(conn, amount, date) do
    post conn, "/api/operation", %{
      "user_id": "1",
      "transaction": %{
        "description": "not ok",
        "type": "debit",
        "amount": amount,
        "date": date
      }
    }
  end

  defp simple_credit(conn, amount, date) do
    post conn, "/api/operation", %{
      "user_id": "1",
      "transaction": %{
        "description": "ok",
        "type": "credit",
        "amount": amount,
        "date": date
      }
    }
  end
end
