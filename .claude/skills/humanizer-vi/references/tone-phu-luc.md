# Tone phụ lục

**Dùng khi nào:** phụ lục, mục tra cứu, bảng thuật ngữ, ma trận phiên bản và tương thích, bảng
liệt kê option và flag, bảng quyết định.

**Xưng hô:** không xưng hô. Không "tôi", không "chúng ta". "Bạn" chỉ nằm trong câu hướng dẫn mà
một mục chứa.

**Nhịp câu:** mục, không phải đoạn văn. Cấu trúc song song giữa các mục: mục đầu có hình dạng
nào (thuật ngữ, một câu định nghĩa, ví dụ) thì mọi mục có đúng hình dạng đó. Người đọc rơi vào
đây từ index, đọc một mục rồi đi.

**Thuật ngữ:** chính xác và đầy đủ: tên lệnh đầy đủ, cú pháp option đầy đủ, đơn vị cho mọi con
số. Từ ba mục cùng hình dạng trở lên thì bảng thắng văn xuôi.

## Dấu vết riêng của tone này

- **Câu chuyển kiểu kể chuyện giữa các mục:** "Sau khi đã xem xong X, giờ ta chuyển sang Y."
  Không ai đọc phụ lục theo thứ tự; mỗi mục đứng một mình.
- **Né "là" và "có"** (nhóm C): "Flag `--force` đóng vai trò là cơ chế ghi đè" phải là "Flag
  `--force` ghi đè".
- **Giọng quảng cáo phiên bản tài liệu** (nhóm A): "option `--parallel` mạnh mẽ". Option làm
  việc gì thì ghi việc đó.
- **Mục chen nhận xét.** Khuyến nghị nằm ở các chương; phụ lục ghi cái đang là, nhiều nhất kèm
  một tham chiếu chéo sang chương đưa ra đánh giá.
- **Mục dựa vào mục bên cạnh:** "Như trên, nhưng cho macOS." Lặp lại mẩu ngữ cảnh nhỏ đó; đây là
  tone duy nhất mà lặp một chút là đúng, vì mỗi mục được đọc riêng lẻ.

## Trước và sau

**Trước:** Sau khi đã tìm hiểu các option cấu hình, cần lưu ý rằng flag --parallel đóng vai trò
là một cơ chế mạnh mẽ giúp nâng cao hiệu năng build.

**Sau:** `--parallel <n>`: build tối đa `<n>` target cùng lúc. Mặc định: số core của máy. Xem
chương 9 về trường hợp build song song làm đổi thứ tự link.
