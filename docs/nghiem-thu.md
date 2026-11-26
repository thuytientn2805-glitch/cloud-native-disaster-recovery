# Ghi chú nghiệm thu Đề tài 23

## Môi trường và tái lập

- Windows PowerShell chạy script. Python 3.12 và PostgreSQL 16 là các dòng phiên bản khai báo trong cấu hình. Phiên bản công cụ trên máy quay demo cần xác nhận bằng `docker version`, `docker compose version`, `kubectl version` và `mc --version`. Image MinIO hiện dùng thẻ `latest`.
- Khi triển khai Kubernetes, tạo namespace trước, sau đó tạo Secret và chỉnh image, ConfigMap, địa chỉ PostgreSQL cho lab trước khi áp dụng Deployment.
- Chạy `python results/tao_bieu_do.py` để dựng lại bảng Markdown và biểu đồ SVG từ CSV ba lần kiểm thử.
- Khi kết thúc lab, dừng port-forward bằng Ctrl+C. Từ thư mục gốc dự án, dùng `docker compose down` để tháo dịch vụ và giữ volume. Dọn chính xác Deployment và Service của lần thử trên cụm lab sau khi lưu log và kiểm tra đúng context.

## Chi phí và rủi ro

Repo cấu hình môi trường cục bộ, không cấp phát dịch vụ cloud trả phí. Chi phí điện, lưu trữ và vận hành chưa đo. MinIO cùng máy với PostgreSQL có thể bị ảnh hưởng bởi cùng một sự cố. Thẻ image động có thể ảnh hưởng khả năng tái lập. Cơ chế mã hóa, lưu giữ độc lập và kiểm soát truy cập kho dự phòng cần kiểm thử riêng.

## Bằng chứng và kế hoạch kiểm thử lại

Ba log ghi nhận phục hồi PostgreSQL trong 1,07 s, 1,50 s và 7,02 s. Video cho thấy Pod thay thế sẵn sàng trong cùng namespace. Chưa có log đủ để xác nhận RPO thực đo hoặc RTO đầu cuối khi mất cụm/vùng.

Sau khi thay đổi backup, image hoặc cấu hình triển khai, chạy lại kịch bản trên lab và ghi mã bản ghi, số lượng, tên bản sao và thời gian. Tiếp theo thử phục hồi từ kho độc lập trên môi trường dự phòng. Ghi mốc phát hiện, kích hoạt, cấp phát, phục hồi, đối soát và chuyển truy cập. So sánh hash của object cùng kết quả API trước và sau, rồi cập nhật runbook và đối chiếu với mục tiêu đề xuất.
