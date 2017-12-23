$Link_UDHome = New-UDLink -Text "Powered by Universal Dashboard" -Url "https://www.poshud.com" -OpenInNewWindow -icon bar_chart_o
$Link_CoinHome = New-UDLink -OpenInNewWindow -Text "Project Home" -Url "https://github.com/mattmcnabb/coindashboard" -Icon github
$Link_BlogHome = New-UDLink -OpenInNewWindow -Text "My Blog" -Url "https://mattmcnabb.github.io" -Icon list
$Link_CryptoCompare = New-UDLink -OpenInNewWindow -Text "CryptCompare.Com" -Url "https://cryptocompare.com"
$Link_TopCoins = New-UDLink -OpenInNewWindow -Text "View Top Coins on CryptoCompare" -url ("{0}/{1}" -f $Link_CryptCompare.Url, "coins/#/usd")

$Splat_Footer = @{
    BackgroundColor = $Config.ThemeColors.Header
    FontColor       = $Config.ThemeColors.Text1
    Links           = $Link_UDHome
    Copyright       = "$([char]169) 2017 Matt McNabb All rights reserved"
}
$Footer = New-UDFooter @Splat_Footer

$Splat_Refresh30Sec    = @{
    AutoRefresh     = $true
    RefreshInterval = 30
}
    
$Splat_Refresh5Min     = @{
    AutoRefresh     = $true
    RefreshInterval = 300
}

$Splat_ElementColors = @{
    BackgroundColor = $Config.ThemeColors.ChartBackground
    FontColor       = $Config.ThemeColors.Text2
}

$Splat_Board = @{
    Footer                       = $Footer
    BackgroundColor              = $Config.ThemeColors.Background
    NavBarColor                  = $Config.ThemeColors.Background
    Title                        = ""
    NavBarLinks                  = $Link_CoinHome, $Link_BlogHome
    EndpointInitializationScript = {Import-Module "D:/home/site/wwwroot/Coin"}
}
