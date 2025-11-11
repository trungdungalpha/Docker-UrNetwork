# Hướng dẫn Git Commands - Commit và Push Code

## Cách 1: Sử dụng Git Bash hoặc Terminal (Khuyên dùng)

### Bước 1: Mở Git Bash hoặc Terminal
- Nhấn chuột phải vào thư mục `Docker-UrNetwork`
- Chọn "Git Bash Here" hoặc "Open in Terminal"

### Bước 2: Kiểm tra trạng thái
```bash
git status
```

### Bước 3: Thêm tất cả file đã thay đổi
```bash
git add .
```

### Bước 4: Commit với message
```bash
git commit -m "Add GUI close feature and GitHub Packages support"
```

### Bước 5: Push lên GitHub
```bash
git push origin main
```

## Cách 2: Sử dụng PowerShell (Windows)

### Mở PowerShell trong thư mục project:
1. Nhấn `Windows + R`
2. Gõ `powershell` và nhấn Enter
3. Navigate đến thư mục:
```powershell
cd "C:\Users\trung\OneDrive\Máy tính\Docker-UrNetwork"
```

### Chạy các lệnh Git:
```powershell
# Kiểm tra trạng thái
git status

# Thêm tất cả file
git add .

# Commit
git commit -m "Add GUI close feature and GitHub Packages support"

# Push
git push origin main
```

## Cách 3: Sử dụng Visual Studio Code

1. Mở VS Code trong thư mục `Docker-UrNetwork`
2. Mở Terminal trong VS Code (Ctrl + `)
3. Chạy các lệnh:
```bash
git add .
git commit -m "Add GUI close feature and GitHub Packages support"
git push origin main
```

## Cách 4: Sử dụng GitHub Desktop (GUI)

1. Mở GitHub Desktop
2. Chọn repository `Docker-UrNetwork`
3. Xem các file đã thay đổi ở panel bên trái
4. Nhập commit message: "Add GUI close feature and GitHub Packages support"
5. Click "Commit to main"
6. Click "Push origin" để push lên GitHub

## Troubleshooting

### Lỗi: "fatal: not a git repository"
**Giải pháp**: Cần khởi tạo git repository trước:
```bash
git init
git remote add origin https://github.com/trungdungalpha/Docker-UrNetwork.git
```

### Lỗi: "fatal: remote origin already exists"
**Giải pháp**: Kiểm tra remote hiện tại:
```bash
git remote -v
```

Nếu cần thay đổi:
```bash
git remote set-url origin https://github.com/trungdungalpha/Docker-UrNetwork.git
```

### Lỗi: "Permission denied (publickey)"
**Giải pháp**: Cần setup SSH key hoặc dùng HTTPS với token:
```bash
# Sử dụng HTTPS với token
git remote set-url origin https://YOUR_TOKEN@github.com/trungdungalpha/Docker-UrNetwork.git
```

### Lỗi: "Updates were rejected because the remote contains work"
**Giải pháp**: Cần pull trước khi push:
```bash
git pull origin main --rebase
git push origin main
```

### Lỗi: "Please tell me who you are"
**Giải pháp**: Cần config git user:
```bash
git config --global user.email "your-email@example.com"
git config --global user.name "Your Name"
```

## Kiểm tra sau khi push

1. Vào GitHub: https://github.com/trungdungalpha/Docker-UrNetwork
2. Kiểm tra các file đã được commit
3. Vào Actions: https://github.com/trungdungalpha/Docker-UrNetwork/actions
4. Xem workflow đang chạy build

## Quick Commands (Copy và paste)

```bash
git add .
git commit -m "Add GUI close feature and GitHub Packages support"
git push origin main
```

## Lưu ý

- Đảm bảo đã đăng nhập GitHub (nếu dùng HTTPS)
- Đảm bảo có quyền push vào repository
- Nếu repository là fork, cần push vào fork của bạn, không phải repository gốc


