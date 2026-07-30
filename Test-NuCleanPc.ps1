<#
/**
 * @file Test-NuCleanPc.ps1
 * @brief 저장소와 NCS가 없는 Windows PC에서 Board Manager 설치와 Upload를 검증한다.
 */
#>

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$IndexUrl = 'https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/package_nucode_index.json',

    [ValidateNotNullOrEmpty()]
    [string]$ArduinoCli = 'C:\Program Files\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe',

    [string]$Port = '',

    [string]$WorkRoot = '',

    [ValidateRange(0, 4294967295)]
    [uint32]$BuildId = 0,

    [ValidateRange(5, 120)]
    [int]$SerialTimeoutSeconds = 20,

    [switch]$EnforceCleanHost
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$nuUtf8Encoding = [System.Text.UTF8Encoding]::new($false)

try
{
    [Console]::InputEncoding = $nuUtf8Encoding
    [Console]::OutputEncoding = $nuUtf8Encoding
}
catch
{
    ## @note Console이 없는 Host에서도 Clean-PC 시험은 계속할 수 있어야 한다.
}

$global:OutputEncoding = $nuUtf8Encoding

$fqbn = 'nucode:zephyr:nu40dk_v2'
$platformVersion = '0.3.1'

if ($BuildId -eq 0)
{
    $BuildId = [uint32][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

    if ($BuildId -eq 0)
    {
        $BuildId = [uint32]1
    }
}

if ([string]::IsNullOrWhiteSpace($WorkRoot))
{
    $WorkRoot = Join-Path $env:TEMP 'NUCODE-Clean'
}

$WorkRoot = [System.IO.Path]::GetFullPath($WorkRoot)
$tempRoot = [System.IO.Path]::GetFullPath($env:TEMP).TrimEnd('\') + '\'

if (-not $WorkRoot.StartsWith(
    $tempRoot,
    [System.StringComparison]::OrdinalIgnoreCase))
{
    throw "시험 작업 경로는 TEMP 아래에 있어야 합니다: $WorkRoot"
}

if (-not (Test-Path -LiteralPath $ArduinoCli))
{
    throw "Arduino CLI를 찾을 수 없습니다: $ArduinoCli"
}

$configPath = Join-Path $WorkRoot 'arduino-cli.yaml'
$dataRoot = Join-Path $WorkRoot 'data'
$downloadsRoot = Join-Path $WorkRoot 'downloads'
$userRoot = Join-Path $WorkRoot 'user'
$sketchRoot = Join-Path $userRoot 'Blink'
$buildRoot = Join-Path $WorkRoot 'build'
$servoSketchRoot = Join-Path $userRoot 'ServoApiSmoke'
$servoBuildRoot = Join-Path $WorkRoot 'servo-build'
$evidenceRoot = Join-Path $WorkRoot 'evidence'
$evidencePath = Join-Path $evidenceRoot 'clean-pc-evidence.json'

## @brief 외부 개발 도구 설치 여부를 확인한다.
function Test-NuExternalCommand
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

## @brief 격리 설정으로 Arduino CLI를 실행하고 출력을 반환한다.
function Invoke-NuArduinoCli
{
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    Write-Host ">> arduino-cli $($Arguments -join ' ')"
    $previousErrorActionPreference = $ErrorActionPreference

    try
    {
        ## @note Windows PowerShell 5.1의 Native stderr 조기 중단을 방지한다.
        $ErrorActionPreference = 'Continue'
        $output = @(
            & $ArduinoCli --config-file $configPath @Arguments 2>&1
        )
        $exitCode = $LASTEXITCODE
    }
    finally
    {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    $outputText = (($output | ForEach-Object {
        $_.ToString()
    }) -join [Environment]::NewLine)
    Write-Host $outputText

    if ($exitCode -ne 0)
    {
        throw "Arduino CLI 실패: 종료 코드 $exitCode"
    }

    return $outputText
}

$hostChecks = [ordered]@{
    ncs_root_exists = Test-Path -LiteralPath 'C:\ncs'
    go_on_path = Test-NuExternalCommand -Name 'go.exe'
    west_on_path = Test-NuExternalCommand -Name 'west.exe'
    arm_gcc_on_path = Test-NuExternalCommand -Name 'arm-zephyr-eabi-gcc.exe'
    source_repository_exists = Test-Path -LiteralPath (
        Join-Path $env:USERPROFILE 'GitHub\NU_nRF_Arduino_Platform')
}

if ($EnforceCleanHost)
{
    foreach ($entry in $hostChecks.GetEnumerator())
    {
        if ([bool]$entry.Value)
        {
            throw "Clean-PC 조건 위반: $($entry.Key)=true"
        }
    }
}

if (Test-Path -LiteralPath $WorkRoot)
{
    Remove-Item -LiteralPath $WorkRoot -Recurse -Force
}

New-Item -ItemType Directory `
    -Path $dataRoot, $downloadsRoot, $userRoot, $sketchRoot, `
        $servoSketchRoot, $evidenceRoot `
    -Force | Out-Null

$yaml = @"
board_manager:
  additional_urls:
    - $IndexUrl
directories:
  data: $($dataRoot.Replace('\', '/'))
  downloads: $($downloadsRoot.Replace('\', '/'))
  user: $($userRoot.Replace('\', '/'))
logging:
  level: info
"@
[System.IO.File]::WriteAllText(
    $configPath,
    $yaml,
    [System.Text.UTF8Encoding]::new($false))

$blink = @"
/**
 * @file Blink.ino
 * @brief NU40 내장 LED와 Native USB CDC를 함께 검증한다.
 */

/** @brief LED와 Native USB Serial을 초기화한다. */
void setup()
{
    Serial.begin(115200);
    pinMode(LED_BUILTIN, OUTPUT);
    digitalWrite(LED_BUILTIN, LED_STATE_OFF);
}

/** @brief LED를 전환하며 Clean-PC 식별 문자열을 1초마다 출력한다. */
void loop()
{
    digitalWrite(LED_BUILTIN, LED_STATE_ON);
    Serial.println("NUCODE CLEAN-PC HELLO $BuildId");
    delay(1000);
    digitalWrite(LED_BUILTIN, LED_STATE_OFF);
    delay(1000);
}
"@
[System.IO.File]::WriteAllText(
    (Join-Path $sketchRoot 'Blink.ino'),
    $blink,
    [System.Text.UTF8Encoding]::new($false))

$servo = @'
/**
 * @file ServoApiSmoke.ino
 * @brief Platform 0.3.1 Servo 공개 API의 Compile과 Link를 검사한다.
 */

#include <Servo.h>

Servo servo;

/** @brief Servo 채널을 연결하고 주요 공개 API를 호출한다. */
void setup()
{
    Serial.begin(115200);

    const uint8_t channel = servo.attach(D2);
    if (channel == INVALID_SERVO)
    {
        Serial.println("SERVO ATTACH FAILED");
        return;
    }

    servo.write(90);
    servo.writeMicroseconds(1000);
    servo.detach();
}

/** @brief Compile 시험용 유휴 Loop를 유지한다. */
void loop()
{
    delay(1000);
}
'@
[System.IO.File]::WriteAllText(
    (Join-Path $servoSketchRoot 'ServoApiSmoke.ino'),
    $servo,
    [System.Text.UTF8Encoding]::new($false))

$null = Invoke-NuArduinoCli -Arguments @('core', 'update-index')
$null = Invoke-NuArduinoCli -Arguments @(
    'core',
    'install',
    "nucode:zephyr@$platformVersion")
$boardList = Invoke-NuArduinoCli -Arguments @(
    'board',
    'listall',
    '--format',
    'json')

if ($boardList -notmatch [regex]::Escape($fqbn))
{
    throw "설치된 Board 목록에서 FQBN을 찾을 수 없습니다: $fqbn"
}

$detectedBoards = Invoke-NuArduinoCli -Arguments @(
    'board',
    'list',
    '--format',
    'json')
$serialDiscoveryMatched = $detectedBoards -match [regex]::Escape($fqbn)
$compileOutput = Invoke-NuArduinoCli -Arguments @(
    'compile',
    '--fqbn',
    $fqbn,
    '--build-path',
    $buildRoot,
    '--build-property',
    "build.nu_build_id=$BuildId",
    '--export-binaries',
    '--clean',
    '--verbose',
    $sketchRoot)

foreach ($forbiddenPattern in @(
    '(?i)[A-Z]:[/\\]ncs[/\\]',
    '(?i)NU_nRF_Arduino_Platform'))
{
    if ($compileOutput -match $forbiddenPattern)
    {
        throw "Compile 출력에서 금지된 개발 경로를 발견했습니다: $forbiddenPattern"
    }
}

$uf2Files = @(
    Get-ChildItem -LiteralPath $sketchRoot -Filter '*.uf2' -Recurse -File
)

if ($uf2Files.Count -ne 1)
{
    throw "Export된 UF2가 정확히 하나가 아닙니다: $($uf2Files.Count)"
}

$servoCompileOutput = Invoke-NuArduinoCli -Arguments @(
    'compile',
    '--fqbn',
    $fqbn,
    '--build-path',
    $servoBuildRoot,
    '--clean',
    '--verbose',
    $servoSketchRoot)

if (($servoCompileOutput -notmatch '(?i)Servo') -or
    (-not (Test-Path -LiteralPath (
        Join-Path $servoBuildRoot 'ServoApiSmoke.ino.uf2') -PathType Leaf)))
{
    throw 'Platform 0.3.1 Servo Compile/Link/UF2를 확인하지 못했습니다.'
}

$uploadExecuted = -not [string]::IsNullOrWhiteSpace($Port)
$serialOutputMatched = $false
$serialLineCount = 0

if ($uploadExecuted)
{
    $null = Invoke-NuArduinoCli -Arguments @(
        'upload',
        '--fqbn',
        $fqbn,
        '--port',
        $Port,
        '--build-path',
        $buildRoot,
        '--verbose')

    $serialPort = [System.IO.Ports.SerialPort]::new(
        $Port,
        115200,
        [System.IO.Ports.Parity]::None,
        8,
        [System.IO.Ports.StopBits]::One)
    $serialPort.ReadTimeout = 1000
    $serialPort.DtrEnable = $true
    $serialPort.RtsEnable = $true

    try
    {
        $serialPort.Open()
        $deadline = (Get-Date).AddSeconds($SerialTimeoutSeconds)
        $expectedSerialLine = "NUCODE CLEAN-PC HELLO $BuildId"

        while ((Get-Date) -lt $deadline)
        {
            try
            {
                $line = $serialPort.ReadLine().Trim()
                if (-not [string]::IsNullOrWhiteSpace($line))
                {
                    Write-Host "[SERIAL] $line"
                    $serialLineCount++

                    if ($line -eq $expectedSerialLine)
                    {
                        $serialOutputMatched = $true
                        break
                    }
                }
            }
            catch [System.TimeoutException]
            {
                ## @note 제한 시간까지 다음 CDC Line을 계속 기다린다.
            }
        }
    }
    finally
    {
        if ($serialPort.IsOpen)
        {
            $serialPort.Close()
        }

        $serialPort.Dispose()
    }

    if (-not $serialOutputMatched)
    {
        throw (
            'Upload 뒤 Native USB Serial 식별 문자열을 확인하지 못했습니다: ' +
            "port=$Port timeout=$SerialTimeoutSeconds")
    }
}

$evidence = [ordered]@{
    schema_version = 1
    test = 'NUCODE-WINDOWS-CLEAN-PC'
    tested_at_utc = [DateTime]::UtcNow.ToString('o')
    computer_name = $env:COMPUTERNAME
    os_version = [Environment]::OSVersion.VersionString
    index_url = $IndexUrl
    fqbn = $fqbn
    platform_version = $platformVersion
    requested_build_id = $BuildId
    host_checks = $hostChecks
    serial_discovery_matched = $serialDiscoveryMatched
    uf2 = $uf2Files[0].FullName
    uf2_sha256 = (Get-FileHash `
        -Algorithm SHA256 `
        -LiteralPath $uf2Files[0].FullName).Hash
    servo_compile_passed = $true
    servo_uf2 = Join-Path $servoBuildRoot 'ServoApiSmoke.ino.uf2'
    forbidden_development_path_found = $false
    upload_executed = $uploadExecuted
    upload_port = $Port
    serial_output_matched = $serialOutputMatched
    serial_line_count = $serialLineCount
}
$evidenceJson = $evidence | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText(
    $evidencePath,
    $evidenceJson + [Environment]::NewLine,
    [System.Text.UTF8Encoding]::new($false))

Write-Host ''
Write-Host 'NUCODE Windows Clean-PC Board Manager 시험 통과' `
    -ForegroundColor Green
Write-Host "FQBN     : $fqbn"
Write-Host "Discovery: $serialDiscoveryMatched"
Write-Host "UF2      : $($uf2Files[0].FullName)"
Write-Host 'Servo     : Compile/Link/UF2 PASS'
Write-Host "Serial    : $serialOutputMatched"
Write-Host "Evidence : $evidencePath"
