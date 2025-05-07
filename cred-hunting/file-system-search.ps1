$ErrorActionPreference = 'SilentlyContinue'
$output = @()
$patterns = 'password','username','user','pass','cred','credentials','credential'
$drives = Get-PSDrive -PSProvider 'FileSystem'
foreach ($drive in $drives) {
    $files = Get-ChildItem -Path $drive.Root -Recurse -Include '*.txt','*.ini','*.cfg','*.config','*.xml','*.git','*.ps1','*.yml'
    $results = $files | Select-String -Pattern $patterns -Context 0,5
    $grouped = $results | Group-Object -Property Path
    foreach ($group in $grouped) {
        $output += "File: " + $group.Name
        $details = ""
        foreach ($match in $group.Group) {
            $pre = if ($match.Context.PreContext) { [string]::Join("`n", $match.Context.PreContext) } else { "" }
            $post = if ($match.Context.PostContext) { [string]::Join("`n", $match.Context.PostContext) } else { "" }
            $details += $match.Line + "`n" + $pre + "`n" + $post + "`n"
        }
        if ($details.Trim().Length -le 50) {
            $output += $details
        }
        $output += "`n---------------------`n"
    }
}
$desktop = "$env:USERPROFILE\Desktop"
$outputPath = Join-Path -Path $desktop -ChildPath "output.txt"
$output | Out-File $outputPath -Encoding UTF8
