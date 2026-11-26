# SO SÁNH CÁC MÔ HÌNH PHỤC HỒI THẢM HỌA

## 1. Backup and Restore

Hệ thống tạo bản sao lưu định kỳ. Khi xảy ra sự cố, nhóm sử dụng
bản sao lưu để phục hồi tài nguyên và dữ liệu.

Ưu điểm:
- Dễ hiểu và phù hợp với bài thực hành.
- Có thể triển khai từng bước.
- Phù hợp để kiểm tra khả năng phục hồi.

Hạn chế:
- Có thể cần nhiều thời gian để khôi phục.
- Phụ thuộc vào chất lượng và độ mới của bản sao lưu.

## 2. Pilot Light

Duy trì các thành phần thiết yếu ở môi trường dự phòng.
Khi xảy ra sự cố, các thành phần còn lại được kích hoạt.

Ưu điểm:
- Không cần duy trì toàn bộ hệ thống dự phòng hoạt động liên tục.

Hạn chế:
- Cần quy trình kích hoạt và cấu hình bổ sung.

## 3. Warm Standby

Duy trì môi trường dự phòng ở trạng thái sẵn sàng tương đối.

Ưu điểm:
- Có thể giảm thời gian phục hồi so với dựng mới hoàn toàn.

Hạn chế:
- Tốn tài nguyên và công sức quản lý môi trường dự phòng.

## 4. Active-Active

Hai môi trường cùng tham gia phục vụ ứng dụng.

Ưu điểm:
- Có thể duy trì dịch vụ khi một môi trường gặp sự cố.

Hạn chế:
- Phức tạp về đồng bộ dữ liệu, điều phối lưu lượng và vận hành.

## 5. Lựa chọn mô hình

Nhóm chọn Backup and Restore làm mô hình triển khai ban đầu vì phù hợp
với phạm vi bài tập. Nhóm sẽ tập trung sao lưu tài nguyên Kubernetes,
sao lưu dữ liệu PostgreSQL bằng quy trình riêng và thực hiện kiểm thử
phục hồi trong môi trường thử nghiệm.