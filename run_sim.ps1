$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildDir = Join-Path $root 'build'
$iverilog = 'C:\iverilog\bin\iverilog.exe'
$vvp = 'C:\iverilog\bin\vvp.exe'

New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

$output = Join-Path $buildDir 'apb_protocol.vvp'
$sources = @(
    (Join-Path $root 'rtl\apb_protocol.v'),
    (Join-Path $root 'rtl\apb_master_3state.v'),
    (Join-Path $root 'rtl\apb_slave_design.v'),
    (Join-Path $root 'tb\apb_protocol_tb.v')
)

& $iverilog -g2012 -s tb_apb_protocol -o $output $sources
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

& $vvp $output
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host "Waveform created at build\apb_protocol_wave.vcd"
