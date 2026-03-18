$files = git show --stat --name-only --format="" c5f0158716efd636214a2f56b5eee9689f9b3acc
$files = $files | Where-Object { $_ -ne "" }
$files

# write to paths file
$files | Out-File -Encoding utf8 paths.txt

# run filter-repo
git filter-repo --paths-from-file paths.txt --invert-paths

# re-add remote and force push
git add .
git commit -m "clean up file tree"