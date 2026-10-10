[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string[]]$Url,

    [ValidateSet('markdown', 'json')]
    [string]$Format = 'markdown'
)

$ErrorActionPreference = 'Stop'

foreach ($item in $Url) {
    $parsed = $null
    if (-not [Uri]::TryCreate($item, [UriKind]::Absolute, [ref]$parsed) -or
        $parsed.Scheme -ne 'https' -or $parsed.Host -ne 'mp.weixin.qq.com') {
        throw "Expected an https://mp.weixin.qq.com article URL; received: $item"
    }
}

$root = Join-Path $env:LOCALAPPDATA 'codex-wechat-article-reader'
$binDir = Join-Path $root 'bin'
$cacheDir = Join-Path $root 'cache'
$pythonDir = Join-Path $root 'python'
$null = New-Item -ItemType Directory -Force -Path $binDir, $cacheDir, $pythonDir

$uvCommand = Get-Command uv -ErrorAction SilentlyContinue
if ($uvCommand) {
    $uv = $uvCommand.Source
} else {
    $uv = Join-Path $binDir 'uv.exe'
    if (-not (Test-Path -LiteralPath $uv)) {
        $arch = $env:PROCESSOR_ARCHITECTURE
        if ($arch -eq 'AMD64') {
            $asset = 'uv-x86_64-pc-windows-msvc.zip'
        } elseif ($arch -eq 'ARM64') {
            $asset = 'uv-aarch64-pc-windows-msvc.zip'
        } else {
            throw "Unsupported Windows architecture: $arch"
        }

        $download = Join-Path $root $asset
        $extractDir = Join-Path $root 'uv-extract'
        try {
            Invoke-WebRequest -Uri "https://github.com/astral-sh/uv/releases/latest/download/$asset" -OutFile $download
            Expand-Archive -LiteralPath $download -DestinationPath $extractDir -Force
            $candidate = Get-ChildItem -LiteralPath $extractDir -Filter 'uv.exe' -Recurse | Select-Object -First 1
            if (-not $candidate) {
                throw 'The downloaded uv archive did not contain uv.exe.'
            }
            Copy-Item -LiteralPath $candidate.FullName -Destination $uv -Force
        } finally {
            Remove-Item -LiteralPath $download, $extractDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

$env:UV_CACHE_DIR = $cacheDir
$env:UV_PYTHON_INSTALL_DIR = $pythonDir
$env:PYTHONIOENCODING = 'utf-8'

$python = Get-ChildItem -LiteralPath $pythonDir -Filter 'python.exe' -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match '\\cpython-3\.12\.[^\\]+\\python\.exe$' } |
    Sort-Object FullName -Descending |
    Select-Object -First 1

if (-not $python) {
    # uv may report a Windows minor-version-link error after it has unpacked
    # the interpreter. Check for the actual executable and use it by path.
    & $uv python install 3.12
    $installExitCode = $LASTEXITCODE
    $python = Get-ChildItem -LiteralPath $pythonDir -Filter 'python.exe' -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match '\\cpython-3\.12\.[^\\]+\\python\.exe$' } |
        Sort-Object FullName -Descending |
        Select-Object -First 1
    if (-not $python) {
        throw "Could not install the isolated Python 3.12 runtime (uv exit code $installExitCode)."
    }
}

$arguments = @('tool', 'run', '--python', $python.FullName, '--from', 'git+https://github.com/mrlong0129/wechat-article-fetcher', 'wxfetch')
if ($Format -eq 'json') {
    $arguments += @('-f', 'json')
}
$arguments += $Url

& $uv @arguments
exit $LASTEXITCODE
