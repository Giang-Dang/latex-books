# Tone thực hành

**Dùng khi nào:** lab cuối chương, bài làm theo từng bước trong sách, công thức kiểu cookbook,
mọi phần sách mà người đọc làm chứ không chỉ đọc.

**Xưng hô:** "bạn" làm chủ ngữ của mọi thao tác, câu mệnh lệnh. "Tôi" chỉ xuất hiện khi đánh dấu
một lựa chọn mà người đọc có thể quyết khác đi.

**Nhịp câu:** ngắn. Một thao tác một bước, một bước một đoạn hoặc một mục danh sách. Văn xuôi
giữa các bước chỉ khi người đọc phải hiểu điều gì đó trước khi thao tác.

**Thuật ngữ:** lệnh, đường dẫn, tag, flag ghi nguyên văn, kèm kết quả kỳ vọng sau bước nào mà
thành công không tự hiển nhiên. Khai báo trạng thái xuất phát trước bước một: checkout tag nào,
đứng ở thư mục nào, dịch vụ nào phải đang chạy sẵn. Lab xuất phát từ trạng thái không khai báo
sẽ chết ở bước ba trên máy của người khác.

## Dấu vết riêng của tone này

- **Hạ thấp độ khó:** "rất đơn giản", "chỉ cần", "chỉ với vài dòng lệnh". Người đọc kẹt đúng
  bước đó sẽ nghĩ lỗi ở mình.
- **Bị động trong hướng dẫn** (nhóm D): "Container sẽ được khởi động." Nói ai khởi động và người
  đọc phải thấy gì khi nó chạy đúng.
- **Bước không có gì để kiểm.** Vài bước một lần, đưa người đọc thứ để soi: dòng output, file
  vừa xuất hiện, con số vừa đổi. Điểm kiểm tra là thứ phân biệt lab với một bản liệt kê lệnh.
- **Chỉ có đường sướng.** Nêu lỗi hay gặp ngay tại bước nó cắn ("nếu port đã bị chiếm thì...")
  thay vì dồn hết vào mục FAQ cuối bài.
- **Kết bằng "Chúc mừng bạn!"** (nhóm I). Dừng ở cái người đọc vừa có trong tay và nơi cuốn sách
  dùng nó tiếp.

## Trước và sau

**Trước:** Rất đơn giản, chỉ cần chạy script setup là môi trường sẽ được cấu hình. Tiếp theo,
chỉ cần khởi động server. Chúc mừng, bạn đã có một hệ thống hoạt động!

**Sau:** Từ thư mục gốc của repo, chạy `./setup.ps1`. Script ghi file `.env` và khởi động
Postgres; `docker ps` phải hiện một container tên `db`. Sau đó chạy `npm run dev` và mở
http://localhost:3000. Trang trắng nghĩa là bước seed hỏng; chạy lại bằng `./setup.ps1 -Reseed`.
