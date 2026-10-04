# Finding Paradise - Port cho ArkOS / R36S (PortMaster)

Bản port game **Finding Paradise (To the Moon 2)** dành cho các thiết bị máy chơi game cầm tay chạy **ArkOS** (như R36S, Anbernic RK3326).

## Đặc điểm bản Port
- Sử dụng engine **falcon_mkxp** tối ưu cho ARM64.
- **Việt Hóa 100%**: Tích hợp bộ font tiếng Việt chuẩn (`Open Sans`, `Arial`, `Times`, `Tahoma`), hiển thị đầy đủ dấu tiếng Việt.
- **Đã fix triệt để lỗi phím & tay cầm**:
  - Khắc phục cơ chế hook `GetAsyncKeyState` trong `preload/win32_wrap.rb`, tương thích hoàn hảo với custom keyboard script (Section 102 Poccil) và mouse script của Finding Paradise.
  - Hỗ trợ đầy đủ cả tay cầm (D-pad/Nút bấm) và chuột (Analog phải + R1/L1).
- **Tối ưu hiệu năng**:
  - Cấu hình `mkxp.conf` chuẩn (`frameSkip=false`, `subImageFix=false`) giúp game vận hành trơn tru ở 40 FPS.
  - Tự động kích hoạt Governor CPU/GPU `performance`.

## Cài đặt trên ArkOS (R36S)
1. Chép file `Finding Paradise.sh` vào thư mục `/roms/ports/` (hoặc `/roms2/ports/`).
2. Chép toàn bộ thư mục `finding_paradise/` vào `/roms/ports/finding_paradise/`.
3. Khởi động lại EmulationStation hoặc vào mục **Ports** để chọn và chơi game.

## Điều khiển (Controls)
- **D-Pad / Cần Analog trái**: Di chuyển nhân vật / Chọn menu
- **Cần Analog phải**: Di chuyển con trỏ chuột
- **Nút A**: Tương tác / Đồng ý (`Enter` / `Input::C`)
- **Nút B**: Hủy / Menu (`Esc` / `Input::B`)
- **Nút X**: Chạy nhanh (`Shift` / `Input::A`)
- **Nút Y**: Giảm tốc độ chuột
- **Nút R1**: Chuột trái (Click chuột)
- **Nút L1**: Chuột phải
- **Nút L2 / R2**: Đổi trang menu (`Q` / `W`)
- **Start**: `Enter`
- **Select + Start**: Thoát game
