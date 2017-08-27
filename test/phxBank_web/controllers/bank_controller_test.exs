defmodule PhxBankWeb.BankControllerTest do
  use PhxBankWeb.ConnCase

  setup do
    insert(:user)
    {:ok, %{}}
  end

  describe "Simple case uses" do
    test "GET /balance", %{conn: conn} do
      conn = get conn, "/api/balance/1"

      assert json = json_response(conn, 200)
      assert json["balance"] == 0
      assert json["user_id"] == 1
      assert json["user_name"] == "Felipe Tuyama"
    end  

    test "POST /operation", %{conn: conn} do
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
  end

  describe "Invalid case uses" do
     test "GET /balance WHEN User doesn't exist", %{conn: conn} do
      conn = simple_debit(conn, "10.0", "2017-08-10")
      assert json_response(conn, 200)

      conn = simple_credit(conn, "20.0", "2017-08-09")
      assert text = text_response(conn, 500)
      assert text == "Transaction can't occur in the past"
    end

    test "POST /operation WHEN Transaction in the past", %{conn: conn} do
      conn = simple_debit(conn, "10.0", "2017-08-10")
      assert json_response(conn, 200)

      conn = simple_credit(conn, "20.0", "2017-08-09")
      assert text = text_response(conn, 500)
      assert text == "Transaction can't occur in the past"
    end

    test "POST /operation WHEN Transaction is invalid", %{conn: conn} do
      conn = simple_debit(conn, "infinito", "2017-08-10")
      assert text = text_response(conn, 500)
      assert text == "Invalid amount"

      conn = post conn, "/api/operation", %{
        "user_id": "1", "debug": "false",
        "transaction": %{
          "description": "not ok",
          "type": "me da dinheiro", # invalid type
          "amount": "0.0",
          "date": "2017-08-10"
        }
      }
      assert text = text_response(conn, 500)
      assert text =~ "could not perform insert because changeset is invalid"

      conn = post conn, "/api/operation", %{
        "user_id": "1", "debug": "false",
        "transaction": %{
          "description": nil, # invalid description
          "type": "me da dinheiro",
          "amount": "0.0",
          "date": "2017-08-10"
        }
      }
      assert text = text_response(conn, 500)
      assert text =~ "could not perform insert because changeset is invalid"
    end

    test "GET /statement WHEN Period is invalid", %{conn: conn} do
      conn = simple_debit(conn, "10.0", "2017-08-10")
      conn = get conn, "/api/statement", %{
        "user_id": "1",
        "start": "2015-08-08",
        "end": "2015-08-01"
      }
      
      assert json = json_response(conn, 200)
      assert Enum.count(json) == 0
    end

    test "GET /statement WHEN Date is invalid", %{conn: conn} do
      conn = simple_debit(conn, "10.0", "2017-08-10")
      conn = get conn, "/api/statement", %{
        "user_id": "1",
        "start": "2015-08-08",
        "end": "hoje"
      }
      
      assert text = text_response(conn, 500)
      assert text == "cannot cast \"hoje\" to date"
    end

    test "GET /debits WHEN There is no debit", %{conn: conn} do
      conn = simple_credit(conn, "20.0", "2017-08-10")
      conn = get conn, "/api/debits/1"
      
      assert json = json_response(conn, 200)
      assert Enum.count(json) == 0
    end
  end

  # Util testing functions

  defp simple_debit(conn, amount, date) do
    post conn, "/api/operation", %{
      "user_id": "1",
      "debug": "false",
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
      "debug": "false",
      "transaction": %{
        "description": "ok",
        "type": "credit",
        "amount": amount,
        "date": date
      }
    }
  end
end
