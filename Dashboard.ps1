#region Style
# theme colors
$Color_Theme1 = "#DBD7CD"
$Color_Theme2 = "#B8B5AD"
$Color_Theme3 = "#8F939F"
$Color_Theme4 = "#585B6A"
$Color_Theme5 = "#2A2C35"

# coin-specific colors
$Color_Bitcoin1 = "#4D4D4D"
$Color_Bitcoin2 = "#F7931B"
$Color_Ether1 = "#1D3C57"
$Color_Ether2 = "#5496E3"
$Color_Litecoin1 = "#DBEFFC"
$Color_Litecoin2 = "#88CBF5"

# Images
$Img_Litecoin = New-UDImage -Path "$PSScriptRoot\images\Litecoin.png" -Height 50 -Width 237.5 -Id CoinLogo
$Img_Bitcoin = New-UDImage -Path "$PSScriptRoot\images\Bitcoin.png" -Height 50 -Width 237.5 -Id CoinLogo
$Img_Ether = New-UDImage -Path "$PSScriptRoot\images\Ethereum.png" -Height 50 -Width 237.5 -Id CoinLogo
$Img_Treasure = New-UDImage -Path "$PSScriptRoot\images\treasure.png" -Height 50 -Width 50

# Chart options
$Splat_LineChart = @{
    Type = "Line"
    #AutoRefresh     = $true
    #RefreshInterval = 300
}

# Header and Footer
$Link_UDHome = New-UDLink -Text "Powered by Universal Dashboard" -Url "https://www.poshud.com" -OpenInNewWindow -icon bar_chart_o
$Link_CoinHome = New-UDLink -OpenInNewWindow -Text "Project Home" -Url "https://github.com/mattmcnabb/coindashboard" -Icon github
$Link_BlogHome = New-UDLink -OpenInNewWindow -Text "My Blog" -Url "https://mattmcnabb.github.io" -Icon list
$Splat_Footer = @{
    BackgroundColor = $Color_Theme4
    FontColor       = $Color_Theme1
    Links           = $Link_UDHome
    Copyright       = "$([char]169) 2017 Matt McNabb All rights reserved"
}
$Footer = New-UDFooter @Splat_Footer

#endregion

#region Dashboard
$Splat_Board = @{
    Footer                       = $Footer
    BackgroundColor              = $Color_Theme3
    NavBarColor                  = $Color_Theme5
    NavBarFontColor              = $Color_Theme1
    Title                        = "Coins"
    NavBarLogo                   = $Img_Treasure
    NavBarLinks                  = $Link_CoinHome, $Link_BlogHome
    EndpointInitializationScript = {
        try
        {
            # try import by PSModulePath first
            Import-Module -Name Coin -ErrorAction Stop
        }
        Catch
        {
            try
            {
                # import by explicit path if not found in PSModulePath
                Import-Module -Name "D:/home/site/wwwroot/Coin" -ErrorAction Stop
            }
            Catch
            {
                throw "Could not find Coin module!"
            }
        }
    }
}

$Dashboard = New-UDDashboard @Splat_Board -Content {

    # the first row contains the price history charts for BTC, ETH, and LTC, with an image header of each coin's logo
    New-UDRow -Columns {
        # Bitcoin column
        New-UDColumn -Size 4 -Content {
            New-UDRow -Columns {
                New-UDColumn -Content {$Img_Bitcoin}
            }
            
            New-UDRow -Columns {
                New-UDColumn -AutoRefresh -RefreshInterval 30 -Content {
                    New-UDChart @Splat_LineChart -Endpoint {
                        param ($TimeRange, $ToCurrency)

                        $Date = Get-Date
                        switch ($TimeRange)
                        {
                            "1H" {$DataInterval = "Minute"; $Since = $Date.AddHours(-1); $Aggregate = 5}
                            "1D" {$DataInterval = "Hour"; $Since = $Date.AddHours(-24); $Aggregate = 1}
                            "1W" {$DataInterval = "Hour"; $Since = $Date.AddDays(-7); $Aggregate = 6}
                            "1M" {$DataInterval = "Day"; $Since = $Date.AddDays(-30); $Aggregate = 1}
                            "1Y" {$DataInterval = "Day"; $Since = $Date.AddDays(-365); $Aggregate = 15}
                            "5Y" {$DataInterval = "Day"; $Since = $Date.AddYears(-5); $Aggregate = 30}
                        }
                        $Splat = @{DataInterval = $DataInterval; Since = $Since; Aggregate = $Aggregate}

                        $History = Get-CoinPriceHistory -FromSymbol BTC -ToSymbol $ToCurrency @Splat -Until $Date
                        $History | Select-Object @{N = "Date"; E = {$_.Time.ToShortDateString()}}, @{N = $ToCurrency; E = {$_.high}} |
                            Out-UDChartData -LabelProperty Date -Dataset @(
                            New-UDLineChartDataset -DataProperty $ToCurrency -Label $ToCurrency -BorderWidth 1 -LineTension 0 -BackgroundColor $Color_Bitcoin1 -BorderColor $Color_Bitcoin2
                        )
                    } -FilterFields {
                        New-UDInputField -Type select -Name TimeRange -Values @("1H", "1D", "1W", "1M", "1Y", "5Y") -DefaultValue "1D"
                        New-UDInputField -Type select -Name ToCurrency -Values @("USD", "ETH", "LTC") -DefaultValue "USD"
                    }
                }
            }
        }

        # Ether column
        New-UDColumn -Size 4 -Content {
            New-UDRow -Columns {
                New-UDColumn -Content {$Img_Ether}
            }
            
            New-UDRow -Columns {
                New-UDColumn -Content {
                    New-UDChart @Splat_LineChart -Endpoint {
                        param ($TimeRange, $ToCurrency)

                        $Date = Get-Date
                        switch ($TimeRange)
                        {
                            "1H" {$DataInterval = "Minute"; $Since = $Date.AddHours(-1); $Aggregate = 5}
                            "1D" {$DataInterval = "Hour"; $Since = $Date.AddHours(-24); $Aggregate = 1}
                            "1W" {$DataInterval = "Hour"; $Since = $Date.AddDays(-7); $Aggregate = 6}
                            "1M" {$DataInterval = "Day"; $Since = $Date.AddDays(-30); $Aggregate = 1}
                            "1Y" {$DataInterval = "Day"; $Since = $Date.AddDays(-365); $Aggregate = 15}
                            "5Y" {$DataInterval = "Day"; $Since = $Date.AddYears(-5); $Aggregate = 30}
                        }
                        $Splat = @{DataInterval = $DataInterval; Since = $Since; Aggregate = $Aggregate}
                        $History = Get-CoinPriceHistory -FromSymbol ETH -ToSymbol $ToCurrency @Splat -Until (Get-Date)
                        $History | Select-Object @{N = "Date"; E = {$_.Time.ToShortDateString()}}, @{N = $ToCurrency; E = {$_.high}} |
                            Out-UDChartData -LabelProperty Date -Dataset @(
                            New-UDLineChartDataset -DataProperty $ToCurrency -Label $ToCurrency -BorderWidth 1 -LineTension 0 -BackgroundColor $Color_Ether1 -BorderColor $Color_Ether2
                        )
                    } -FilterFields {
                        New-UDInputField -Type select -Name TimeRange -Values @("1H", "1D", "1W", "1M", "1Y", "5Y") -DefaultValue "1D"
                        New-UDInputField -Type select -Name ToCurrency -Values @("USD", "BTC", "LTC") -DefaultValue "USD"
                    }
                }
            }
        }

        # Litecoin column
        New-UDColumn -Size 4 -Content {
            New-UDRow -Columns {
                New-UDColumn -Content {$Img_Litecoin}
            }
            
            New-UDRow -Columns {
                New-UDColumn -Content {
                    New-UDChart @Splat_LineChart -Endpoint {
                        param ($TimeRange, $ToCurrency)

                        $Date = Get-Date
                        switch ($TimeRange)
                        {
                            "1H" {$DataInterval = "Minute"; $Since = $Date.AddHours(-1); $Aggregate = 5}
                            "1D" {$DataInterval = "Hour"; $Since = $Date.AddHours(-24); $Aggregate = 1}
                            "1W" {$DataInterval = "Hour"; $Since = $Date.AddDays(-7); $Aggregate = 6}
                            "1M" {$DataInterval = "Day"; $Since = $Date.AddDays(-30); $Aggregate = 1}
                            "1Y" {$DataInterval = "Day"; $Since = $Date.AddDays(-365); $Aggregate = 15}
                            "5Y" {$DataInterval = "Day"; $Since = $Date.AddYears(-5); $Aggregate = 30}
                        }
                        $Splat = @{DataInterval = $DataInterval; Since = $Since; Aggregate = $Aggregate}
                        $History = Get-CoinPriceHistory -FromSymbol LTC -ToSymbol $ToCurrency @Splat -Until (Get-Date)
                        $History | Select-Object @{N = "Date"; E = {$_.Time.ToShortDateString()}}, @{N = $ToCurrency; E = {$_.high}} |
                            Out-UDChartData -LabelProperty Date -Dataset @(
                            New-UDLineChartDataset -DataProperty $ToCurrency -Label $ToCurrency -BorderWidth 1 -LineTension 0 -BackgroundColor $Color_Litecoin1 -BorderColor $Color_Litecoin2
                        )
                    } -FilterFields {
                        New-UDInputField -Type select -Name TimeRange -Values @("1H", "1D", "1W", "1M", "1Y", "5Y") -DefaultValue "1D"
                        New-UDInputField -Type select -Name ToCurrency -Values @("USD", "BTC", "ETH") -DefaultValue "USD"
                    }
                }
            }
        }
    }

    # let's make a paged grid with all available coins, and a table of the top coins
    New-UDLayout -Columns 2 -Content {
        New-UDTable -Title "Top Coins" -Headers "Rank", "Name", "Price", "Market Cap", "24 hour change" -Endpoint {
            $TopCoins = Get-Coin
            $Prices = Get-CoinPrice -FromSymbol $TopCoins.Symbol -ToSymbols USD
            $TopCoins | Foreach-Object {
                $Price = $Prices | Where-Object FromSymbol -eq $_.Symbol
                [PSCustomObject]@{
                    SortOrder       = $_.SortOrder
                    CoinName        = $_.CoinName
                    Price           = $Price.Price
                    MktCap          = $Price.MktCap
                    ChangePct24Hour = $Price.ChangePct24Hour
                }
            } | Out-UDTableData -Property "SortOrder", "CoinName", "Price", "MktCap", "ChangePct24Hour"
        }

        New-UDGrid -Title "All Coins" -Headers "Name", "Symbol", "Total Coin Supply" -Properties "CoinName", "Symbol", "TotalCoinSupply" -Endpoint {
            Get-Coin -All | Sort-Object SortOrder | Out-UDGridData
        }
    }
}
#endregion

Start-UDDashboard -Dashboard $Dashboard -Wait
