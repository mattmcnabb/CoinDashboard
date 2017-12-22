#region Style
# theme colors
$Color_Theme1 = "#F5F5F5" # text color 1
$Color_Theme2 = "#D5D5D5" # text color 2
$Color_Theme3 = "#45668F" # dashboard background
$Color_Theme4 = "#23384B" # header and footer
$Color_Theme5 = "#354F6E" # chart background

# accent colors
$Color_Accent1 = "#2D9A4B" # green
$Color_AccentLight1 = "#442D9A4B" # green
$Color_Accent2 = "#0074D9" # blue
$Color_AccentLight2 = "#440074D9" # blue
$Color_Accent3 = "#FF851B" # orange
$Color_AccentLight3 = "#44FF851B" # orange
$Color_Accent4 = "#FF4136" # red
$Color_AccentLight4 = "#44FF4136" # red

# Images
$Img_Coins = New-UDImage -Path "$PSScriptRoot\images\Coins.png" -Height 50 -Width 50

# Chart options
$Splat_Refresh30Sec = @{
    AutoRefresh     = $true
    RefreshInterval = 30
}
$Splat_Refresh5Min = @{
    AutoRefresh     = $true
    RefreshInterval = 300
}

$Splat_ElementColors = @{
    BackgroundColor = $Color_Theme5
    FontColor       = $Color_Theme2
}

# Header and Footer
$Link_UDHome = New-UDLink -Text "Powered by Universal Dashboard" -Url "https://www.poshud.com" -OpenInNewWindow -icon bar_chart_o
$Link_CoinHome = New-UDLink -OpenInNewWindow -Text "Project Home" -Url "https://github.com/mattmcnabb/coindashboard" -Icon github
$Link_BlogHome = New-UDLink -OpenInNewWindow -Text "My Blog" -Url "https://mattmcnabb.github.io" -Icon list
$Link_IconAuthor = New-UDLink -OpenInNewWindow -Text "Logo by smashicon" -url "https://www.flaticon.com/authors/smashicons" -Icon picture_o
$Link_CCTopCoins = New-UDLink -OpenInNewWindow -Text "View Top Coins on CryptoCompare" -url "https://www.cryptocompare.com/coins/#/usd"

$Splat_Footer = @{
    BackgroundColor = $Color_Theme4
    FontColor       = $Color_Theme1
    Links           = $Link_UDHome, $Link_IconAuthor
    Copyright       = "$([char]169) 2017 Matt McNabb All rights reserved"
}
$Footer = New-UDFooter @Splat_Footer

#endregion

#region Dashboard
$Splat_Board = @{
    Footer                       = $Footer
    BackgroundColor              = $Color_Theme3
    NavBarColor                  = $Color_Theme3
    NavBarFontColor              = $Color_Theme1
    Title                        = ""
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
    # a padding row to move the images down
    New-UDRow -Columns {
        New-UDColumn -Content {
            New-UDCard @Splat_ElementColors -Text "PowerShell Coin Dashboard" -TextSize Large -TextAlignment center
        }
    }

        #region line charts
        # the first row contains the price history charts for BTC, ETH, and LTC, with an image header of each coin's logo
        New-UDLayout -Columns 3 -Content {
            # Bitcoin column
            New-UDColumn  -Content {
                New-UDRow -Columns {
                    New-UDColumn -Size 6 -Content {New-UDCard -Text Bitcoin -TextSize Medium @Splat_ElementColors }
                    New-UDColumn -Size 6 -Content {
                        New-UDCounter @Splat_Refresh30Sec @Splat_ElementColors -Format '$0,0.00' -Icon usd -Endpoint {Get-CoinPrice BTC USD | Select -Exp Price} -TextSize Medium -TextAlignment Center
                    }
                }
                New-UDRow -Columns {
                    New-UDColumn -Content {
                        New-UDChart @Splat_Refresh5Min @Splat_ElementColors -Type Line -Endpoint {
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
                                New-UDLineChartDataset -DataProperty $ToCurrency -Label $ToCurrency -LineTension 0 -BorderWidth 1 -BorderColor $Color_Accent3 -BackgroundColor $Color_AccentLight3 -Fill none
                            )
                        } -FilterFields {
                            New-UDInputField -Type select -Name TimeRange -Values @("1H", "1D", "1W", "1M", "1Y", "5Y") -DefaultValue "1D"
                            New-UDInputField -Type select -Name ToCurrency -Values @("USD", "ETH", "LTC") -DefaultValue "USD"
                        }
                    }
                }
            }

            # Ether column
            New-UDColumn -Content {
                New-UDRow -Columns {
                    New-UDColumn -Size 6 -Content {New-UDCard -Text Ether -TextSize Medium @Splat_ElementColors}
                    New-UDColumn -Size 6 -Content {
                        New-UDCounter @Splat_ElementColors @Splat_Refresh30Sec -Format '$0,0.00' -Icon usd -Endpoint {Get-CoinPrice ETH USD | Select -Exp Price} -TextSize Medium -TextAlignment Center
                    }
                }
                New-UDRow -Columns {
                    New-UDColumn -Content {
                        New-UDChart @Splat_Refresh5Min @Splat_ElementColors -Type Line -Endpoint {
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
                                New-UDLineChartDataset -DataProperty $ToCurrency -Label $ToCurrency -LineTension 0 -BorderWidth 1 -BorderColor $Color_Accent1 -BackgroundColor $Color_AccentLight1 -Fill none
                            )
                        } -FilterFields {
                            New-UDInputField -Type select -Name TimeRange -Values @("1H", "1D", "1W", "1M", "1Y", "5Y") -DefaultValue "1D"
                            New-UDInputField -Type select -Name ToCurrency -Values @("USD", "BTC", "LTC") -DefaultValue "USD"
                        }
                    }
                }
            }

            # Litecoin column
            New-UDColumn -Content {
                New-UDRow -Columns {
                    New-UDColumn -Size 6 -Content {New-UDCard -Text Litecoin -TextSize Medium @Splat_ElementColors}
                    New-UDColumn -Size 6 -Content {
                        New-UDCounter @Splat_ElementColors @Splat_Refresh30Sec -Format '$0,0.00' -Icon usd -Endpoint {Get-CoinPrice LTC USD | Select -Exp Price} -TextSize Medium -TextAlignment Center
                    }
                }
                New-UDRow -Columns {
                    New-UDColumn -Content {
                        New-UDChart @Splat_Refresh5Min @Splat_ElementColors -Type Line -Endpoint {
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
                                New-UDLineChartDataset -DataProperty $ToCurrency -Label $ToCurrency -LineTension 0 -BorderWidth 1  -BorderColor $Color_Accent2 -BackgroundColor $Color_AccentLight2 -Fill none
                            )
                        } -FilterFields {
                            New-UDInputField -Type select -Name TimeRange -Values @("1H", "1D", "1W", "1M", "1Y", "5Y") -DefaultValue "1D"
                            New-UDInputField -Type select -Name ToCurrency -Values @("USD", "BTC", "ETH") -DefaultValue "USD"
                        }
                    }
                }
            }
        }
        #endregion line charts

        #region tables
        # let's make a paged grid with all available coins, and a table of the top coins
        New-UDLayout -Columns 2 -Content {
            New-UDTable -Title "Top Coins" @Splat_ElementColors -Headers "Rank", "Name", "Price", "Market Cap", "24 hour change" -Links $Link_CCTopCoins -Endpoint {
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

            New-UDGrid @Splat_ElementColors -Title "All Coins" -Headers "Name", "Symbol", "Total Coin Supply" -Properties "CoinName", "Symbol", "TotalCoinSupply" -Endpoint {
                Get-Coin -All | Sort-Object SortOrder | Out-UDGridData
            }
        }
        #endregion tables
    }
    #endregion dashboard

    Start-UDDashboard -Dashboard $Dashboard -Wait
