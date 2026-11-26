$ErrorActionPreference = "Stop"

# Xac dinh thu muc du an
$thuMucDuAn = $PSScriptRoot

# Thu muc luu ban sao luu
$thuMucBackup = Join-Path $thuMucDuAn "backup\backups"

# Cau hinh MinIO
$mc = "C:\minio\mc.exe"
$bucket = "local/backup-cloud-native"

# Tao thu muc neu chua ton tai
New-Item -ItemType Directory -Force -Path $thuMucBackup | Out-Null

# Tao ten file theo ngay gio
$tenFile = "cloud_native_db_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').backup"
$duongDan = Join-Path $thuMucBackup $tenFile

Write-Host "BAT DAU SAO LUU CO SO DU LIEU..." -ForegroundColor Cyan

try {
    # Kiem tra MinIO Client
    if (-not (Test-Path $mc)) {
        throw "Khong tim thay MinIO Client tai $mc"
    }

    # Tao ban sao luu PostgreSQL
    docker compose -f (Join-Path $thuMucDuAn "docker-compose.yml") exec -T database pg_dump `
        -U dr_user `
        -d cloud_native_db `
        -Fc `
        -f "/tmp/$tenFile"

    if ($LASTEXITCODE -ne 0) {
        throw "Khong tao duoc file backup trong container."
    }

    # Copy file backup tu container ve may tinh
    docker compose -f (Join-Path $thuMucDuAn "docker-compose.yml") cp `
        "database:/tmp/$tenFile" $duongDan

    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $duongDan)) {
        throw "Khong copy duoc file backup ve may tinh."
    }

    # Kiem tra file backup PostgreSQL
    docker compose -f (Join-Path $thuMucDuAn "docker-compose.yml") exec -T database pg_restore --list "/tmp/$tenFile" |
        Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "File backup khong doc duoc."
    }

    Write-Host "Sao luu PostgreSQL thanh cong: $tenFile" -ForegroundColor Green

    # Tu dong tai file backup len MinIO
    Write-Host "Dang tai file backup len MinIO..."

    & $mc cp $duongDan "$bucket/"

    if ($LASTEXITCODE -ne 0) {
        throw "Khong tai duoc file backup len MinIO."
    }

    # Kiem tra file da ton tai tren MinIO
    & $mc stat "$bucket/$($tepCu.Name)" 2>$null | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "Khong tim thay file backup tren MinIO."
    }

    Write-Host "Tai file len MinIO thanh cong!" -ForegroundColor Green

    # Xoa cac ban backup cu hon 7 ngay
    $ngayGioiHan = (Get-Date).AddDays(-7)

    $danhSachCu = Get-ChildItem $thuMucBackup -Filter "cloud_native_db_*.backup" |
        Where-Object { $_.LastWriteTime -lt $ngayGioiHan }

    foreach ($tepCu in $danhSachCu) {
        # Kiem tra xem file co ton tai tren MinIO khong truoc khi thuc hien xoa
        & $mc stat "$bucket/$($tepCu.Name)" | Out-Null
        if ($LASTEXITCODE -eq 0) {
            & $mc rm "$bucket/$($tepCu.Name)" --force | Out-Null
        }

        # Xoa file cu tren may tinh
        Remove-Item $tepCu.FullName -Force -ErrorAction SilentlyContinue

        Write-Host "Da don dep ban backup cu: $($tepCu.Name)" -ForegroundColor Yellow
    }

    # Hien thi danh sach backup tren may tinh
    Write-Host "`nDANH SACH BACKUP HIEN CO TREN MAY TINH:" -ForegroundColor Cyan

    Get-ChildItem $thuMucBackup -Filter "cloud_native_db_*.backup" |
        Select-Object Name, Length, LastWriteTime |
        Format-Table -AutoSize

    # Hien thi danh sach file tren MinIO
    Write-Host "DANH SACH BACKUP TREN MINIO:" -ForegroundColor Cyan

    & $mc ls $bucket

    if ($LASTEXITCODE -ne 0) {
        throw "Khong doc duoc danh sach file tren MinIO."
    }

    Write-Host "`nSAO LUU VA DONG BO MINIO THANH CONG!" -ForegroundColor Green
}
catch {
    Write-Host "`nSAO LUU THAT BAI: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}