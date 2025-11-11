# 🚀 Quick Start - Docker Hub Setup

## ✅ Đã có thông tin đăng nhập
- **Username**: `kingofmmo`
- **Token**: Đã được cấu hình
- **Login Status**: ✅ Đã login thành công

## 📋 Checklist - Làm theo thứ tự:

### ✅ Bước 1: Tạo Repository trên Docker Hub

1. Truy cập: https://hub.docker.com/repositories
2. Click **Create Repository** (nút xanh)
3. Điền thông tin:
   ```
   Name: docker-urnetwork
   Visibility: Public (khuyên dùng)
   Description: Docker image for UrNetwork Provider with GUI close feature
   ```
4. Click **Create**

### ✅ Bước 2: Thêm Secrets vào GitHub

**QUAN TRỌNG**: Phải làm bước này để workflow tự động push!

1. Truy cập: https://github.com/trungdungalpha/Docker-UrNetwork/settings/secrets/actions

2. Thêm Secret 1:
   - Click **New repository secret**
   - **Name**: `DOCKER_HUB_USERNAME`
   - **Secret**: `kingofmmo`
   - Click **Add secret**

3. Thêm Secret 2:
   - Click **New repository secret**
   - **Name**: `DOCKER_HUB_TOKEN`
   - **Secret**: `YOUR_DOCKER_HUB_TOKEN` (thay bằng token thật của bạn)
   - Click **Add secret**

### ✅ Bước 3: Kiểm tra Secrets

Vào lại: https://github.com/trungdungalpha/Docker-UrNetwork/settings/secrets/actions

Bạn sẽ thấy:
- ✅ DOCKER_HUB_USERNAME
- ✅ DOCKER_HUB_TOKEN

### ✅ Bước 4: Trigger Workflow

Sau khi thêm secrets, có 2 cách:

#### Cách 1: Push code (nếu chưa push)
```bash
git add .
git commit -m "Add Docker Hub support"
git push origin main
```

#### Cách 2: Manual trigger
1. Vào: https://github.com/trungdungalpha/Docker-UrNetwork/actions
2. Chọn workflow "Build and Push to GitHub Packages"
3. Click **Run workflow** → **Run workflow**

### ✅ Bước 5: Xác nhận Image

Sau khi workflow chạy xong (5-10 phút):

1. **GitHub Packages**: 
   - https://github.com/trungdungalpha/Docker-UrNetwork/pkgs/container/docker-urnetwork

2. **Docker Hub**:
   - https://hub.docker.com/r/kingofmmo/docker-urnetwork
   - Kiểm tra các tags: `latest`, `sha-xxxxx`, `YYYYMMDD`

## 🎯 Sử dụng Image

### Pull từ Docker Hub
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
  kingofmmo/docker-urnetwork:latest
```

### Sử dụng docker-compose.yml
```yaml
services:
  urnetwork:
    image: kingofmmo/docker-urnetwork:latest
    # ... rest of config
```

## 🔒 Bảo mật

⚠️ **Lưu ý quan trọng**:
- Token đã được chia sẻ - nên rotate sau khi setup
- Không commit token vào code
- Token chỉ nên ở trong GitHub Secrets
- Rotate token định kỳ (mỗi 90 ngày)

## 🐛 Troubleshooting

### Workflow không push lên Docker Hub
- ✅ Kiểm tra secrets đã được thêm chưa
- ✅ Kiểm tra repository đã được tạo trên Docker Hub chưa
- ✅ Kiểm tra workflow logs trong GitHub Actions

### Lỗi: "unauthorized"
- ✅ Kiểm tra token có đúng không
- ✅ Kiểm tra token có quyền Read & Write không

### Image không xuất hiện
- ✅ Đợi vài phút để Docker Hub sync
- ✅ Kiểm tra repository visibility (Public/Private)

## 📞 Liên kết nhanh

- **Docker Hub**: https://hub.docker.com/r/kingofmmo/docker-urnetwork
- **GitHub Secrets**: https://github.com/trungdungalpha/Docker-UrNetwork/settings/secrets/actions
- **GitHub Actions**: https://github.com/trungdungalpha/Docker-UrNetwork/actions
- **GitHub Packages**: https://github.com/trungdungalpha/Docker-UrNetwork/pkgs/container/docker-urnetwork

## ✅ Kết quả mong đợi

Sau khi hoàn thành, mỗi lần push code sẽ tự động:
1. ✅ Build Docker image (amd64 + arm64)
2. ✅ Push lên GitHub Packages
3. ✅ Push lên Docker Hub (kingofmmo/docker-urnetwork)
4. ✅ Tag với: `latest`, `sha-xxxxx`, `YYYYMMDD`

---

**Chúc bạn thành công! 🎉**

