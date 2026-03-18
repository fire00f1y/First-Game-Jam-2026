$repoPath = "C:\path\to\your\repo"

Set-Location $repoPath

# show what's going to be staged
Write-Host "`nUnstaged changes:" -ForegroundColor Cyan
git status --short

# stage everything
git add .

# ask for commit message
Write-Host "`nEnter commit message:" -ForegroundColor Cyan
$commitMessage = Read-Host

if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    Write-Host "Commit message cannot be empty. Aborting." -ForegroundColor Red
    Read-Host "`nPress Enter to close"
    exit 1
}

# commit and push
git commit -m $commitMessage
git push

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nPushed successfully!" -ForegroundColor Green
} else {
    Write-Host "`nSomething went wrong. Check the output above." -ForegroundColor Red
}

# keep window open so he can read the output
Read-Host "`nPress Enter to close"