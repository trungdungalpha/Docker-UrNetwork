# 🔍 Troubleshooting - Image chưa xuất hiện trên Docker Hub

## ✅ Checklist kiểm tra:

### 1. Repository đã được tạo trên Docker Hub chưa?

**Kiểm tra:**
- Vào: https://hub.docker.com/repositories
- Tìm repository `docker-urnetwork`
- Nếu chưa có → Tạo ngay:
  1. Click **"Create Repository"**
  2. Name: `docker-urnetwork`
  3. Visibility: Public
  4. Click **"Create"**

### 2. Workflow có chạy không?

**Kiểm tra:**
- Vào: https://github.com/trungdungalpha/Docker-UrNetwork/actions
- Xem workflow **"Build and Push to GitHub Packages"** có chạy không
- Nếu chưa chạy → Trigger manual:
  1. Click vào workflow
  2. Click **"Run workflow"**
  3. Chọn branch: **main**
  4. Click **"Run workflow"**

### 3. Workflow có push lên Docker Hub không?

**Kiểm tra logs:**
1. Vào workflow run
2. Xem step **"Log in to Docker Hub"**:
   - ✅ Thành công: "Login Succeeded"
   - ❌ Lỗi: "unauthorized" → Kiểm tra secrets
3. Xem step **"Build and push Docker image"**:
   - ✅ Có tags Docker Hub trong output
   - ❌ Không có → Secrets chưa được cấu hình

### 4. Secrets có đúng không?

**Kiểm tra:**
- Vào: https://github.com/trungdungalpha/Docker-UrNetwork/settings/secrets/actions
- Phải có 2 secrets:
  - ✅ `DOCKER_HUB_USERNAME` = `kingofmmo`
  - ✅ `DOCKER_HUB_TOKEN` = (token của bạn)

## 🚀 Giải pháp nhanh:

### Cách 1: Trigger Workflow Manual (Khuyên dùng)

1. Vào: https://github.com/trungdungalpha/Docker-UrNetwork/actions
2. Chọn workflow **"Build and Push to GitHub Packages"**
3. Click **"Run workflow"** (góc trên bên phải)
4. Chọn branch: **main**
5. Click **"Run workflow"** (nút xanh)
6. Đợi 5-10 phút
7. Kiểm tra lại Docker Hub

### Cách 2: Push một file nhỏ để trigger workflow

```bash
# Tạo file test để trigger workflow
echo "# Test" >> test.txt
git add test.txt
git commit -m "Trigger workflow"
git push origin main
```

Sau đó xóa file test.txt:
```bash
git rm test.txt
git commit -m "Remove test file"
git push origin main
```

### Cách 3: Sửa workflow để luôn chạy

Sửa file `.github/workflows/build-push.yml`, bỏ phần `paths`:

```yaml
on:
  push:
    branches:
      - main
  # Bỏ phần paths để workflow chạy mỗi khi push
  workflow_dispatch:
```

## 🔍 Debug Workflow Logs

### Xem logs chi tiết:

1. Vào: https://github.com/trungdungalpha/Docker-UrNetwork/actions
2. Click vào workflow run mới nhất
3. Xem từng step:

#### Step "Log in to Docker Hub":
- ✅ Thành công: "Login Succeeded"
- ❌ Lỗi: Xem error message

#### Step "Prepare all tags":
- ✅ Output phải có: `kingofmmo/docker-urnetwork:latest`
- ❌ Nếu không có → Secrets chưa được set

#### Step "Build and push Docker image":
- ✅ Xem "Pushing" logs
- ✅ Kiểm tra có push lên Docker Hub không

## ⚠️ Lỗi thường gặp:

### Lỗi: "unauthorized: authentication required"
**Nguyên nhân**: Token hoặc username sai
**Giải pháp**: 
- Kiểm tra lại secrets
- Tạo token mới trên Docker Hub
- Cập nhật secret `DOCKER_HUB_TOKEN`

### Lỗi: "repository name must be lowercase"
**Nguyên nhân**: Repository name có chữ hoa
**Giải pháp**: 
- Repository phải là: `docker-urnetwork` (chữ thường)
- Không được có ký tự đặc biệt

### Lỗi: "denied: requested access to the resource is denied"
**Nguyên nhân**: 
- Repository chưa được tạo
- Token không có quyền push
**Giải pháp**: 
- Tạo repository trên Docker Hub
- Kiểm tra token có quyền Read & Write

### Workflow không chạy
**Nguyên nhân**: 
- Workflow `build-push.yml` chỉ chạy khi thay đổi file cụ thể
- Hoặc workflow bị disable
**Giải pháp**: 
- Trigger manual workflow
- Hoặc sửa file trong `paths` để trigger

## 📋 Quick Fix Checklist:

- [ ] Repository `docker-urnetwork` đã được tạo trên Docker Hub
- [ ] Secrets `DOCKER_HUB_USERNAME` và `DOCKER_HUB_TOKEN` đã được thêm vào GitHub
- [ ] Workflow đã được trigger (manual hoặc tự động)
- [ ] Workflow logs không có lỗi
- [ ] Đợi 5-10 phút sau khi workflow hoàn thành
- [ ] Refresh trang Docker Hub

## 🔗 Liên kết:

- **Docker Hub**: https://hub.docker.com/r/kingofmmo/docker-urnetwork
- **GitHub Actions**: https://github.com/trungdungalpha/Docker-UrNetwork/actions
- **GitHub Secrets**: https://github.com/trungdungalpha/Docker-UrNetwork/settings/secrets/actions

---

**Sau khi kiểm tra và trigger workflow, image sẽ xuất hiện trên Docker Hub trong 5-10 phút! 🚀**

