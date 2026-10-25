<#
.SYNOPSIS
    Script tự động Deploy và Process Full mô hình SSAS Tabular (DAAI_OLAP) cho dự án DAAI-N2.5.
.DESCRIPTION
    Script này đọc cấu hình mô hình từ file Olap/SSAS/Model.bim, kết nối tới SSAS Tabular Server,
    tạo mới Database DAAI_OLAP và nạp toàn bộ dữ liệu vào bộ nhớ VertiPaq RAM (Process Full).
.PARAMETER ServerName
    Tên SSAS Tabular Instance (mặc định: 'localhost' hoặc 'localhost:2383').
.PARAMETER DatabaseName
    Tên Database trên SSAS (mặc định: 'DAAI_OLAP').
.PARAMETER ModelBimPath
    Đường dẫn tới file Model.bim (mặc định: 'Olap/SSAS/Model.bim').
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\Deploy_SSAS.ps1
    powershell -ExecutionPolicy Bypass -File .\Deploy_SSAS.ps1 -ServerName "localhost\TABULAR"
#>

param(
    [string]$ServerName = "localhost",
    [string]$DatabaseName = "DAAI_OLAP",
    [string]$ModelBimPath = "Olap\SSAS\Model.bim"
)

$ErrorActionPreference = "Stop"
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   QUY TRÌNH DEPLOY & PROCESS FULL SSAS TABULAR (DAAI_OLAP)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Tìm và Load thư viện Microsoft.AnalysisServices.Tabular (TOM)
$loaded = $false
$possiblePaths = @(
    "C:\Program Files\Microsoft SQL Server Management Studio 22\Release\Common7\IDE\Microsoft.AnalysisServices.Tabular.dll",
    "C:\Program Files\Microsoft SQL Server Management Studio 21\Release\Common7\IDE\Microsoft.AnalysisServices.Tabular.dll",
    "C:\Program Files\Microsoft SQL Server Management Studio 20\Common7\IDE\Microsoft.AnalysisServices.Tabular.dll",
    "C:\Program Files (x86)\Microsoft SQL Server Management Studio 19\Common7\IDE\Microsoft.AnalysisServices.Tabular.dll",
    "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Microsoft.AnalysisServices.Tabular.dll"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        try {
            Add-Type -Path $path -ErrorAction SilentlyContinue
            $loaded = $true
            Write-Host "Đã nạp thư viện TOM từ: $path" -ForegroundColor Gray
            break
        } catch { }
    }
}

if (-not $loaded) {
    try {
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices.Tabular") | Out-Null
        $loaded = $true
    } catch {
        Write-Error "Không tìm thấy thư viện Microsoft.AnalysisServices.Tabular.dll. Hãy đảm bảo máy đã cài đặt SSMS!"
        exit 1
    }
}

# 2. Kết nối tới SSAS Server
Write-Host "Đang kết nối tới SSAS Server: '$ServerName'..." -ForegroundColor Yellow
$server = New-Object Microsoft.AnalysisServices.Tabular.Server
try {
    $server.Connect($ServerName)
    Write-Host "Kết nối thành công tới SSAS Server!" -ForegroundColor Green
} catch {
    Write-Error "Không thể kết nối tới SSAS Tabular '$ServerName'. Hãy kiểm tra dịch vụ SSAS Tabular đã khởi động trong Services (services.msc)!"
    exit 1
}

# 3. Kiểm tra file Model.bim
if (-not (Test-Path $ModelBimPath)) {
    # Thử tìm ở thư mục cha nếu đang chạy từ thư mục con
    if (Test-Path "..\$ModelBimPath") {
        $ModelBimPath = "..\$ModelBimPath"
    } else {
        Write-Error "Không tìm thấy file mô hình tại '$ModelBimPath'!"
        $server.Disconnect()
        exit 1
    }
}

Write-Host "Đang đọc cấu trúc mô hình từ: $ModelBimPath..." -ForegroundColor Yellow
$json = Get-Content -Raw -Encoding UTF8 $ModelBimPath
$db = [Microsoft.AnalysisServices.Tabular.JsonSerializer]::DeserializeDatabase($json)
$db.Name = $DatabaseName

# 4. Triển khai mô hình vào SSAS
if ($server.Databases.Contains($DatabaseName)) {
    Write-Host "Database '$DatabaseName' đã tồn tại. Đang xóa bản cũ để cập nhật..." -ForegroundColor Yellow
    $server.Databases[$DatabaseName].Drop()
}

Write-Host "Đang tạo mới Database '$DatabaseName' trên SSAS..." -ForegroundColor Yellow
$server.Databases.Add($db)
$db.Update()
Write-Host "Khởi tạo Database '$DatabaseName' trên SSAS thành công!" -ForegroundColor Green

# 5. Nạp dữ liệu vào VertiPaq RAM (Process Full)
Write-Host "Đang nạp dữ liệu từ SQL Server vào VertiPaq RAM (Process Full)..." -ForegroundColor Yellow
try {
    $db.Model.RequestRefresh([Microsoft.AnalysisServices.Tabular.RefreshType]::Full)
    $db.Model.SaveChanges()
    Write-Host "Process Full hoàn tất! Dữ liệu đã sẵn sàng trong RAM." -ForegroundColor Green
} catch {
    Write-Error "Lỗi trong quá trình nạp dữ liệu Process Full: $_"
    $server.Disconnect()
    exit 1
}

# 6. Thống kê bảng và Measure
$tableCount = $db.Model.Tables.Count
$measureCount = 0
foreach ($tbl in $db.Model.Tables) {
    $measureCount += $tbl.Measures.Count
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   DEPLOY & NẠP DỮ LIỆU THÀNH CÔNG!" -ForegroundColor Green
Write-Host "   - Database SSAS: $DatabaseName" -ForegroundColor White
Write-Host "   - Số bảng Dimension & Fact: $tableCount" -ForegroundColor White
Write-Host "   - Số Measure/Metric/KPI đã nạp: $measureCount" -ForegroundColor White
Write-Host "   - Trạng thái: Sẵn sàng kết nối Live từ Power BI Desktop!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan

$server.Disconnect()
