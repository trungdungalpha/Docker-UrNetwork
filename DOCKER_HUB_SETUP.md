# Hướng dẫn Setup Docker Hub

## Bước 1: Đăng ký tài khoản Docker Hub

1. Truy cập: https://hub.docker.com/
2. Click **Sign Up** để tạo tài khoản mới
3. Điền thông tin:
   - Username: (ví dụ: `trungdungalpha`)
   - Email: your-email@example.com
   - Password: (mật khẩu mạnh)
4. Xác nhận email
5. Đăng nhập vào Docker Hub

## Bước 2: Tạo Access Token

1. Đăng nhập vào Docker Hub
2. Click vào avatar (góc trên bên phải) → **Account Settings**
3. Vào **Security** → **New Access Token**
4. Đặt tên token: `github-actions` (hoặc tên khác)
5. Chọn quyền: **Read & Write** (hoặc **Read, Write & Delete**)
6. Click **Generate**
7. **LƯU LẠI TOKEN** (chỉ hiện 1 lần!)

## Bước 3: Tạo Repository trên Docker Hub

1. Vào Docker Hub: https://hub.docker.com/
2. Click **Create Repository**
3. Điền thông tin:
   - **Name**: `docker-urnetwork`
   - **Visibility**: Public (hoặc Private)
   - **Description**: Docker image for UrNetwork Provider with GUI close feature
4. Click **Create**

## Bước 4: Thêm Secrets vào GitHub

1. Vào GitHub repository: https://github.com/trungdungalpha/Docker-UrNetwork
2. Vào **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Thêm 2 secrets:

### Secret 1: DOCKER_HUB_USERNAME
- **Name**: `DOCKER_HUB_USERNAME`
- **Value**: Tên Docker Hub của bạn (ví dụ: `trungdungalpha`)
- Click **Add secret**

### Secret 2: DOCKER_HUB_TOKEN
- **Name**: `DOCKER_HUB_TOKEN`
- **Value**: Access token đã tạo ở Bước 2
- Click **Add secret**

## Bước 5: Kiểm tra Workflow

1. Vào **Actions** tab trong GitHub repository
2. Workflow sẽ tự động chạy khi:
   - Push code lên `main` branch
   - Hoặc trigger manual từ **Actions** → **Run workflow**
3. Kiểm tra logs để đảm bảo push thành công

## Bước 6: Xác nhận Image trên Docker Hub

1. Vào Docker Hub: https://hub.docker.com/r/YOUR_USERNAME/docker-urnetwork
2. Kiểm tra các tags:
   - `latest`
   - `sha-xxxxx` (commit SHA)
   - `YYYYMMDD` (date)
   - Version tags (nếu có)

## Sử dụng Image từ Docker Hub

### Pull Image
```bash
docker pull YOUR_USERNAME/docker-urnetwork:latest
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
  YOUR_USERNAME/docker-urnetwork:latest
```

### Sử dụng trong docker-compose.yml
```yaml
services:
  urnetwork:
    image: YOUR_USERNAME/docker-urnetwork:latest
    # ... rest of config
```

## Troubleshooting

### Lỗi: "unauthorized: authentication required"
**Giải pháp**: 
- Kiểm tra DOCKER_HUB_USERNAME và DOCKER_HUB_TOKEN có đúng không
- Đảm bảo token có quyền Read & Write
- Kiểm tra repository name có đúng không

### Lỗi: "repository name must be lowercase"
**Giải pháp**: 
- Repository name phải viết thường
- Không được có ký tự đặc biệt (trừ `-` và `_`)

### Lỗi: "denied: requested access to the resource is denied"
**Giải pháp**: 
- Kiểm tra token có quyền push không
- Kiểm tra repository có tồn tại không
- Kiểm tra username có đúng không

### Image không xuất hiện trên Docker Hub
**Giải pháp**: 
- Đợi vài phút để Docker Hub sync
- Kiểm tra workflow logs trong GitHub Actions
- Kiểm tra repository visibility (Public/Private)

## Lưu ý

1. **Token Security**: 
   - Không chia sẻ token với ai
   - Rotate token định kỳ (mỗi 90 ngày)
   - Sử dụng token có scope tối thiểu cần thiết

2. **Repository Naming**:
   - Tên repository phải unique trong Docker Hub
   - Nếu tên đã tồn tại, cần đổi tên hoặc dùng namespace

3. **Rate Limits**:
   - Free tier: 200 pulls/6 hours, 100 pushes/day
   - Pro tier: Unlimited pulls, 5000 pushes/day

4. **Image Size**:
   - Giữ image size nhỏ để tải nhanh
   - Sử dụng multi-stage builds
   - Xóa các layer không cần thiết

## Liên kết hữu ích

- Docker Hub: https://hub.docker.com/
- Docker Hub Docs: https://docs.docker.com/docker-hub/
- GitHub Actions Docker Login: https://github.com/docker/login-action
- Access Tokens: https://docs.docker.com/docker-hub/access-tokens/

