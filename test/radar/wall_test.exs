defmodule WallTest do
  use ExUnit.Case
  doctest Wall

  describe "detect_walls/2" do
    test "detect super simple wall" do
      orders = [
        ["4993.07000000", "0.09408000"],
        ["4993.06800000", "0.00000000"],
        ["4993.06700000", "0.15323300"],
        ["4992.57000000", "0.30800000"],
        ["4992.15000000", "0.00000000"],
        ["4992.10000000", "15.00000000"],
        ["4992.04000000", "0.01277500"],
        ["4990.10000000", "0.93967000"]
      ]

      walls = Wall.detect(orders, type: :bid, precision: 0, threshold: 0.5)

      # 1 buy wall detected at 1
      assert walls == [
               %Wall{price: 4992.0, total: 15.320775, precision: 0}
             ]
    end

    test "detect walls with precision 0" do
      orders = [
        # group 1
        ["4993.07000000", "0.09408000"],
        ["4993.06800000", "0.00000000"],
        ["4993.06700000", "12.15323300"],
        # group 2
        ["4992.57000000", "0.30800000"],
        ["4992.15000000", "0.00000000"],
        ["4992.10000000", "15.00000000"],
        ["4992.04000000", "0.01277500"],
        # group 3
        ["4990.10000000", "0.93967000"]
      ]

      walls = Wall.detect(orders, type: :bid, precision: 0, threshold: 0.5)

      # 2 buy walls detected at 1
      assert walls == [
               %Wall{precision: 0, price: 4992.0, total: 15.320775},
               %Wall{precision: 0, price: 4993.0, total: 12.247313}
             ]
    end

    test "detect two walls" do
      orders = [
        ["1.0", "0.1"],
        ["1.0", "5.0"],
        ["2.0", "0.1"],
        ["2.0", "5.0"]
      ]

      walls = Wall.detect(orders, type: :bid, precision: 0, threshold: 0.5)

      # 2 buy walls detected at 1.0, 2.0
      assert walls == [
               %Wall{price: 1.0, total: 5.1, precision: 0},
               %Wall{price: 2.0, total: 5.1, precision: 0}
             ]
    end

    test "detect walls" do
      orders = [
        ["4995.71000000", "0.16090700"],
        ["4995.72000000", "0.00000000"],
        ["4995.73000000", "0.00000000"],
        ["4995.76000000", "1.00000000"],
        ["4995.78000000", "0.00000000"],
        ["4995.80000000", "0.10000000"],
        ["4996.09000000", "0.00000000"],
        ["4996.10000000", "1.17033000"],
        ["5000.81000000", "0.00000000"],
        ["5001.94000000", "0.00000000"],
        ["5002.01000000", "0.05840000"]
      ]

      walls = Wall.detect(orders, type: :bid, precision: 2, threshold: 0.5)

      # 3 sell walls detected at 6500.00, 6550.00, 6600.00

      assert walls == [
               %Wall{precision: 2, price: 4995.76, total: 1.0},
               %Wall{precision: 2, price: 4996.1, total: 1.17033}
             ]
    end
  end
end
