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
Trước khi chạy `kubectl apply -f kubernetes/deployment.yaml`:

- Thay `TEN_TAI_KHOAN/cloud-native-app:1.0` bằng tên image Flask mà cụm Kubernetes có thể tải.
- Tạo Secret `dr-db-secret` trong namespace `ungdung-dr`, với hai khóa
  `username` và `password` theo cấu hình PostgreSQL của môi trường lab.

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

## 5. Kiểm tra ứng dụng Flask trên Kubernetes

Kiểm tra Deployment đã sẵn sàng:

```powershell
kubectl rollout status deployment/ungdung-mau -n ungdung-dr
kubectl get pods -n ungdung-dr
```

Mở cổng truy cập ứng dụng:

```powershell
kubectl port-forward -n ungdung-dr service/ungdung-dichvu 8080:80
```

Giữ cửa sổ PowerShell đang chạy. Mở `http://localhost:8080/health`
để kiểm tra phản hồi của ứng dụng Flask. Sau đó, mở
`http://localhost:8080/students/count` để kiểm tra ứng dụng đọc được
số bản ghi từ PostgreSQL.

Nếu Pod chưa sẵn sàng, kiểm tra tên image, Secret `dr-db-secret`
và cấu hình kết nối PostgreSQL.

## 6. Xử lý lỗi cơ bản

Kiểm tra chi tiết Pod:

    kubectl describe pods -n ungdung-dr

Xem log ứng dụng:

    kubectl logs -n ungdung-dr deployment/ungdung-mau

## 7. Lưu ý

Các lệnh trên triển khai ứng dụng mẫu. Việc sao lưu và phục hồi bằng
Velero hoặc công cụ sao lưu PostgreSQL cần được cấu hình và kiểm thử
riêng trước khi kết luận hệ thống đáp ứng yêu cầu DR.
