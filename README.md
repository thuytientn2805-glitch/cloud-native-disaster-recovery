# Thiết kế và kiểm chứng kế hoạch sao lưu phục hồi thảm họa cho ứng dụng Cloud Native

## 1. Giới thiệu

Dự án được thực hiện nhằm thiết kế và kiểm chứng kế hoạch sao lưu, phục hồi thảm họa cho một ứng dụng Cloud Native. Nhóm tập trung vào việc bảo vệ tài nguyên Kubernetes, sao lưu dữ liệu cơ sở dữ liệu và kiểm tra khả năng phục hồi khi hệ thống gặp sự cố.

## 2. Mục tiêu

- Thiết kế kiến trúc sao lưu và phục hồi cho ứng dụng.
- Xây dựng các file cấu hình triển khai Kubernetes.
- Nghiên cứu và áp dụng công cụ sao lưu phù hợp.
- Thực hiện kiểm thử phục hồi và ghi nhận kết quả.

## 3. Công nghệ sử dụng

- **Kubernetes:** Triển khai và quản lý tài nguyên ứng dụng.
- **Velero:** Hỗ trợ sao lưu và phục hồi tài nguyên Kubernetes.
- **PostgreSQL:** Hệ quản trị cơ sở dữ liệu của ứng dụng.
- **GitHub:** Quản lý mã nguồn, file cấu hình và tài liệu dự án.
- **VS Code:** Soạn thảo mã nguồn và cấu hình.

## 4. Cấu trúc thư mục

- `kubernetes/`: Chứa các file cấu hình Kubernetes.
- `docs/`: Chứa tài liệu thiết kế và hướng dẫn triển khai.
- `app/`: Chứa mã nguồn ứng dụng.
- `database/`: Chứa cấu trúc và dữ liệu cơ sở dữ liệu.
- `backup-database.ps1`: Script sao lưu PostgreSQL.
- `tests/`: Chứa kịch bản kiểm thử.
- `results/`: Lưu kết quả kiểm thử.

## 5. Phạm vi thực hiện

Dự án tập trung vào việc thiết kế kiến trúc, cấu hình môi trường triển khai, xây dựng phương án sao lưu và thực hiện kiểm thử phục hồi. Kết quả đánh giá sẽ dựa trên các thử nghiệm thực tế của nhóm.

## 6. Trạng thái dự án

Các file cấu hình và tài liệu được xây dựng, cập nhật trong quá trình thực hiện. Khả năng sao lưu và phục hồi chỉ được xác nhận sau khi nhóm triển khai và kiểm thử thành công trong môi trường thử nghiệm.

## Minh chứng kiểm thử ngày 25/11/2026

Ba log trong [results/](results/) ghi nhận thời gian chạy bước phục hồi PostgreSQL lần lượt là 1,07 s, 1,50 s và 7,02 s. API trả lại toàn bộ 4, 5 và 5 bản ghi tương ứng sau sự cố giả lập mất dữ liệu bảng. Đây là thời gian của bước phục hồi CSDL. Các log này chưa đo RTO đầu cuối hoặc chứng minh khôi phục cả cụm Kubernetes.

## Tái lập trên môi trường thực hành

Xem [hướng dẫn triển khai](docs/huong-dan-trien-khai.md) và tạo `.env` từ `.env.example` với giá trị riêng. Chỉ chạy `tests/test-dr-e2e.ps1` trên hệ thống thử nghiệm có thể khôi phục vì kịch bản có bước xóa dữ liệu trong bảng để giả lập sự cố.
