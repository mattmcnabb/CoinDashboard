Import-Module (Join-Path $PSScriptRoot "Dashboard") -Force

$Board = New-UDDashboard @Splat_Board -Content {
    ### the title row
    New-UDRow -Columns {New-UDColumn -Content {New-Title}}
    
    ### the first row contains the price history charts for BTC, ETH, and LTC
    New-UDLayout -Columns 3 -Content {
        # Bitcoin column
        New-UDColumn -Content {
            New-UDRow -Columns {
                New-UDColumn -Size 6 -Content {New-CoinPriceCounter -Name Bitcoin -Symbol BTC}
                New-UDColumn -Size 6 -Content {New-CoinChangeCounter -Symbol BTC}
            }
            New-UDRow -Columns {New-UDColumn -Content {New-CoinLineChart -Symbol BTC -Color Orange -Currencies "USD", "ETH", "LTC"}}
        }

        # Ether column
        New-UDColumn -Content {
            New-UDRow -Columns {
                New-UDColumn -Size 6 -Content {New-CoinPriceCounter -Name Ether -Symbol ETH}
                New-UDColumn -Size 6 -Content {New-CoinChangeCounter -Symbol ETH}
            }
            New-UDRow -Columns {New-UDColumn -Content {New-CoinLineChart -Symbol ETH -Color Green -Currencies "USD", "BTC", "LTC"}}
        }

        # Litecoin column
        New-UDColumn -Content {
            New-UDRow -Columns {
                New-UDColumn -Size 6 -Content {New-CoinPriceCounter -Name Litecoin -Symbol LTC}
                New-UDColumn -Size 6 -Content {New-CoinChangeCounter -Symbol LTC}
            }
            New-UDRow -Columns {New-UDColumn -Content {New-CoinLineChart -Symbol LTC -Color Blue -Currencies "USD", "BTC", "ETH"}
            }
        }
    }

    ### let's make a paged grid with all available coins, and a table of the top coins
    New-UDLayout -Columns 2 -Content {
        New-TopCoinTable
        New-AllCoinGrid
    }
}

Start-UDDashboard -Dashboard $Board
