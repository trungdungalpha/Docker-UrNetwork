# Hướng dẫn sử dụng với Docker Desktop

## Cài đặt Docker Desktop

1. Tải Docker Desktop: https://www.docker.com/products/docker-desktop/
2. Cài đặt và khởi động Docker Desktop
3. Đảm bảo Docker Desktop đang chạy (icon Docker trong system tray)

## Cách 1: Sử dụng Docker Desktop GUI

### Bước 1: Pull Image từ GitHub Packages

1. Mở Docker Desktop
2. Vào tab **Images**
3. Click **Pull** hoặc nhấn `Ctrl + P`
4. Nhập image name: `ghcr.io/trungdungalpha/docker-urnetwork:latest`
5. Click **Pull**

**Lưu ý**: Nếu image là private, cần login trước:
```bash
docker login ghcr.io -u trungdungalpha
```

### Bước 2: Chạy Container

1. Tìm image `ghcr.io/trungdungalpha/docker-urnetwork:latest` trong danh sách
2. Click **Run** (nút play)
3. Điền thông tin:
   - **Container name**: `urnetwork`
   - **Ports**: `8080:8080` (optional)
   - **Environment variables**:
     - `USER_AUTH`: your-email@gmail.com
     - `PASSWORD`: your-password
     - `ENABLE_GUI_CLOSE`: `false` (or `true` if you have GUI)
     - `GUI_WINDOW_NAME`: `UrNetwork`
     - `AUTO_RESTART_INTERVAL`: `86400`
     - `ENABLE_IP_CHECKER`: `false`
4. Click **Run**

## Cách 2: Sử dụng Docker Compose (Khuyên dùng)

### Bước 1: Cập nhật docker-compose.yml

File `docker-compose.yml` đã được cấu hình sẵn. Chỉ cần chỉnh sửa:
- `USER_AUTH`: Email của bạn
- `PASSWORD`: Mật khẩu của bạn
- Các biến môi trường khác (optional)

### Bước 2: Chạy với Docker Desktop

#### Option A: Sử dụng Docker Desktop GUI

1. Mở Docker Desktop
2. Vào tab **Containers**
3. Click **Compose** hoặc nhấn `Ctrl + Shift + C`
4. Click **Open** và chọn file `docker-compose.yml`
5. Click **Start**

#### Option B: Sử dụng Terminal

1. Mở Terminal/PowerShell trong thư mục project
2. Chạy lệnh:
```bash
docker-compose up -d
```

### Bước 3: Xem logs

```bash
docker-compose logs -f
```

Hoặc trong Docker Desktop:
1. Vào tab **Containers**
2. Click vào container `urnetwork`
3. Xem tab **Logs**

## Cách 3: Sử dụng Docker CLI

### Bước 1: Login vào GitHub Packages (nếu cần)

```bash
docker login ghcr.io -u trungdungalpha
```

Nhập GitHub Personal Access Token khi được yêu cầu.

### Bước 2: Pull Image

```bash
docker pull ghcr.io/trungdungalpha/docker-urnetwork:latest
```

### Bước 3: Chạy Container

```bash
docker run -d \
  --name="urnetwork" \
  --restart="always" \
  --privileged \
  -e USER_AUTH="your-email@gmail.com" \
  -e PASSWORD="your-password" \
  -e ENABLE_GUI_CLOSE="false" \
  -e GUI_WINDOW_NAME="UrNetwork" \
  -e AUTO_RESTART_INTERVAL="86400" \
  -e ENABLE_IP_CHECKER="false" \
  -v vnstat_data:/var/lib/vnstat \
  -p 8080:8080 \
  ghcr.io/trungdungalpha/docker-urnetwork:latest
```

## Quản lý Container trong Docker Desktop

### Xem Container Status

1. Mở Docker Desktop
2. Vào tab **Containers**
3. Tìm container `urnetwork`
4. Xem status, CPU, Memory usage

### Xem Logs

1. Click vào container `urnetwork`
2. Vào tab **Logs**
3. Xem real-time logs

### Stop/Start/Restart Container

1. Click vào container `urnetwork`
2. Sử dụng các nút:
   - **Stop**: Dừng container
   - **Start**: Khởi động container
   - **Restart**: Khởi động lại container

### Xóa Container

1. Click vào container `urnetwork`
2. Click **Delete** (thùng rác)
3. Chọn **Delete container** hoặc **Delete container and volumes**

## Truy cập Stats Portal

Nếu đã mở port 8080:
- URL: http://localhost:8080/cgi-bin/stats
- Xem thống kê network usage

## Troubleshooting

### Lỗi: "unauthorized: authentication required"

**Giải pháp**: Login vào GitHub Packages:
```bash
docker login ghcr.io -u trungdungalpha
```

### Lỗi: "pull access denied"

**Giải pháp**: 
1. Kiểm tra image có public không
2. Nếu private, cần GitHub token với quyền `read:packages`
3. Login lại với token

### Lỗi: "Cannot connect to Docker daemon"

**Giải pháp**: 
1. Đảm bảo Docker Desktop đang chạy
2. Khởi động lại Docker Desktop
3. Kiểm tra Docker service trong Windows Services

### Container không chạy

**Giải pháp**:
1. Xem logs: `docker logs urnetwork`
2. Kiểm tra environment variables
3. Kiểm tra USER_AUTH và PASSWORD có đúng không

## Tips

1. **Auto-start**: Container sẽ tự động start khi Docker Desktop khởi động (với `restart: always`)

2. **Resource limits**: Có thể set CPU và Memory limits trong Docker Desktop:
   - Click container → Settings → Resources

3. **Volume persistence**: Data được lưu trong volume `vnstat_data`, không bị mất khi xóa container

4. **Multiple instances**: Có thể chạy nhiều container với các port khác nhau:
   ```yaml
   ports:
     - "8080:8080"  # Instance 1
     - "8081:8080"  # Instance 2
   ```

## Cấu hình nâng cao

### Thêm Proxy

Uncomment dòng volume trong `docker-compose.yml`:
```yaml
volumes:
  - /path/to/your/proxy.txt:/app/proxy.txt
```

### Enable GUI Close Feature

Chỉ enable nếu bạn có GUI environment (X11, VNC, etc.):
```yaml
environment:
  ENABLE_GUI_CLOSE: "true"
  GUI_WINDOW_NAME: "UrNetwork"
```

### Custom Auto-restart Interval

```yaml
environment:
  AUTO_RESTART_INTERVAL: "43200"  # 12 hours
```

## Liên kết hữu ích

- Docker Desktop Docs: https://docs.docker.com/desktop/
- GitHub Packages: https://github.com/trungdungalpha/Docker-UrNetwork/pkgs/container/docker-urnetwork
- Docker Compose Docs: https://docs.docker.com/compose/

