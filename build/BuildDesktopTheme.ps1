[CmdletBinding()]
param(
    [string]$ToolboxPath,
    [string]$ThemeDirectory = (Join-Path (Split-Path $PSScriptRoot -Parent) 'KittelTheme'),
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'dist')
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $ThemeDirectory -PathType Container)) {
    throw "Theme directory not found: $ThemeDirectory"
}
$ThemeDirectory = (Resolve-Path -LiteralPath $ThemeDirectory).Path

if (-not $ToolboxPath) {
    $toolboxCommand = Get-Command 'Toolbox.exe' -CommandType Application -ErrorAction SilentlyContinue
    if ($toolboxCommand) {
        $ToolboxPath = $toolboxCommand.Source
    }
    else {
        $toolboxCandidates = @(
            (Join-Path $env:LOCALAPPDATA 'Playnite\Toolbox.exe'),
            (Join-Path $env:ProgramFiles 'Playnite\Toolbox.exe'),
            (Join-Path ${env:ProgramFiles(x86)} 'Playnite\Toolbox.exe')
        )
        $ToolboxPath = $toolboxCandidates |
            Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) } |
            Select-Object -First 1
    }
}

if (-not $ToolboxPath -or -not (Test-Path -LiteralPath $ToolboxPath -PathType Leaf)) {
    throw 'Toolbox.exe was not found. Install Playnite or pass its path with -ToolboxPath.'
}
$ToolboxPath = (Resolve-Path -LiteralPath $ToolboxPath).Path

$OutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
if (-not (Test-Path -LiteralPath $OutputDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
}

Write-Host "Packaging theme from '$ThemeDirectory'..."
& $ToolboxPath pack $ThemeDirectory $OutputDirectory
if ($LASTEXITCODE -ne 0) {
    throw "Toolbox pack failed with exit code $LASTEXITCODE."
}

Write-Host "Theme package output: '$OutputDirectory'"