# Runbook sao lưu và phục hồi PostgreSQL

## 1. Phạm vi

Quy trình dùng để diễn tập sao lưu và phục hồi dữ liệu PostgreSQL trên môi trường lab của Nhóm 23.

## 2. Chuẩn bị

1. Khởi động hệ thống theo [hướng dẫn triển khai](huong-dan-trien-khai.md).
2. Kiểm tra PostgreSQL, ứng dụng và MinIO đang chạy.
3. Mở `http://localhost:5000/students/count` và ghi lại số bản ghi ban đầu. Nếu có bản ghi kiểm thử, ghi lại mã của bản ghi để đối chiếu.

## 3. Sao lưu PostgreSQL

1. Mở PowerShell tại thư mục gốc của dự án và chạy:

   ```powershell
   .\backup-database.ps1
   ```

2. Ghi lại tên file `.backup` mà script in ra. Bản sao trên máy nằm trong thư mục `backup\backups`.
3. Script dùng `pg_restore --list` để đọc danh mục nội dung của bản sao, sau đó tải file lên MinIO. Nếu có lỗi khi xác nhận file trên MinIO, xem mục 6.

## 4. Diễn tập phục hồi

Kịch bản có bước xóa dữ liệu để giả lập sự cố. Chỉ chạy trên môi trường lab.

1. Từ thư mục gốc của dự án, chạy:

   ```powershell
   .\tests\test-dr-e2e.ps1
   ```

2. Xem `TC-04` trong log để xác nhận số bản ghi qua API giảm về 0 sau khi giả lập sự cố.
3. Xem `TC-05` để xác nhận bước phục hồi PostgreSQL hoàn tất và ghi lại thời gian của bước này.

## 5. Kiểm tra sau phục hồi

1. Xem `TC-06` và đối chiếu số bản ghi sau phục hồi với số bản ghi ban đầu.
2. Mở `/students` để kiểm tra bản ghi kiểm thử đã xuất hiện lại.
3. Lưu log của lần diễn tập vào `results/`. Khi tổng hợp, ghi chỉ số tại `TC-05` là **thời gian phục hồi PostgreSQL**.

## 6. Xử lý sự cố khi kiểm tra bản sao trên MinIO

Nếu script báo `Khong tim thay file backup tren MinIO.`, hãy ghi lại tên
file `.backup` ở dòng `Sao luu PostgreSQL thanh cong:`. Sau đó, mở PowerShell
trên máy chạy lab và liệt kê các file trong bucket MinIO:

```powershell
& "C:\minio\mc.exe" ls local/backup-cloud-native
```

- Nếu danh sách có đúng tên file vừa tạo, bản sao đã xuất hiện trong bucket.
  Kiểm tra dòng `mc stat` ngay sau bước tải lên. Dòng này cần dùng `$tenFile`
  để kiểm tra đúng file mới.
- Nếu danh sách hiện ra nhưng thiếu file vừa tạo, kiểm tra lại kết quả của
  lệnh tải lên và bucket đích.
- Nếu lệnh `ls` báo lỗi, kiểm tra đường dẫn `mc.exe`, alias `local` và trạng
  thái của MinIO trước khi kết luận về file backup.
