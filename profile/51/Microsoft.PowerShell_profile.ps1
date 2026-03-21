Clear-Host
Write-Host "Windows PowerShell 5.1"
Write-Host "Copyright (C) Microsoft Corporation. All rights reserved."
Write-Host ""

Import-Module "$HOME\Documents\WindowsPowerShell\Modules\PSReadLine\2.4.5\PSReadLine.psd1" -Force

Set-PSReadLineOption -Colors @{
    Command            = "Yellow"
    Comment            = "DarkGreen"
    ContinuationPrompt = "Gray"
    Default            = "Gray"
    Emphasis           = "Cyan"
    Error              = "Red"
    Keyword            = "Green"
    Member             = "White"
    Number             = "White"
    Operator           = "DarkGray"
    Parameter          = "DarkGray"
    String             = "DarkCyan"
    Type               = "Gray"
    Variable           = "Green"
}


function prompt {
    "PS $($executionContext.SessionState.Path.CurrentLocation)> "
}
