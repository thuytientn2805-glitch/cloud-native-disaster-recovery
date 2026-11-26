$ErrorActionPreference = "Stop"
$ThuMucGoc = Split-Path -Parent $PSScriptRoot
Set-Location $ThuMucGoc

$ThoiGianBatDau = Get-Date
$MaTest = "SV_DR_" + (Get-Date -Format "HHmmss")
$TenTest = "Kiem Thu Phuc Hoi DR"
$EmailTest = "dr-test@example.com"
$ThuMucKetQua = Join-Path $ThuMucGoc "results"
if (-not (Test-Path $ThuMucKetQua)) { New-Item -ItemType Directory -Path $ThuMucKetQua | Out-Null }
$FileBaoCao = Join-Path $ThuMucKetQua ("bao-cao-kiem-thu-" + (Get-Date -Format "yyyy-MM-dd_HH-mm-ss") + ".txt")

$KetQuaTest = @()
function Ghi-Log {
    param([string]$Buoc, [string]$TrangThai, [string]$ChiTiet)
    $Dong = "[$(Get-Date -Format 'HH:mm:ss')] [$TrangThai] $Buoc : $ChiTiet"
    $script:KetQuaTest += $Dong
    if ($TrangThai -eq "PASS") { Write-Host $Dong -ForegroundColor Green }
    elseif ($TrangThai -eq "FAIL") { Write-Host $Dong -ForegroundColor Red }
    else { Write-Host $Dong -ForegroundColor Cyan }
}

Write-Host "BAT DAU KIEM THU SAO LUU & PHUC HOI THAM HOA (DR TEST)" -ForegroundColor Yellow

try {
    # TC-01: Kiem tra ha tang Docker & Kubernetes
    Ghi-Log "TC-01" "INFO" "Kiem tra trang thai container va cum Kubernetes..."
    $dbStatus = docker inspect -f '{{.State.Health.Status}}' dr-postgres 2>$null
    $appStatus = docker inspect -f '{{.State.Status}}' dr-app 2>$null
    $minioStatus = docker inspect -f '{{.State.Status}}' dr-minio 2>$null

    if ($dbStatus -eq "healthy" -and $appStatus -eq "running" -and $minioStatus -eq "running") {
        Ghi-Log "TC-01.1" "PASS" "Cac container (dr-postgres, dr-app, dr-minio) dang hoat dong on dinh."
    } else {
        throw "Mot hoac nhieu container chua san sang (DB=$dbStatus, App=$appStatus, MinIO=$minioStatus)."
    }

    $k8sPods = kubectl get pods -n ungdung-dr --no-headers 2>$null
    if ($k8sPods -match "Running") {
        Ghi-Log "TC-01.2" "PASS" "Pod ung dung trong namespace 'ungdung-dr' dang o trang thai Running."
    } else {
        Ghi-Log "TC-01.2" "WARN" "Khong phat hien Pod Running trong namespace 'ungdung-dr'."
    }

    # TC-02: Chen du lieu giao dich moi (RPO Check)
    Ghi-Log "TC-02" "INFO" "Chen ban ghi kiem thu ($MaTest) vao bang sinh_vien..."
    $sqlInsert = "INSERT INTO sinh_vien (ma_sinh_vien, ho_ten, email) VALUES ('$MaTest', '$TenTest', '$EmailTest');"
    docker compose exec -T database psql -U dr_user -d cloud_native_db -c $sqlInsert | Out-Null

    $apiCountBefore = (Invoke-RestMethod -Uri "http://localhost:5000/students/count").so_ban_ghi
    Ghi-Log "TC-02" "PASS" "Da chen du lieu giao dich thanh cong. Tong so ban ghi hien tai: $apiCountBefore."

    # TC-03: Sao luu CSDL va dong bo MinIO
    Ghi-Log "TC-03" "INFO" "Chay kich ban backup-database.ps1..."
    & "$ThuMucGoc\backup-database.ps1" | Out-Null
    $FileBackupMoiNhat = Get-ChildItem "$ThuMucGoc\backup\backups" -Filter "cloud_native_db_*.backup" |
                         Sort-Object LastWriteTime -Descending | Select-Object -First 1

    if ($null -ne $FileBackupMoiNhat) {
        Ghi-Log "TC-03" "PASS" "Tao va dong bo ban sao luu thanh cong: $($FileBackupMoiNhat.Name) ($($FileBackupMoiNhat.Length) bytes)."
    } else {
        throw "Khong tim thay tep backup sau khi chay script sao luu."
    }

    # TC-04: Gia lap tham hoa (Xoa du lieu)
    Ghi-Log "TC-04" "INFO" "GIA LAP THAM HOA: Thuc hien TRUNCATE bang sinh_vien..."
    docker compose exec -T database psql -U dr_user -d cloud_native_db -c "TRUNCATE TABLE sinh_vien RESTART IDENTITY;" | Out-Null
    $apiCountDisaster = (Invoke-RestMethod -Uri "http://localhost:5000/students/count").so_ban_ghi

    if ($apiCountDisaster -eq 0) {
        Ghi-Log "TC-04" "PASS" "Xac nhan tham hoa xay ra: So ban ghi qua API giam ve 0."
    } else {
        throw "Gia lap tham hoa that bai, du lieu van con ($apiCountDisaster ban ghi)."
    }

    # TC-05: Phuc hoi CSDL va do luong RTO
    $BatDauPhucHoi = Get-Date
    Ghi-Log "TC-05" "INFO" "Bat dau phuc hoi CSDL tu tep $($FileBackupMoiNhat.Name)..."
    Copy-Item $FileBackupMoiNhat.FullName "$ThuMucGoc\backup\restore-test\restore.backup" -Force
    docker compose cp "./backup/restore-test/restore.backup" database:/tmp/restore.backup | Out-Null
    docker compose exec -T database pg_restore -U dr_user -d cloud_native_db --clean --if-exists /tmp/restore.backup 2>$null

    $KetThucPhucHoi = Get-Date
    $ThoiGianRTO = [math]::Round(($KetThucPhucHoi - $BatDauPhucHoi).TotalSeconds, 2)
    Ghi-Log "TC-05" "PASS" "Phuc hoi PostgreSQL hoan tat. Thoi gian phuc hoi thuc te (RTO): $ThoiGianRTO giay."

    # TC-06: Kiem chung toan ven du lieu qua API
    Ghi-Log "TC-06" "INFO" "Kiem tra tinh toan ven du lieu qua API /students..."
    $apiDataAfter = Invoke-RestMethod -Uri "http://localhost:5000/students"
    $timThayBanGhi = $apiDataAfter.danh_sach | Where-Object { $_.ma_sinh_vien -eq $MaTest }

    if ($apiDataAfter.so_luong -eq $apiCountBefore -and $null -ne $timThayBanGhi) {
        Ghi-Log "TC-06" "PASS" "Du lieu khoi phuc toan ven 100% ($($apiDataAfter.so_luong) ban ghi, bao gom ban ghi giao dich $MaTest)."
    } else {
        throw "Du lieu sau phuc hoi khong khop! Truoc=$apiCountBefore, Sau=$($apiDataAfter.so_luong)."
    }

    docker compose exec -T database psql -U dr_user -d cloud_native_db -c "DELETE FROM sinh_vien WHERE ma_sinh_vien = '$MaTest';" | Out-Null
    Ghi-Log "CLEANUP" "INFO" "Da don dep ban ghi kiem thu $MaTest, tra he thong ve trang thai chuan."

    $TongThoiGian = [math]::Round(((Get-Date) - $ThoiGianBatDau).TotalSeconds, 2)
    Write-Host "`nKET LUAN: TAT CA CAC KICH BAN KIEM THU DR DEU DAT (PASS) | RTO: $ThoiGianRTO giay | Tong test: $TongThoiGian giay" -ForegroundColor Green
}
catch {
    Ghi-Log "ERROR" "FAIL" $_.Exception.Message
    Write-Host "`nKIEM THU THAT BAI! Vui long kiem tra chi tiet loi phia tren." -ForegroundColor Red
}
finally {
    $KetQuaTest | Out-File -FilePath $FileBaoCao -Encoding UTF8
    Write-Host "Da xuat bien ban kiem thu tu dong tai: $FileBaoCao" -ForegroundColor Yellow
}