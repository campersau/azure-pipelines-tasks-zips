if (Test-Path -path azure-pipelines-tasks)
{
    pushd azure-pipelines-tasks
    & git reset --hard
    & git pull --all --quiet
}
else 
{
    & git clone https://github.com/microsoft/azure-pipelines-tasks.git --quiet
    pushd azure-pipelines-tasks
}

git config --local pager.branch false
$branches = & git branch -r
$version = (($branches | Select-String -pattern "(?<=origin/releases/m)\d+$").Matches) | %{ [int32]$_.Value } | measure-object -maximum
$version = $version.Maximum
popd

Write-Host "Release version: m$version"

$tag = "m$version"
$release = (& gh release view $tag --json url) | ConvertFrom-Json
if (-not $release)
{
    . .\download.ps1
    & gh release create $tag -t "$tag" --target main -n """" (dir _download/*.zip)
}
else 
{
    Write-Host "Already exists: $($release.url)"
}

$tag = "m$version-sxs"
$release = (& gh release view $tag --json url) | ConvertFrom-Json

if (-not $release)
{
    . .\generate-sxs.ps1
    & gh release create $tag -t "$tag" --target main -n """" (dir _sxs/*.zip)
}
else 
{
    Write-Host "Already exists: $($release.url)"
}