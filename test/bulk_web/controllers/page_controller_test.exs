defmodule BulkWeb.PageControllerTest do
  use BulkWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Bulk Discount II"
  end
end
