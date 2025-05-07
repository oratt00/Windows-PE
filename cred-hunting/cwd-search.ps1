$ErrorActionPreference = 'SilentlyContinue'
$output = @()
$files = Get-ChildItem -Path . -Recurse -Include '*.txt','*.ini','*.cfg','*.config','*.xml','*.git','*.ps1','*.yml'
$results = $files | Select-String -Pattern 'password' -Context 0,5
$grouped = $results | Group-Object -Property Path
foreach ($group in $grouped) {
    $output += "File: " + $group.Name
    $details = ""
    foreach ($match in $group.Group) {
        if ($match.Context.PreContext) {
            $pre = [string]::Join("`n", $match.Context.PreContext)
        } else {
            $pre = ""
        }
        if ($match.Context.PostContext) {
            $post = [string]::Join("`n", $match.Context.PostContext)
        } else {
            $post = ""
        }
        $details += $match.Line + "`n" + $pre + "`n" + $post + "`n"
    }
    if ($details.Trim().Length -le 50) {
        $output += $details
    }
    $output += "`n---------------------`n"
}
$desktop = "$env:USERPROFILE\Desktop"
$outputPath = Join-Path -Path $desktop -ChildPath "output.txt"
$output | Out-File $outputPath -Encoding UTF8
