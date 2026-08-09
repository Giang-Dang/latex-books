# Tone kỹ thuật

**Dùng khi nào:** README, tài liệu API, ADR, mô tả pull request, commit message dài, comment code,
runbook.

**Xưng hô:** không xưng. Chủ ngữ là hệ thống, lệnh, hoặc chính người đọc. Dùng "bạn" khi câu mô tả
thao tác người đọc phải làm. Không "mình", không "chúng ta", không "chúng tôi".

**Nhịp câu:** ngắn, khoảng 8 đến 20 chữ, một câu một ý. Các bước thao tác viết ở dạng mệnh lệnh
trực tiếp: "Chạy `npm ci` trước khi build."

**Thuật ngữ:** giữ nguyên tiếng Anh gần như toàn bộ. Không dịch tên lệnh, tên flag, tên biến môi
trường, tên file. Không dịch những từ mà người đọc sẽ gõ vào terminal.

## Dấu vết riêng của tone này

- **Viết như đang kể lại một thay đổi** thay vì mô tả thứ đang có: "Hàm này được thêm vào để thay
  thế cách làm cũ vốn chậm hơn." Tài liệu phải đọc hiểu được mà không cần biết commit trước đó là
  gì. Ngoại lệ: changelog, release note, migration guide vốn gắn với phiên bản.
- **Câu cụt bỏ chủ ngữ:** "Không cần file cấu hình." Viết đủ: "Bạn không cần file cấu hình."
- **Bullet mở đầu bằng `**Tiêu đề:**`** rồi lặp lại chính tiêu đề đó ở vế sau.
- **Tính từ tiếp thị trong tài liệu:** mạnh mẽ, linh hoạt, cực kỳ đơn giản, tối ưu, hiện đại.
  Tài liệu nói được gì làm được, không bán hàng.
- **Nhắc lại thứ môi trường đã tự nói.** Danh sách flag mà `--help` in ra, hay các script đã nằm
  trong `package.json`. Tài liệu nên giữ cái mà người đọc không tra được: lý do của một lựa chọn,
  quy ước bất thành văn, cái bẫy không config nào ghi.

## Trước và sau

**Trước:** Công cụ này cực kỳ mạnh mẽ và linh hoạt, được thiết kế nhằm mục đích giúp cho việc quản
lý cấu hình trở nên đơn giản hơn. Nó đọc các giá trị từ biến môi trường. Không cần file cấu hình.

**Sau:** Công cụ đọc cấu hình từ biến môi trường, nên bạn không cần file cấu hình.
