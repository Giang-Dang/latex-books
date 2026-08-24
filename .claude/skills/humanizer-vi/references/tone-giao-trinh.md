# Tone giáo trình

**Dùng khi nào:** giáo trình, chuyên khảo học thuật: định nghĩa, lý thuyết, chứng minh, bài tập
kèm lời giải mẫu.

**Xưng hô:** ngôi thứ ba cho đối tượng trình bày. "Ta" hoặc "chúng ta" chỉ dùng theo nghĩa trình
bày ("ta xét...", "chúng ta chứng minh..."), nghĩa là tác giả và người đọc cùng làm việc, không
bao giờ là tiểu sử tác giả.

**Nhịp câu:** đều và không vội là đúng chuẩn; đây là tone sách duy nhất mà nhịp ổn định là ưu
điểm. Độ phức tạp dồn vào độ chính xác, không dồn vào mệnh đề lồng nhau.

**Liên kết:** nhịp đều của tone này dựa trên phép nối, không dựa trên phép đặt cạnh. Mỗi mục
mở bằng một câu móc vào kết luận của mục trước ("Mục trước đã cho thấy...", "Như vậy...",
"Nếu vậy thì..."); trong đoạn, câu sau bám câu trước bằng quan hệ từ, phép thế có tiền ngữ rõ,
hoặc phép lặp chủ đề. Kho từ nối của chuyên khảo tiếng Việt: như vậy, nói cách khác, trước
hết, do đó, chú ý rằng, ta thấy - mỗi chỗ chuyển một từ là đủ. Độ cô đọng `vừa` cắt đoạn dạo
đầu chứ không cắt câu chuyển: một câu nối hai mục là mạch lập luận, không phải chỗ thừa.

**Độ cô đọng:** `vừa`. Một suy diễn phải trình đủ từng bước, và một bước không phải là chỗ thừa.
Cái vẫn bị cắt là phần văn xuôi quanh phần toán: đoạn báo trước sắp có định lý, và đoạn tổng kết
mục này vừa chứng minh xong cái gì. Xem phần Độ cô đọng trong `SKILL.md`.

**Thuật ngữ:** định nghĩa trước khi dùng, rồi một tên cho một khái niệm đến hết sách. Xoay vòng
từ đồng nghĩa (nhóm G) phá tone này nặng hơn mọi lỗi khác: người mới đọc "mô hình", "mạng" và
"kiến trúc" thành ba thứ khác nhau. Sách có đánh số định nghĩa, định lý thì về sau trích theo số.

## Dấu vết riêng của tone này

- **Tâng bốc ngành** (nhóm A): "Machine learning đã cách mạng hóa...", "đóng vai trò then chốt
  trong thời đại số". Giáo trình mặc định người đọc đã ngồi trong phòng.
- **Chuyện nghề chen giữa chứng minh.** Chuyện đó thuộc tone chương sách hoặc một sidebar được
  đánh dấu riêng; phần chính giữ giọng khách quan.
- **Hạ thấp độ khó:** "dễ thấy rằng", "hiển nhiên", "chứng minh rất đơn giản". Nếu đơn giản thật
  thì câu đó không cần viết ra.
- **Đồng thuận không nguồn:** "được chấp nhận rộng rãi rằng". Trích nguồn hoặc chứng minh.
- **Dấu hiệu phấn khích:** dấu chấm than, "đáng kinh ngạc", "tuyệt đẹp". Kết quả tự nó nói được.
- **Chuỗi câu cụt đặt cạnh nhau** không quan hệ từ, và mảnh câu không động từ kiểu punchline
  dịch từ tiếng Anh ("Cùng một đầu vào, ba kết luận khác nhau."). Nối các ý đó lại thành câu
  có quan hệ từ; xem mục Liên kết ở trên.
- **Calque cấu trúc tiếng Anh:** "Đó là nơi... xuất hiện", "thành công trước người đọc", chữ
  "một" dịch mạo từ trong câu định nghĩa, thiếu "là" sau "không phải". Đọc thầm thành tiếng:
  câu phải đọc hai lần là câu cần viết lại.
- **Quy chiếu không tiền ngữ:** "điều này", "khái niệm ấy", "phần tiếp theo" mà người đọc
  không chỉ ra được đích. Tham chiếu tới chỗ khác trong sách nêu đích tường minh: phần,
  chương hay mục nào.

## Trước và sau

**Trước:** Gradient descent là một thuật toán thực sự đáng kinh ngạc, đóng vai trò then chốt
trong bức tranh deep learning hiện đại. Dễ thấy rằng nó hội tụ. Chỉ cần đi theo hướng ngược
gradient!

**Sau:** Gradient descent cập nhật tham số theo hướng ngược gradient của hàm mất mát. Với giả
thiết lồi ở mục 3.2, định lý 3.4 cho thấy dãy lặp hội tụ về cực tiểu toàn cục.

Và một cặp về liên kết:

**Trước:** Mô hình giả định dữ liệu sạch. Dữ liệu thực tế có nhiễu. Tiền xử lý là một bước
quan trọng. Chuẩn hóa đưa các đặc trưng về cùng thang đo.

**Sau:** Mô hình giả định dữ liệu sạch, trong khi dữ liệu thực tế có nhiễu, nên trước khi
huấn luyện ta phải tiền xử lý. Trước hết, chuẩn hóa đưa các đặc trưng về cùng thang đo.
