@echo off
setlocal EnableExtensions EnableDelayedExpansion
title ORB — ONE BUTTON (Ultra Simple)
set ROOT=%~dp0site
set WK=%ROOT%\.well-known
set LOG=%~dp0logs\go_%DATE: =_%_%TIME::=_%_log.txt
set PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe
set SERVE=%TEMP%\orb_ultra_serve.ps1

if not exist "%~dp0logs" mkdir "%~dp0logs"
echo [%DATE% %TIME%] GO start > "%LOG%"
if not exist "%ROOT%" mkdir "%ROOT%"

REM Ensure key files/folders
if not exist "%ROOT%\index.html" (
  >"%ROOT%\index.html" echo ^<!doctype html^><meta charset="utf-8"><title>Orb Universal OK</title>^<h1>OK</h1>
)
if not exist "%ROOT%\manifest.webmanifest" copy "%~dp0site\manifest.webmanifest" "%ROOT%\manifest.webmanifest" >nul
if not exist "%ROOT%\sw.js" copy "%~dp0site\sw.js" "%ROOT%\sw.js" >nul
if not exist "%ROOT%\credits" mkdir "%ROOT%\credits"
if not exist "%ROOT%\credits\index.html" copy "%~dp0site\credits\index.html" "%ROOT%\credits\index.html" >nul
if not exist "%ROOT%\public\downloads" mkdir "%ROOT%\public\downloads"
for %%F in (OrbOne.apk OrbOne.aab OrbOne.ipa) do ( if not exist "%ROOT%\public\downloads\%%F" type nul > "%ROOT%\public\downloads\%%F" )

if not exist "%WK%" mkdir "%WK%"

REM Beacon with defaults (no prompts)
for /f "delims=" %%H in ('powershell -NoProfile -Command "(Get-FileHash -Algorithm SHA256 \"%ROOT%\index.html\").Hash"') do set HASH=%%H
>"%WK%\orb-beacon.json" echo { 
>>"%WK%\orb-beacon.json" echo   "project":"Orb One",
>>"%WK%\orb-beacon.json" echo   "owner":"YOUR_NAME",
>>"%WK%\orb-beacon.json" echo   "contact":{"email":"you@example.com"},
>>"%WK%\orb-beacon.json" echo   "claim":"I, YOUR_NAME, created and ship Orb One. Signature Phrase: I build with trust.",
>>"%WK%\orb-beacon.json" echo   "site":"https://orbone.org",
>>"%WK%\orb-beacon.json" echo   "index_html_sha256":"%HASH%",
>>"%WK%\orb-beacon.json" echo   "created":"%DATE%",
>>"%WK%\orb-beacon.json" echo   "links":["https://orbone.org"]
>>"%WK%\orb-beacon.json" echo }

REM Write the PowerShell server to temp and launch (auto-port, headers)
> "%SERVE%" echo param([string]$root,[int]$startPort=17171,[int]$endPort=17180)
$ErrorActionPreference='Stop'
function L([string]$p){$l=New-Object System.Net.HttpListener; $l.Prefixes.Add($p); $l.Start(); return $l}
$root=[IO.Path]::GetFullPath($root)
for($port=$startPort; $port -le $endPort; $port++){
  try{ $prefix=""http://localhost:$port/""; $l=L($prefix); break }catch{ if($port -eq $endPort){ throw } }
}
Write-Host (""Serving {0} on {1}  (Ctrl+C to stop)"" -f $root,$prefix)
try{ Start-Process ""cmd.exe"" ""/c start """" $prefix"" }catch{}
function Send-File([string]$p,[System.Net.HttpListenerResponse]$r){
  if(-not(Test-Path $p)){ $r.StatusCode=404; $b=[Text.Encoding]::UTF8.GetBytes('Not found'); $r.OutputStream.Write($b,0,$b.Length); $r.Close(); return }
  $ext=[IO.Path]::GetExtension($p).ToLower()
  switch($ext){
    "".html"" { $r.ContentType=""text/html; charset=utf-8"" }
    "".htm""  { $r.ContentType=""text/html; charset=utf-8"" }
    "".js""   { $r.ContentType=""text/javascript; charset=utf-8"" }
    "".css""  { $r.ContentType=""text/css; charset=utf-8"" }
    "".json"" { $r.ContentType=""application/json; charset=utf-8"" }
    "".png""  { $r.ContentType=""image/png"" }
    "".jpg""  { $r.ContentType=""image/jpeg"" }
    "".jpeg"" { $r.ContentType=""image/jpeg"" }
    "".svg""  { $r.ContentType=""image/svg+xml"" }
    default { $r.ContentType=""application/octet-stream"" }
  }
  $r.Headers['Cross-Origin-Opener-Policy']='same-origin'
  $r.Headers['Cross-Origin-Embedder-Policy']='require-corp'
  $r.Headers['Permissions-Policy']='camera=(),microphone=(),geolocation=()'
  $r.Headers['Cache-Control']='no-store'
  $bytes=[IO.File]::ReadAllBytes($p)
  $r.ContentLength64=$bytes.Length
  $r.OutputStream.Write($bytes,0,$bytes.Length)
  $r.Close()
}
while($true){
  $ctx=$l.GetContext(); $req=$ctx.Request; $res=$ctx.Response
  $path=$req.Url.AbsolutePath.TrimStart('/'); if([string]::IsNullOrWhiteSpace($path)){ $path='index.html' }
  $safe=$path -replace '\\','/' -replace '\.\.',''
  $full = Join-Path $root $safe
  Send-File $full $res
}

"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%SERVE%" -root "%ROOT%"
