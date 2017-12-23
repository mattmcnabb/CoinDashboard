$Config = Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot "Config.ps1")
. (Join-Path $PSScriptRoot "Init.ps1")

function New-Title
{
    param
    (

    )

    New-UDCard @Splat_ElementColors -Text $Config.Title -TextSize Large -TextAlignment center
}

function New-CoinLineChart
{
    [CmdletBinding()]
    param
    (
        $Symbol,

        [ValidateSet("Green", "Blue", "Orange", "Red")]
        $Color,

        [ValidateSet("BTC", "ETH", "LTC", "USD")]
        [string[]]
        $Currencies
    )

    New-UDChart @Splat_Refresh5Min @Splat_ElementColors -Id "LineChart$Symbol" -Type Line -Endpoint {
        param ($TimeRange, $ToCurrency)

        $Date = Get-Date
        switch ($TimeRange)
        {
            "1H" {$DataInterval = "Minute"; $Since = $Date.AddHours( - 1); $Aggregate = 5}
            "1D" {$DataInterval = "Hour"; $Since = $Date.AddHours( - 24); $Aggregate = 1}
            "1W" {$DataInterval = "Hour"; $Since = $Date.AddDays( - 7); $Aggregate = 6}
            "1M" {$DataInterval = "Day"; $Since = $Date.AddDays( - 30); $Aggregate = 1}
            "1Y" {$DataInterval = "Day"; $Since = $Date.AddDays( - 365); $Aggregate = 15}
            "5Y" {$DataInterval = "Day"; $Since = $Date.AddYears( - 5); $Aggregate = 30}
        }
        $Splat = @{DataInterval = $DataInterval; Since = $Since; Aggregate = $Aggregate}
        $History = Get-CoinPriceHistory -FromSymbol $Symbol -ToSymbol $ToCurrency @Splat -Until $Date
        $History | Select-Object @{N = "Date"; E = {$_.Time.ToShortDateString()}}, @{N = $ToCurrency; E = {$_.high}} |
            Out-UDChartData -LabelProperty Date -Dataset @(
            New-UDLineChartDataset -DataProperty $ToCurrency -Label $ToCurrency -LineTension 0 -BorderWidth 1 -BorderColor $Config.ChartColors.$Color -BackgroundColor $Config.ChartColorsTrns.$Color -Fill none
        )
    } -FilterFields {
        New-UDInputField -Type select -Name TimeRange -Values @("1H", "1D", "1W", "1M", "1Y", "5Y") -DefaultValue "1D"
        New-UDInputField -Type select -Name ToCurrency -Values @($Currencies) -DefaultValue "USD"
    }
}

function New-CoinPriceCounter
{
    [CmdletBinding()]
    param
    (
        [String]
        $Name,

        [string]
        $Symbol
    )

    $Splat = @{
        Title         = $Name
        Format        = '$0,0.00'
        Endpoint      = {(Get-CoinPrice $Symbol USD).Price}
        TextSize      = "Medium"
        TextAlignment = "Center"
        Icon          = "usd"
        Id            = "CoinPrice$Symbol"
    }

    New-UDCounter @Splat @Splat_ElementColors @Splat_Refresh30Sec
}

function New-CoinChangeCounter
{
    [CmdletBinding()]
    param
    (
        [string]
        $Symbol
    )

    $Splat = @{
        Title         = "24-hour change"
        Format        = '0.0000%'
        Endpoint      = {0.01 * (Get-CoinPrice $Symbol USD).ChangePct24Hour}
        TextSize      = "Medium"
        TextAlignment = "Center"
        Icon          = "line_chart"
        Id            = "CoinChange$Symbol"
    }

    New-UDCounter @Splat @Splat_ElementColors @Splat_Refresh30Sec
}

function New-TopCoinTable
{
    New-UDTable -Id "TopCoins" -Title "Top Coins" -Style responsive-table @Splat_ElementColors -Headers "Rank", "Name", "Price", "Market Cap", "24 hour change" -Links $Link_TopCoins -Endpoint {
        function Format-Arrow
        {
            param
            (
                [string]
                $String
            )
            switch -Regex ($String)
            {
                "^-" {$String -replace '-', "$([char]0x25BC) "}
                default {"{0}{1}" -f "$([char]0x25B2) ", $String}
            }
        }
        $TopCoins = Get-Coin
        $Prices = Get-CoinPrice -FromSymbol $TopCoins.Symbol -ToSymbols USD
        $TopCoins | Foreach-Object {
            $Price = $Prices | Where-Object FromSymbol -eq $_.Symbol
            [PSCustomObject]@{
                SortOrder       = $_.SortOrder
                CoinName        = New-UDLink -Text $_.CoinName -Url ("{0}{1}" -f $Link_CryptoCompare.Url, $_.Url) -OpenInNewWindow
                Price           = '${0:N2}' -f $Price.Price
                MktCap          = '${0:N2}' -f $Price.MktCap
                ChangePct24Hour = Format-Arrow ('{0:N4}%' -f $Price.ChangePct24Hour)
            }
        } | Out-UDTableData -Property "SortOrder", "CoinName", "Price", "MktCap", "ChangePct24Hour"
    }
}

function New-AllCoinGrid
{
    New-UDGrid @Splat_ElementColors -Id "AllCoins" -Title "All Coins" -Headers "Name", "Symbol", "Total Coin Supply" -Properties "CoinName", "Symbol", "TotalCoinSupply" -Endpoint {
        Get-Coin -All |
            Sort-Object SortOrder |
            Select-Object @{n="CoinName"; e={New-UDLink -Text $_.CoinName -Url ("{0}{1}" -f $Link_CryptoCompare.Url, $_.Url) -OpenInNewWindow}}, Symbol, TotalCoinSupply |
            Out-UDGridData
    }
}

Export-ModuleMember -Function * -Variable *
