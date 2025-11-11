# Hướng dẫn Build và Push Docker Image lên GitHub Packages

## Tự động Build và Push (Khuyên dùng)

### Cách 1: Push code lên GitHub
1. Commit và push code lên branch `main`:
```bash
git add .
git commit -m "Add GUI close feature for UrNetwork"
git push origin main
```

2. GitHub Actions sẽ tự động:
   - Build Docker image với platform `linux/amd64` và `linux/arm64`
   - Push lên GitHub Packages tại: `ghcr.io/trungdungalpha/docker-urnetwork`

3. Xem kết quả tại:
   - Actions: https://github.com/trungdungalpha/Docker-UrNetwork/actions
   - Packages: https://github.com/trungdungalpha/Docker-UrNetwork/pkgs/container/docker-urnetwork

### Cách 2: Manual trigger
1. Vào trang GitHub Actions
2. Chọn workflow "Build and Push to GitHub Packages"
3. Click "Run workflow" → "Run workflow"

## Pull và sử dụng Image

### 1. Login vào GitHub Container Registry
```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u trungdungalpha --password-stdin
```

Hoặc nếu chưa có token:
1. Tạo Personal Access Token (PAT) tại: https://github.com/settings/tokens
2. Chọn scope: `read:packages`, `write:packages`
3. Login:
```bash
docker login ghcr.io -u trungdungalpha -p YOUR_TOKEN
```

### 2. Pull image
```bash
docker pull ghcr.io/trungdungalpha/docker-urnetwork:latest
```

### 3. Chạy container
```bash
docker run -d \
  --name="urnetwork" \
  --restart="always" \
  --privileged \
  -e USER_AUTH="your-email@gmail.com" \
  -e PASSWORD="your-password" \
  -e ENABLE_GUI_CLOSE="true" \
  -e GUI_WINDOW_NAME="UrNetwork" \
  -e AUTO_RESTART_INTERVAL="86400" \
  ghcr.io/trungdungalpha/docker-urnetwork:latest
```

## Build local (Tùy chọn)

### Build cho một platform
```bash
docker build -t ghcr.io/trungdungalpha/docker-urnetwork:latest .
```

### Build cho nhiều platforms (cần Docker Buildx)
```bash
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 \
  -t ghcr.io/trungdungalpha/docker-urnetwork:latest \
  --push .
```

## Cấu hình môi trường mới

### Biến môi trường mới:
- `ENABLE_GUI_CLOSE`: Bật/tắt tính năng đóng GUI (mặc định: `false`)
- `GUI_WINDOW_NAME`: Tên cửa sổ GUI cần đóng (mặc định: `UrNetwork`)
- `AUTO_RESTART_INTERVAL`: Khoảng thời gian auto-restart (giây, mặc định: `86400` = 24h)

### Ví dụ docker-compose.yml:
```yaml
services:
  urnetwork:
    image: ghcr.io/trungdungalpha/docker-urnetwork:latest
    container_name: urnetwork
    platform: linux/amd64
    restart: always
    privileged: true
    environment:
      USER_AUTH: "your-email@gmail.com"
      PASSWORD: "your-password"
      ENABLE_GUI_CLOSE: "true"
      GUI_WINDOW_NAME: "UrNetwork"
      AUTO_RESTART_INTERVAL: "86400"
      ENABLE_IP_CHECKER: "true"
    volumes:
      - vnstat_data:/var/lib/vnstat
    ports:
      - "8080:8080"

volumes:
  vnstat_data:
```

## Lưu ý

1. **Permissions**: Đảm bảo repository có permissions để push packages:
   - Vào Settings → Actions → General → Workflow permissions
   - Chọn "Read and write permissions"
   - Check "Allow GitHub Actions to create and approve pull requests"

2. **Package visibility**: 
   - Public packages: Ai cũng có thể pull
   - Private packages: Chỉ owner và collaborators có thể pull

3. **Xóa package cũ**: Nếu cần xóa package cũ để tiết kiệm dung lượng:
   - Vào https://github.com/trungdungalpha/Docker-UrNetwork/pkgs/container/docker-urnetwork
   - Chọn package version → Delete

## Troubleshooting

### Lỗi: "unauthorized: authentication required"
- Kiểm tra GITHUB_TOKEN có đúng permissions không
- Đảm bảo đã login vào ghcr.io

### Lỗi: "permission denied"
- Kiểm tra workflow permissions trong repository settings
- Đảm bảo có quyền `packages: write`

### Image không được push
- Kiểm tra GitHub Actions logs
- Đảm bảo workflow không bị skip (kiểm tra conditions)


