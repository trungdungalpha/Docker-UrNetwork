# Khắc phục vấn đề vnstatd chiếm CPU cao

## Vấn đề
`vnstatd` là daemon theo dõi thống kê băng thông mạng, được sử dụng để hiển thị stats tại `http://localhost:8080/cgi-bin/stats`. Khi có nhiều process `vnstatd` chạy đồng thời, chúng sẽ chiếm rất nhiều CPU (mỗi process 6-10%, tổng cộng có thể lên 100%).

## Nguyên nhân
1. **Container restart nhiều lần**: Mỗi lần container restart, một process `vnstatd` mới được tạo nhưng process cũ không được cleanup đúng cách
2. **Nhiều container đang chạy**: Mỗi container có 1 process `vnstatd`, nếu có nhiều container thì sẽ có nhiều process
3. **Process không được kiểm tra trước khi start**: Script không kiểm tra xem process đã chạy chưa trước khi start mới

## Giải pháp đã áp dụng
Đã cập nhật `entrypoint.sh` để:
- Kiểm tra và kill các process `vnstatd` cũ trước khi start mới
- Chỉ start `vnstatd` nếu process chưa chạy
- Tránh duplicate processes

## Kiểm tra và khắc phục trên hệ thống hiện tại

### Bước 1: Kiểm tra số lượng process vnstatd
```bash
# Trong container
pgrep -a vnstatd

# Hoặc từ host (nếu có quyền)
docker exec urnetwork pgrep -a vnstatd
```

### Bước 2: Kiểm tra số lượng container đang chạy
```bash
docker ps | grep urnetwork
```

### Bước 3: Kill các process vnstatd dư thừa (trong container)
```bash
# Kill tất cả process vnstatd (trong container)
docker exec urnetwork pkill -x vnstatd

# Hoặc kill từng process cụ thể
docker exec urnetwork kill <PID>
```

### Bước 4: Restart container để áp dụng fix
```bash
# Restart container
docker restart urnetwork

# Hoặc rebuild và restart
docker-compose down
docker-compose up -d
```

### Bước 5: Kiểm tra lại
```bash
# Kiểm tra số lượng process vnstatd (chỉ nên có 1)
docker exec urnetwork pgrep -a vnstatd

# Kiểm tra CPU usage
docker stats urnetwork
```

## ✅ Đã tắt vnstatd (CPU optimization)

**vnstatd đã được tắt hoàn toàn trong entrypoint.sh** để giảm CPU usage. Stats portal (`http://localhost:8080/cgi-bin/stats`) sẽ không hoạt động.

### Nếu muốn bật lại vnstatd:
1. Uncomment các dòng trong `entrypoint.sh` (dòng 260-284)
2. Rebuild image và restart container

### Lưu ý:
- Port 8080 không còn cần thiết nếu không dùng stats portal
- Có thể xóa port mapping `8080:8080` trong docker-compose.yml
- Volume `vnstat_data` không còn cần thiết

## Tối ưu hóa vnstatd (giảm CPU usage)

Có thể tăng interval để giảm CPU usage trong `Dockerfile`:

```dockerfile
RUN sed -i \
  -e 's/^;*UpdateInterval.*/UpdateInterval 60/' \    # Tăng từ 15s lên 60s
  -e 's/^;*PollInterval.*/PollInterval 60/' \        # Tăng từ 15s lên 60s
  /etc/vnstat.conf
```

**Lưu ý**: Tăng interval sẽ làm giảm độ chính xác của stats, nhưng sẽ giảm CPU usage.

## Kiểm tra logs

```bash
# Xem logs của container
docker logs urnetwork | grep vnstatd

# Xem logs real-time
docker logs -f urnetwork | grep vnstatd
```

## Sau khi áp dụng fix

Sau khi rebuild image với fix mới:
1. Mỗi container chỉ nên có **1 process vnstatd**
2. CPU usage của `vnstatd` nên ở mức **< 1%** (thay vì 6-10% mỗi process)
3. Nếu có nhiều container, mỗi container có 1 process là bình thường

## Liên quan
- `vnstatd` được cài đặt trong `Dockerfile` (line 8)
- Được khởi động trong `entrypoint.sh` (line 268-280)
- Stats portal: `http://localhost:8080/cgi-bin/stats`
- Config file: `/etc/vnstat.conf`

