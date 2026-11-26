# HƯỚNG DẪN TRIỂN KHAI

## 1. Yêu cầu

- Máy tính đã cài kubectl.
- Có Kubernetes cluster đang hoạt động.
- Có quyền tạo tài nguyên trong cluster.
- Các file YAML đã được kiểm tra.

## 2. Kiểm tra môi trường

Mở Terminal và chạy:

    kubectl version --client
    kubectl config current-context
    kubectl get nodes

Nếu cluster chưa sẵn sàng, cần cấu hình môi trường trước khi triển khai.

## 3. Triển khai tài nguyên

Tại thư mục gốc của dự án, chạy:

    kubectl apply -f kubernetes/namespace.yaml
    kubectl apply -f kubernetes/configmap.yaml
    kubectl apply -f kubernetes/deployment.yaml
    kubectl apply -f kubernetes/service.yaml

## 4. Kiểm tra kết quả

    kubectl get namespaces
    kubectl get pods -n ungdung-dr
    kubectl get deployments -n ungdung-dr
    kubectl get services -n ungdung-dr

Pod cần ở trạng thái Running và sẵn sàng trước khi kiểm tra truy cập.

## 5. Kiểm tra ứng dụng mẫu

Chạy:

    kubectl port-forward -n ungdung-dr service/ungdung-dichvu 8080:80

Giữ Terminal đang chạy, sau đó mở trình duyệt tại:

    http://localhost:8080

Nếu trang NGINX xuất hiện, ứng dụng mẫu đã có thể được truy cập qua
port-forward.

## 6. Xử lý lỗi cơ bản

Kiểm tra chi tiết Pod:

    kubectl describe pods -n ungdung-dr

Xem log ứng dụng:

    kubectl logs -n ungdung-dr deployment/ungdung-mau

## 7. Lưu ý

Các lệnh trên triển khai ứng dụng mẫu. Việc sao lưu và phục hồi bằng
Velero hoặc công cụ sao lưu PostgreSQL cần được cấu hình và kiểm thử
riêng trước khi kết luận hệ thống đáp ứng yêu cầu DR.