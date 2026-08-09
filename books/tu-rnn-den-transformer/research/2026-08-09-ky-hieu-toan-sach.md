# Ký hiệu toàn sách — thiết kế và căn cứ

Ghi ngày 2026-08-09. Chương 01 định nghĩa hệ ký hiệu này; phụ lục A đối chiếu
nó với từng bài trong sáu bài báo gốc.

## Nguyên tắc thiết kế

Hệ ký hiệu này tồn tại vì sáu bài báo dùng sáu bộ ký hiệu khác nhau và không
cái nào tương thích với cái nào. LSTM gọi `c_t` là cell state; Bahdanau gọi
`c_i` là context vector. Không có một bộ ký hiệu chung thì sách không thể đặt
phương trình của hai bài báo cạnh nhau, mà đó là phần lớn những gì cuốn sách này
tồn tại để làm.

Nguyên tắc:

1. **Nhất quán toàn sách.** Mỗi đại lượng có đúng một ký hiệu, và mỗi ký hiệu
   có đúng một nghĩa. Không tái sử dụng chữ cái cho mục đích khác ở chương sau.
2. **Gần với quy ước hiện đại.** Sinh viên ra ngoài đọc paper năm 2026 sẽ gặp
   `h_t` cho hidden state và `W` cho ma trận trọng số, không gặp `s_t` hay
   `U, V, W` kiểu 1997.
3. **Tự mô tả.** `W_xh` nói "từ input tới hidden", không cần tra bảng.
4. **Jacobian trước.** Từ chương 01 đến chương 04, mọi đạo hàm được viết dưới
   dạng Jacobian, vì đó là ngôn ngữ tự nhiên nhất để dẫn xuất vanishing
   gradient, constant error carousel, và attention.

## Bảng ký hiệu chính

### Vô hướng, vector, ma trận

| Ký hiệu | LaTeX | Ý nghĩa |
|---------|-------|---------|
| `x_t` | `\vect{x}_t` | Vector đầu vào tại bước thời gian t |
| `h_t` | `\vect{h}_t` | Trạng thái ẩn tại bước t |
| `y_t` | `\vect{y}_t` | Vector đầu ra tại bước t |
| `a_t` | `\vect{a}_t` | Pre-activation trước khi qua hàm kích hoạt |
| `W_xh` | `\mat{W}_{xh}` | Ma trận trọng số input → hidden |
| `W_hh` | `\mat{W}_{hh}` | Ma trận trọng số hồi quy hidden → hidden |
| `W_hy` | `\mat{W}_{hy}` | Ma trận trọng số hidden → output |
| `b_h` | `\vect{b}_h` | Bias hidden |
| `b_y` | `\vect{b}_y` | Bias output |

### Kích thước

| Ký hiệu | Ý nghĩa |
|---------|---------|
| `d_x` | Số chiều vector đầu vào |
| `d_h` | Số chiều vector trạng thái ẩn |
| `d_y` | Số chiều vector đầu ra |
| `T` | Số bước thời gian của chuỗi |

### Hàm và toán tử

| Ký hiệu | LaTeX | Ý nghĩa |
|---------|-------|---------|
| `σ` | `\sigma` | Hàm sigmoid logistic |
| `tanh` | `\tanh` | Hàm tanh, dùng cho RNN |
| `⊙` | `\odot` | Tích Hadamard (element-wise) |
| `∂L/∂W` | `\pd{L}{\mat{W}}` | Gradient của loss theo ma trận, dạng Jacobian |
| `diag(v)` | `\diag(\vect{v})` | Ma trận đường chéo từ vector |

### Chỉ số và quy ước

| Ký hiệu | Ý nghĩa |
|---------|---------|
| `t` | Chỉ số bước thời gian, 1..T |
| `h_0` | Trạng thái ẩn khởi tạo (luôn là vector không) |
| `\transpose` | Chuyển vị ma trận |

## Những chỗ xung đột đã né

1. **`c_t`:** LSTM gọi cell state là `c_t`; Bahdanau gọi context vector là
   `c_i`. Sách này không dùng `c` cho cả hai: cell state LSTM sẽ là `c_t` vì
   LSTM ra đời trước và `c_t` đã thành quy ước trong mọi textbook. Context
   vector của Bahdanau sẽ là `\vect{c}_t` với subscript `t` thay vì `i`. Phụ
   lục A ghi lại ánh xạ.
2. **`s_t`:** Một số paper RNN đầu tiên gọi hidden state là `s_t`. Sách này
   dùng `h_t` như mọi textbook hiện đại. Phụ lục A ghi chú.
3. **`U, V, W`:** LSTM 1997 gọi input weights là `W`, recurrent weights là `U`,
   output weights là `V`. Sách này dùng `W_xh, W_hh, W_hy`. Tự mô tả quan trọng
   hơn ngắn gọn, và sinh viên mở paper Transformer sẽ thấy `W^Q, W^K, W^V`
   cũng theo cùng quy ước này.

## Macro LaTeX đã định nghĩa

Tất cả macro ký hiệu nằm trong `preamble/macros.tex`:

- `\vect{}` — vector (bold lowercase)
- `\mat{}` — ma trận (bold uppercase, cùng thân với `\vect{}`)
- `\transpose` — chuyển vị `^{\mathsf{T}}`
- `\pd{}{}` — đạo hàm riêng
- `\jac{}{}` — Jacobian (cùng thân `\pd`, dùng riêng để grep được)
- `\diag{}` — toán tử đường chéo
- `\norm{}`, `\abs{}`, `\inner{}{}` — chuẩn, trị tuyệt đối, tích vô hướng

Phụ lục A sẽ có dạng một bảng ba cột: ký hiệu sách — ký hiệu tương đương trong
từng paper — ghi chú về sự khác biệt.
