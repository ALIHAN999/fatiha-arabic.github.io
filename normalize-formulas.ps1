$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)
$changed = @()

Get-ChildItem -Path $PSScriptRoot -Filter *.html | ForEach-Object {
    $path = $_.FullName
    $c = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    $orig = $c

    # 1. Formula grid: equal flexible columns that can shrink
    $c = [regex]::Replace($c, '(?s)(\.formula\s*\{[^}]*?)grid-template-columns:[^;]*;',
        '${1}grid-template-columns: minmax(0, 1fr) auto minmax(0, 1fr) auto minmax(0, 1fr);')

    # 2. Formula gap: uniform compact gap
    $c = [regex]::Replace($c, '(?s)(\.formula\s*\{[^}]*?)gap: [0-9.]+px;',
        '${1}gap: 4px;')

    # 3. Formula parts: adaptive font size
    $c = [regex]::Replace($c, '(?s)(\.formula-part\s*\{[^}]*?)font-size: [0-9.]+rem;',
        '${1}font-size: clamp(1.35rem, 6vw, 1.8rem);')

    # 4. Formula signs: adaptive font size, uniform weight
    $c = [regex]::Replace($c, '(?s)(\.formula-sign\s*\{[^}]*?)font-size: [0-9.]+rem;',
        '${1}font-size: clamp(1.3rem, 5vw, 1.75rem);')
    $c = [regex]::Replace($c, '(?s)(\.formula-sign\s*\{[^}]*?)font-weight: [0-9]+;',
        '${1}font-weight: 700;')

    # 5. Translation line in formula blocks: adaptive
    $c = [regex]::Replace($c, '(?s)(\.translation\s*\{[^}]*?)font-size: [0-9.]+rem;',
        '${1}font-size: clamp(1rem, 4vw, 1.25rem);')

    # 6. Phrase arabic blocks: adaptive font size
    $c = [regex]::Replace($c, '(?s)(\.phrase-arabic\s*\{[^}]*?)font-size: [0-9.]+rem;',
        '${1}font-size: clamp(1.35rem, 6vw, 2rem);')

    # 7. Small phrase arabic blocks: adaptive font size
    $c = [regex]::Replace($c, '(?s)(\.phrase-arabic-small\s*\{[^}]*?)font-size: [0-9.]+rem;',
        '${1}font-size: clamp(1.25rem, 5.5vw, 1.8rem);')

    if ($c -ne $orig) {
        [System.IO.File]::WriteAllText($path, $c, $enc)
        $changed += $_.Name
    }
}

Write-Output "CHANGED:"
$changed | ForEach-Object { Write-Output "  $_" }
Write-Output "TOTAL: $($changed.Count)"
