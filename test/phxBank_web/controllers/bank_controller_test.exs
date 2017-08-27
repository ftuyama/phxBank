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
    assert json["transaction"]["description"] == "ok"


    conn = simple_credit(conn, "20.0", "2017-08-10")
    
    assert json = json_response(conn, 200)
    assert json["user_id"] == 1
    assert json["balance"] == 10.0
    assert json["transaction"]["id"] == 2
    assert json["transaction"]["description"] == "not ok"
  end

  test "GET /statement", %{conn: conn} do
    insert(:user)

    conn = simple_debit(conn, "10.0", "2017-08-10")
    conn = simple_credit(conn, "20.0", "2017-08-10")
    conn = simple_debit(conn, "5.0", "2017-08-11")

    conn = get conn, "/api/statement", %{
      "user_id": "1",
      "start": "2015-08-08",
      "end": "2018-08-12"
    }
    
    assert json = json_response(conn, 200)
    assert json |> List.first |> Map.get("balance") == 10.0
    assert json |> List.first |> Map.get("date") == "2017-08-10"

    assert json |> List.last |> Map.get("balance") == 5.0
    assert json |> List.last |> Map.get("date") == "2017-08-11"
  end


  defp simple_debit(conn, amount, date) do
    post conn, "/api/operation", %{
      "user_id": "1",
      "transaction": %{
        "description": "ok",
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
        "description": "not ok",
        "type": "credit",
        "amount": amount,
        "date": date
      }
    }
  end
end
