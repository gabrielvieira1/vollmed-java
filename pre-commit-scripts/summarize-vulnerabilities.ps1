# summarize-vulnerabilities.ps1

# Get the absolute path to the project root (assuming script is run from project root or a subdirectory)
# For now, let's assume the script is run from within the project or pre-commit-scripts
# and derive the project root from $PSScriptRoot
$projectRoot = Join-Path $PSScriptRoot ".."

$logDir = Join-Path $projectRoot "logs"
$snykLog = Join-Path $logDir "snyk.log"
$gitleaksLog = Join-Path $logDir "gitleaks.log"
$semgrepLog = Join-Path $logDir "semgrep.log"

Write-Output "Resolved Snyk Log Path: $snykLog" # Added for debugging

Write-Output "Vulnerability Summary Report - $(Get-Date)"
Write-Output "--------------------------------------------------"

# --- Parse Snyk Log ---
Write-Output "`n--- Snyk Vulnerabilities ---"
try {
    $snykContent = Get-Content $snykLog -Raw -ErrorAction Stop
    $snykOutput = $snykContent | ConvertFrom-Json -ErrorAction Stop

    if ($snykOutput.vulnerabilities) {
        Write-Output "  Total Snyk issues found: $($snykOutput.vulnerabilities.Count)"
        $snykOutput.vulnerabilities | ForEach-Object {
            Write-Output "  Name: $($_.title)"
            Write-Output "  Location: $($_.from -join ' > ')"
            Write-Output "  Severity: $($_.severity)"
            Write-Output "  Version: $($_.version)"
            Write-Output "  ---"
        }
    } else {
        Write-Output "  No Snyk vulnerabilities found."
    }
} catch {
    Write-Output "  Snyk log file not found or accessible: $snykLog - $($_.Exception.Message)"
}

# --- Parse GitLeaks Log ---
Write-Output "`n--- GitLeaks Findings ---"
try {
    $gitleaksContent = Get-Content $gitleaksLog -Raw -ErrorAction Stop
    # Strip ANSI escape codes
    $gitleaksContent = $gitleaksContent -replace "\x1b\[[0-9;]*m", ""

    $gitleaksRegex = [regex]"Finding:\s*(?<finding>.*)\nSecret:\s*(?<secret>.*)\nRuleID:\s*(?<ruleid>.*)\nEntropy:\s*(?<entropy>.*)\nFile:\s*(?<file>.*)\nLine:\s*(?<line>.*)\nFingerprint:\s*(?<fingerprint>.*)"

    $matchesFound = $gitleaksContent | Select-String -Pattern $gitleaksRegex -AllMatches
    if ($matchesFound.Matches.Count -gt 0) {
        Write-Output "  Total GitLeaks findings: $($matchesFound.Matches.Count)"
        $matchesFound | ForEach-Object {
            $match = $_.Matches[0]
            Write-Output "  Name: $($match.Groups['ruleid'].Value.Trim())"
            Write-Output "  Location: $($match.Groups['file'].Value.Trim()) (Line: $($match.Groups['line'].Value.Trim()))"
            Write-Output "  Severity: High (Secret Leak)"
            Write-Output "  ---"
        }
    } else {
        Write-Output "  No GitLeaks findings."
    }
    if ($gitleaksContent.Length -eq 0) {
        Write-Output "  GitLeaks log is empty or GitLeaks scan failed to produce output."
    } elseif ($gitleaksContent -notmatch "leaks found") {
        Write-Output "  No leaks found."
    }
} catch {
    Write-Output "  GitLeaks log file not found or accessible: $gitleaksLog - $($_.Exception.Message)"
}

# --- Parse Semgrep Log ---
Write-Output "`n--- Semgrep Findings ---"
try {
    $semgrepContent = Get-Content $semgrepLog -Raw -ErrorAction Stop
    # Aggressively try to find and extract the JSON part
    # This regex looks for a string starting with { and ending with } (non-greedy)
    # and tries to capture the content between them.
    if ($semgrepContent -match '(\{.*?\})') { # Changed to non-greedy .*?
        $semgrepJsonContent = $matches[1]
    } else {
        throw "No JSON content found in Semgrep log using aggressive regex."
    }

    $semgrepOutput = $semgrepJsonContent | ConvertFrom-Json -ErrorAction Stop

    if ($semgrepOutput.results) {
        Write-Output "  Total Semgrep findings: $($semgrepOutput.results.Count)"
        $semgrepOutput.results | ForEach-Object {
            Write-Output "  Name: $($_.check_id)"
            Write-Output "  Location: $($_.path) (Line: $($_.start.line))"
            Write-Output "  Severity: $($_.severity)"
            Write-Output "  ---"
        }
    } else {
        Write-Output "  No Semgrep findings."
    }
} catch {
    Write-Output "  Semgrep log file not found or accessible/parsable: $semgrepLog - $($_.Exception.Message)"
}

Write-Output "`nReport End."
