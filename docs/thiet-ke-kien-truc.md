# THIẾT KẾ KIẾN TRÚC HỆ THỐNG DR

## 1. Mục tiêu

Thiết kế kiến trúc sao lưu và phục hồi thảm họa cho ứng dụng Cloud Native.
Hệ thống cần có khả năng sao lưu tài nguyên, bảo vệ dữ liệu và hỗ trợ
khôi phục sau khi xảy ra sự cố.

## 2. Các thành phần chính

- Kubernetes: triển khai và quản lý các tài nguyên ứng dụng.
- Deployment và Pod: chạy ứng dụng trong Kubernetes.
- Service: cung cấp điểm truy cập đến ứng dụng trong cluster.
- ConfigMap: lưu cấu hình không bí mật.
- PostgreSQL: lưu trữ dữ liệu của ứng dụng.
- Velero: hỗ trợ sao lưu và phục hồi tài nguyên Kubernetes.
- Công cụ sao lưu cơ sở dữ liệu: sao lưu và phục hồi dữ liệu PostgreSQL.
- Kho lưu trữ backup: lưu các bản sao lưu để sử dụng khi xảy ra sự cố.

## 3. Luồng hoạt động bình thường

Người dùng gửi yêu cầu đến ứng dụng. Ứng dụng xử lý yêu cầu và truy cập
cơ sở dữ liệu khi cần thiết.

## 4. Luồng sao lưu

Velero được sử dụng để sao lưu các tài nguyên Kubernetes đã chọn.
Dữ liệu PostgreSQL được sao lưu bằng quy trình riêng. Các bản sao lưu
được lưu tại kho lưu trữ đã cấu hình.

## 5. Luồng phục hồi

Khi xảy ra sự cố, nhóm xác định tài nguyên và dữ liệu cần phục hồi.
Nhóm khôi phục tài nguyên Kubernetes, phục hồi cơ sở dữ liệu, sau đó
kiểm tra trạng thái ứng dụng và tính toàn vẹn dữ liệu.

## 6. Giới hạn

Khả năng phục hồi phụ thuộc vào phạm vi sao lưu, vị trí lưu trữ,
cấu hình công cụ và kết quả kiểm thử thực tế.
Sơ đồ thiết kế không thay thế cho việc kiểm chứng phục hồi.