# Find the 'his' folder
Write-Host "Searching for 'his' folder..."

# Check common paths
$possiblePaths = @(
    "D:\his",
    "D:\Nouveau dossier*\his",
    "E:\his",
    "E:\Nouveau dossier*\his",
    "C:\his"
)

foreach ($path in $possiblePaths) {
    $found = Get-ChildItem -Path $path -ErrorAction SilentlyContinue -Directory
    if ($found) {
        Write-Host "Found: $($found.FullName)"
    }
}

# Search D: drive for his folder
Write-Host "`nSearching D: drive..."
Get-ChildItem -Path "D:\" -Directory -Recurse -Depth 2 -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq "his" } |
    ForEach-Object { Write-Host "Found: $($_.FullName)" }
