# SƠ ĐỒ KIẾN TRÚC HỆ THỐNG DR

## 1. Thành phần

- Người dùng
- Ứng dụng Cloud Native
- Kubernetes Deployment và Pod
- PostgreSQL
- Velero
- Công cụ sao lưu PostgreSQL
- Kho lưu trữ bản sao lưu

## 2. Luồng hoạt động

Người dùng truy cập ứng dụng. Ứng dụng xử lý yêu cầu và trao đổi dữ
liệu với PostgreSQL.

## 3. Luồng sao lưu

Velero sao lưu các tài nguyên Kubernetes được lựa chọn.
Công cụ riêng thực hiện sao lưu dữ liệu PostgreSQL.
Các bản sao lưu được đưa đến kho lưu trữ đã cấu hình.

## 4. Luồng phục hồi

Khi xảy ra sự cố, nhóm phục hồi tài nguyên Kubernetes và dữ liệu
PostgreSQL theo đúng trình tự, sau đó kiểm tra khả năng hoạt động
của ứng dụng.