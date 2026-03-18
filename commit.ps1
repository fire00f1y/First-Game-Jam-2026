$repoPath = "E:\first-game-jam-2026"

Set-Location $repoPath

Write-Host "`nUnstaged changes:" -ForegroundColor Cyan
git status --short

git add .

Write-Host "`nEnter commit message:" -ForegroundColor Cyan
$commitMessage = Read-Host

if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    Write-Host "Commit message cannot be empty. Aborting." -ForegroundColor Red
    Read-Host "`nPress Enter to close"
    exit 1
}

git commit -m $commitMessage
git push

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nPushed successfully!" -ForegroundColor Green
} else {
    Write-Host "`nSomething went wrong. Check the output above." -ForegroundColor Red
}

Read-Host "`nPress Enter to close"