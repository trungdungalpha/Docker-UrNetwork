# Quick Setup Docker Hub - Đã có thông tin đăng nhập

## Thông tin Docker Hub
- **Username**: `kingofmmo`
- **Token**: `YOUR_DOCKER_HUB_TOKEN` ⚠️ (Thay bằng token thật của bạn)

## Bước 1: Tạo Repository trên Docker Hub

1. Truy cập: https://hub.docker.com/repositories
2. Click **Create Repository**
3. Điền thông tin:
   - **Name**: `docker-urnetwork`
   - **Visibility**: Public (khuyên dùng) hoặc Private
   - **Description**: Docker image for UrNetwork Provider with GUI close feature
4. Click **Create**

## Bước 2: Thêm Secrets vào GitHub

### Cách 1: Qua GitHub Web UI (Khuyên dùng)

1. Truy cập: https://github.com/trungdungalpha/Docker-UrNetwork/settings/secrets/actions
2. Click **New repository secret**

#### Secret 1: DOCKER_HUB_USERNAME
- **Name**: `DOCKER_HUB_USERNAME`
- **Value**: `kingofmmo`
- Click **Add secret**

#### Secret 2: DOCKER_HUB_TOKEN
- **Name**: `DOCKER_HUB_TOKEN`
- **Value**: `YOUR_DOCKER_HUB_TOKEN` (thay bằng token thật của bạn)
- Click **Add secret**

### Cách 2: Qua GitHub CLI (Nếu có)

```bash
gh secret set DOCKER_HUB_USERNAME --body "kingofmmo"
gh secret set DOCKER_HUB_TOKEN --body "YOUR_DOCKER_HUB_TOKEN"
```

## Bước 3: Kiểm tra Secrets

1. Vào: https://github.com/trungdungalpha/Docker-UrNetwork/settings/secrets/actions
2. Xác nhận có 2 secrets:
   - ✅ DOCKER_HUB_USERNAME
   - ✅ DOCKER_HUB_TOKEN

## Bước 4: Test Workflow

1. Push code lên GitHub (nếu chưa push)
2. Vào **Actions** tab
3. Workflow sẽ tự động chạy và push lên cả GitHub Packages và Docker Hub
4. Kiểm tra logs để đảm bảo push thành công

## Bước 5: Xác nhận Image trên Docker Hub

1. Truy cập: https://hub.docker.com/r/kingofmmo/docker-urnetwork
2. Kiểm tra các tags:
   - `latest`
   - `sha-xxxxx` (commit SHA)
   - `YYYYMMDD` (date)

## Sử dụng Image từ Docker Hub

### Pull Image
```bash
docker pull kingofmmo/docker-urnetwork:latest
```

### Chạy Container
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
  kingofmmo/docker-urnetwork:latest
```

### Sử dụng trong docker-compose.yml
```yaml
services:
  urnetwork:
    image: kingofmmo/docker-urnetwork:latest
    # ... rest of config
```

## Lưu ý bảo mật

⚠️ **QUAN TRỌNG**: 
- Token đã được chia sẻ - nên rotate token sau khi setup xong
- Không commit token vào code
- Chỉ sử dụng token trong GitHub Secrets
- Rotate token định kỳ (mỗi 90 ngày)

## Troubleshooting

### Lỗi: "unauthorized: authentication required"
- Kiểm tra DOCKER_HUB_USERNAME và DOCKER_HUB_TOKEN có đúng không
- Đảm bảo token có quyền Read & Write
- Kiểm tra repository đã được tạo trên Docker Hub chưa

### Lỗi: "repository name must be lowercase"
- Repository name phải viết thường: `docker-urnetwork`
- Không được có ký tự đặc biệt (trừ `-` và `_`)

### Image không xuất hiện trên Docker Hub
- Đợi vài phút để Docker Hub sync
- Kiểm tra workflow logs trong GitHub Actions
- Kiểm tra repository visibility (Public/Private)

## Liên kết

- Docker Hub Repository: https://hub.docker.com/r/kingofmmo/docker-urnetwork
- GitHub Secrets: https://github.com/trungdungalpha/Docker-UrNetwork/settings/secrets/actions
- GitHub Actions: https://github.com/trungdungalpha/Docker-UrNetwork/actions

