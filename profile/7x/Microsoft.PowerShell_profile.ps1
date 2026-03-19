Import-Module "$HOME\Documents\PowerShell\Modules\PSReadLine\2.4.5\PSReadLine.psd1" -Force

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
    [Console]::Write([char]27 + "[5 q")
    "PS $($executionContext.SessionState.Path.CurrentLocation)> "
}