# Chương 03: Phân tích (Pascanu, Mikolov, Bengio 2013)

Ghi ngày 2026-08-09.

Ghi chú nguồn và số đo cho chương 3. Mọi số thập phân chương 3 in ra đều phải
có mặt ở đây (quyết định 20 trong SPEC).

## Bài báo

File đọc: `1. On the difficulty of training recurrent neural networks.pdf`, thư
mục trong `2026-08-nguon-sau-bai-bao.md`. SHA-256 kiểm lại ngày 2026-08-09 bằng
`Get-FileHash -Algorithm SHA256`, khớp với manifest:

```
67C3D44B0F7CB1FC148069D14066B7AA7617FD37B9D7BD0040DC275506A9BF6E
```

Bản trên file: arXiv:1211.5063v2, cs.LG, 16 Feb 2013. Tổng cộng 12 trang: 9
trang thân bài và tài liệu tham khảo, 3 trang phụ lục.

### Venue: việc còn nợ từ phiên skeleton, nay đã trả

Manifest ghi trang bìa file không nói venue. Đã tra và chốt:

- Proceedings of the 30th International Conference on Machine Learning (ICML
  2013), Atlanta, Georgia, USA, 17-19 June 2013.
- PMLR (Proceedings of Machine Learning Research), volume 28, number 3, trang
  1310-1318. Editor: Sanjoy Dasgupta, David McAllester.
- Trang chính thức: https://proceedings.mlr.press/v28/pascanu13.html (đọc ngày
  2026-08-09), có sẵn khối BibTeX với khóa `pmlr-v28-pascanu13`.

Hệ quả cho chương: **số trang trong bản arXiv không phải số trang kỷ yếu.** Bản
arXiv đánh trang 1 đến 12; kỷ yếu đánh 1310-1318. Trích dẫn có neo trang phải
neo theo kỷ yếu, không theo file PDF đang đọc.

## Những gì bài báo thật sự viết

Đọc thẳng từ file, không lấy từ trí nhớ.

### Tham số hoá

Phương trình (1): `x_t = F(x_{t-1}, u_t, theta)`.

Phương trình (2): `x_t = W_rec sigma(x_{t-1}) + W_in u_t + b`.

Chú thích chân trang 1 nói rõ dạng này tương đương dạng quen thuộc hơn
`x_t = sigma(W_rec x_{t-1} + W_in u_t + b)`, và họ chọn nó "for convenience".
Tiện ở chỗ Jacobian tách được ma trận hằng ra khỏi phần phụ thuộc trạng thái.

### Gradient viết dạng tổng tích

Phương trình (3), (4), (5). Phương trình (5) là chỗ chương 3 dựa vào:

```
d x_t / d x_k = prod_{t >= i > k} d x_i / d x_{i-1}
              = prod_{t >= i > k} W_rec^T diag(sigma'(x_{i-1}))
```

### Điều kiện đủ cho vanishing, điều kiện cần cho exploding

Mục 2.1. Với `gamma` là chặn trên của `|sigma'(x)|`:

- **Đủ** để vanishing: `lambda_1 < 1 / gamma`, trong đó bài viết `lambda_1` là
  "the absolute value of the largest eigenvalue" của `W_rec`.
- **Cần** để exploding: `lambda_1 > 1 / gamma`.
- `gamma = 1` cho tanh, `gamma = 1/4` cho sigmoid. Bài ghi đúng như vậy.

Phương trình (6): `||d x_{k+1} / d x_k|| <= ||W_rec^T|| ||diag(sigma'(x_k))||
< (1/gamma) gamma < 1`.

Phương trình (7): `(d E_t / d x_t) prod_{i=k}^{t-1} (d x_{i+1} / d x_i)
<= eta^{t-k} (d E_t / d x_t)` với `eta < 1`.

Phụ lục, phương trình (12): trường hợp tuyến tính `d x_t / d x_k = (W_rec^T)^l`
với `l = t - k`. Chứng minh bằng power iteration, phương trình (13), giả thiết
`W_rec` chéo hoá được, mở rộng được qua dạng chuẩn Jordan. Phụ lục nói thẳng:
"This result provides a necessary condition for gradients to grow, namely that
the spectral radius (the absolute value of the largest eigenvalue) of W_rec
must be larger than 1."

### Hai biện pháp

Mục 3.2, thuật toán 1, chép nguyên:

```
g_hat <- dE/dtheta
if ||g_hat|| >= threshold then
    g_hat <- (threshold / ||g_hat||) g_hat
end if
```

Bài nói thuật toán này rất giống đề xuất của Tomas Mikolov, và họ chỉ lệch khỏi
bản gốc "in an attempt to provide a better theoretical foundation (ensuring that
we always move in a descent direction with respect to the current mini-batch),
though in practice both variants behave similarly". Mikolov cắt theo từng phần
tử; bản này cắt theo norm.

Heuristic chọn threshold: nhìn thống kê norm trung bình qua một số lượng đủ lớn
các bước cập nhật. Bài nói thêm là huấn luyện không nhạy lắm với siêu tham số
này và thuật toán chạy tốt cả với threshold khá nhỏ.

Mục 3.3, phương trình (9), regularizer giữ norm:

```
Omega = sum_k Omega_k
      = sum_k ( ||(dE/dx_{k+1}) (dx_{k+1}/dx_k)|| / ||dE/dx_{k+1}|| - 1 )^2
```

Phương trình (10): chỉ dùng đạo hàm riêng "immediate" theo `W_rec`, coi `x_k` và
`dE/dx_{k+1}` là hằng. Họ dùng Theano để lấy `dE/dx_k` từ BPTT.

### Số của bài báo (số của họ, không phải số tôi đo)

Bảng 1, dự đoán nhạc đa âm, negative log likelihood mỗi bước, thấp hơn là tốt:

| Tập dữ liệu | Fold | SGD | SGD+C | SGD+CR |
|---|---|---|---|---|
| Piano-midi.de | train | 6.87 | 6.81 | 7.01 |
| Piano-midi.de | test | 7.56 | 7.53 | 7.46 |
| Nottingham | train | 3.67 | 3.21 | 3.24 |
| Nottingham | test | 3.80 | 3.48 | 3.46 |
| MuseData | train | 8.25 | 6.54 | 6.51 |
| MuseData | test | 7.11 | 7.00 | 6.99 |

Bảng 2, dự đoán ký tự kế tiếp trên Penn Treebank, entropy bit trên ký tự:

| Nhiệm vụ | Fold | SGD | SGD+C | SGD+CR |
|---|---|---|---|---|
| 1 bước | train | 1.46 | 1.34 | 1.36 |
| 1 bước | test | 1.50 | 1.42 | 1.41 |
| 5 bước | train | N/A | 3.76 | 3.70 |
| 5 bước | test | N/A | 3.89 | 3.74 |

Bài toán thứ tự thời gian (mục 4.1.1, hình 7): với chuỗi dài hơn 20 bước, cả SGD
lẫn SGD-C đều không giải được. SGD-CR giải được với tỷ lệ thành công 100% tới
200 bước, và một model duy nhất xử lý được mọi độ dài từ 50 tới 200.

Siêu tham số trong phụ lục thực nghiệm: bài toán cộng dùng 50 đơn vị ẩn, tanh,
learning rate 0.01, hệ số regularization 0.5, ngưỡng clipping 6, trọng số khởi
tạo từ phân phối chuẩn trung bình 0 độ lệch chuẩn 0.1. Bài toán thứ tự thời gian
dùng 50 đơn vị ẩn, learning rate 0.001, hệ số 2, ngưỡng 6. Hoán vị ngẫu nhiên là
bài khó nhất: chỉ 1 trong 8 lần chạy thành công.

## Ba chỗ vênh, ghi lại vì cả ba đều đủ sức làm hỏng một đoạn

### 1. Tham chiếu "equation (11)" trong thân bài

Thân bài trang 1 viết "the specific parametrization given by equation (11)",
nhưng ngay bên dưới in ra phương trình đánh số (2). Mục 2.1 cũng nhắc "(11)" ba
lần. Không phải lỗi: phương trình (11) nằm ở phụ lục, và nó là bản chép lại của
(2). Người đọc dò theo số (11) từ trang 1 sẽ đi tới phụ lục chứ không tìm thấy
gì ở thân bài. Chương 3 nhắc tới phương trình theo nội dung, không theo số.

### 2. Chuyển vị trong phương trình (5)

Với `x_t = W_rec sigma(x_{t-1}) + ...`, Jacobian theo quy ước vector cột là
`W_rec diag(sigma'(x_{t-1}))`. Chuyển vị của nó là
`diag(sigma'(x_{t-1})) W_rec^T`, chứ không phải `W_rec^T diag(sigma'(x_{i-1}))`
như (5) in. Lý do là bài đẩy gradient ngược dạng vector hàng.

Không có hệ quả nào cho các chặn: mọi chặn trong bài đều đặt trên spectral norm,
và một ma trận với chuyển vị của nó có cùng spectral norm. Chương 3 phải khai
báo quy ước thay vì thừa kế chỗ mập mờ này. Đã kiểm bằng máy: xem test
`test_jacobian_factors_as_w_rec_times_diag_sigma_prime`, so Jacobian giải tích
với `torch.autograd.functional.jacobian`, sai khác dưới `1e-10`.

### 3. Trị riêng lớn nhất không phải giá trị kỳ dị lớn nhất

Đây là chỗ vênh nặng nhất và là chỗ dòng TOC của chương đã nói trước.

Bài phát biểu điều kiện đủ qua `lambda_1`, "trị tuyệt đối của trị riêng lớn
nhất". Nhưng chứng minh, phương trình (6), chặn `||W_rec^T||`, và đó là một giá
trị kỳ dị. Ma trận chuẩn tắc (normal) thì hai số bằng nhau; chiều ngược lại không đúng, có ma trận không chuẩn tắc mà hai số vẫn bằng nhau, ví dụ ma trận 3x3 với các hàng (1,0,0), (0,0,1), (0,0,0), đo được rho = norm = 1. Với
ma trận không chuẩn tắc, bán kính phổ nhỏ hơn `1/gamma` **không** kéo theo chặn
(6), nên phát biểu đọc theo nghĩa đen là không đủ; chỉ bản đọc theo giá trị kỳ
dị mới làm chứng minh chạy được.

Đã đo, xem mục dưới: ma trận `[[0.9, 3.0], [0, 0.9]]` có bán kính phổ 0.9 và
spectral norm 3.249286. Tích Jacobian của nó **tăng** tới 11.635514 ở bước 9
trước khi giảm, và chỉ tụt xuống dưới 1 từ bước 49.

## Số tôi đo

### Môi trường và cách chạy lại

Repo companion: https://github.com/Giang-Dang/rnn-to-transformer-lab, tag
`ch03`, commit `bc021ec`.

```
git clone git@github.com:Giang-Dang/rnn-to-transformer-lab.git
cd rnn-to-transformer-lab
git checkout ch03
conda env create -f environment.yml
conda activate rnn-to-transformer-lab
python verify.py
```

Mọi script in ra dòng phiên bản trước khi in số:

```
python 3.12.13 | torch 2.11.0+cpu | numpy 2.2.6 | Windows AMD64
```

Máy đo: laptop, CPU, không dùng card đồ hoạ. `verify.py` chạy hết 105.93 giây,
trong đó riêng phần verify của chương 2 chiếm 91.31 giây; toàn bộ phần chương 3
gộp lại là 13.32 giây.

**Ngân sách thời gian, chốt trong phiên này** (mục còn treo trong SPEC): mỗi
experiment 60 giây, cả lần chạy verify 600 giây. `verify.py` tự kiểm và trả về
mã lỗi khác 0 nếu vượt, nên đây là ràng buộc chứ không phải ghi chú.

### Đo 1: tốc độ tắt của tích Jacobian theo bán kính phổ

`python experiments/ch03_decay.py`. 64 đơn vị ẩn, 100 bước, tanh, `W_rec` chuẩn
tắc (trực giao nhân vô hướng) nên bán kính phổ bằng spectral norm.

```
radius  norm   l=1         l=10        l=50        l=100      rate
0.500   0.500  5.0000e-01  9.7532e-04  8.8705e-16  7.8786e-31 0.5000
0.900   0.900  9.0000e-01  3.4200e-01  5.0259e-03  2.5902e-05 0.9000
1.000   1.000  1.0000e+00  9.5614e-01  7.6328e-01  6.2852e-01 0.9961
1.200   1.200  1.2000e+00  4.9458e+00  2.4703e+01  8.2505e+01 1.0244
```

Hai điều đáng nói, cả hai đều không có trong bài báo:

1. **Bán kính phổ đúng bằng 1 vẫn tắt**, chậm thôi: tốc độ đo được là 0.9961
   chứ không phải 1. Vì `tanh'(x) < 1` ngay khi trạng thái rời khỏi gốc, nên
   `gamma = 1` là chặn không bao giờ đạt được trên một quỹ đạo thật.
Để đối chiếu, `1.2 ** 100` bằng 8.2818e+07 (tính bằng Python, cùng môi
trường), và `8.2818e+07 / 82.505` bằng 1.003793e+06: số đo được nhỏ hơn luỹ
thừa thuần tuý khoảng một triệu lần.

2. **Bán kính phổ 1.2 không cho tốc độ 1.2** mà cho 1.0244. Bão hoà kéo
   `sigma'` xuống. Đây chính là lý do điều kiện exploding của bài chỉ là điều
   kiện *cần*: vượt ngưỡng không có nghĩa là gradient sẽ nổ.

### Đo 2: khoảng cách giữa trị riêng và giá trị kỳ dị

`python experiments/ch03_nonnormal.py`. Trường hợp tuyến tính (`sigma` là ánh xạ
đồng nhất), đúng bối cảnh chứng minh ở phụ lục, nên tích Jacobian là luỹ thừa ma
trận, phương trình (12).

```
W = [[0.9, 3.0], [0, 0.9]]
spectral radius (largest |eigenvalue|) = 0.900000
spectral norm   (largest singular value) = 3.249286

l     ||W^l||
1     3.249286e+00
5     9.876803e+00
9     1.163551e+01
10    1.163307e+01
20    8.106934e+00
50    8.589935e-01
100   8.853879e-03

peak at l=9, ||W^l||=11.635514
amplification over l=1: 3.5809
first l with ||W^l|| < 1: 49
```

Kiểm được bằng tay: `W^l` có phần tử ngoài đường chéo là `l * 3 * 0.9^{l-1}`,
đạo hàm theo `l` triệt tiêu tại `l = -1 / ln(0.9) = 9.49`, nên đỉnh rơi vào giữa
bước 9 và bước 10 và hai giá trị gần bằng nhau. Số đo khớp.

### Đo 3: bức tường trong mặt lỗi

`python experiments/ch03_surface.py`. Dựng lại bối cảnh hình 6: một đơn vị ẩn,
không input, `x_t = w sigmoid(x_{t-1}) + b`, `x_0 = 0.5`, đọc lỗi một lần ở bước
50 theo `(sigmoid(x_50) - 0.7)^2`. Toàn bộ chạy ở float64.

Đi ngang qua tường tại `w = 5.0`, bước `b` là 0.001:

```
         b          cost        ||grad||
   -2.6140    0.34182245    2.457457e-01
   -2.6130    0.34157104    2.942246e-01
   -2.6120    0.00847633    9.281034e+00
   -2.6110    0.01020121    5.137097e-01
   -2.6100    0.01049210    2.777983e-01
```

Chi phí rơi 0.33309471 chỉ trong một bước 0.001 của `b`.

Vùng phẳng để đối chiếu, cùng `w = 5.0`: tại `b = -2.0`, chi phí 0.05558549 và
`||grad||` bằng 5.549566e-02.

Điểm dốc nhất theo từng `w`, tìm bằng lưới lồng nhau 4 vòng, mỗi vòng 401 điểm:

```
    w          b at peak    max ||grad||    cost there
  4.6      -2.3642758000    3.157208e+02    0.13157964
  4.8      -2.4880230200    1.396279e+03    0.14229738
  5.0      -2.6123413600    6.773125e+03    0.14960413
  5.2      -2.7367973600    3.424156e+04    0.15545694
  5.4      -2.8612821400    1.736738e+05    0.16071180
```

Hai lần chạy nữa, thêm vào sau khi audit chỉ ra hai con số của chương không tái
lập được ở tag:

```
--- what a step of 0.01 finds instead, over the whole window
max ||grad||=2.777983e-01 at b=-2.6100
the grid steps over the wall; this is a different number, not a rough one

--- the same search kept inside the window the paper drew
w=5.4 over b in [-2.8, -2.0]: max ||grad||=1.355472e-01 at b=-2.80816320
the wall at w=5.4 sits outside that window, so this number means nothing
```

Tỷ số giữa điểm dốc nhất và vùng phẳng tại `w = 5.0` là 1.2205e+05, tức
5.0865 bậc độ lớn.

Đỉnh tường di chuyển gần như tuyến tính theo `w`: từ 4.6 tới 5.2, `b` tại đỉnh
đi từ -2.364 tới -2.737, độ dốc khoảng -0.62 trên mỗi đơn vị `w`.

Lưới `w` trong bảng đi từng bước 0.2, và trên mỗi bước 0.2 đó, độ dốc lớn nhất
nhân lên khoảng năm lần: 3.157208e+02, 1.396279e+03, 6.773125e+03, 3.424156e+04,
1.736738e+05. Tỷ số giữa hai dòng liên tiếp lần lượt là 4.42, 4.85, 5.06, 5.07.

### Đo 4: một bước đi ngay tại tường, có cắt và không cắt

`python experiments/ch03_clipping.py`. Xuất phát từ đúng điểm dốc nhất ở trên,
learning rate 0.1.

```
start point: w=5.0 b=-2.6123413600
learning rate 0.1

cost at start      0.14960413
dE/dw              -3.577721e+03
dE/db              -5.751099e+03
||grad||           6.773125e+03

 thresh  fired        step        w after        b after        cost
   none  False  6.7731e+02   362.77214318   572.49753848  0.09000000
    1.0   True  1.0000e-01     5.05282231    -2.52743080  0.02586525
    0.1   True  1.0000e-02     5.00528223    -2.60385030  0.01215804
```

Bản đầu của phiên này in `cost at start 0.14959206`, vì script clipping dán sẵn
`b = -2.6123413579` trong khi script surface tính ra `-2.6123413600`. Lệch
khoảng 2e-9, đủ để đổi chi phí ở chữ số thập phân thứ năm, và chương in cả hai
rồi gọi chúng là một điểm. Audit bắt được. Cả hai script bây giờ gọi chung
`steepest_point`, và có test khoá lại.

Bước không cắt dài gấp 6.7731e+03 lần bước cắt ở ngưỡng 1.0, tức 3.8308 bậc.

Chi tiết đáng giữ: chi phí sau bước không cắt là **đúng 0.09000000**. Không phải
trùng hợp. Với `w = 362.77` và `b = 572.50` thì `sigmoid(x_50)` bão hoà về 1
trong float64, nên chi phí là `(1 - 0.7)^2 = 0.09` chính xác. Một bước ấy không
tìm ra cực tiểu tệ hơn; nó rời khỏi bài toán.

### Đo 5: regularizer nhìn thấy gì

`python experiments/ch03_regularizer.py`. 32 đơn vị ẩn, 30 bước, tanh, chi phí
`0.5 * ||x_T||^2`. In ra tỷ số từng bước trước khi bình phương.

```
 radius k=0         k=10        k=28             mean      Omega
  0.500 0.488384    0.500000    0.500000     0.499463   7.516259
  0.900 0.879230    0.897886    0.899925     0.895816   0.326728
  1.000 0.977480    0.982812    0.978343     0.978175   0.014876
```

Tỷ số hội tụ về đúng bán kính phổ, và `Omega` giảm đơn điệu khi mạng tiến về chỗ
giữ được norm.

## Đo rồi mà không dùng, ghi lại để khỏi đo lại

- **Quét thô mặt lỗi với bước 0.01 hoàn toàn bỏ sót bức tường.** Tại `w = 5.0`,
  quét cả cửa sổ với bước 0.01 cho `max ||grad||` bằng 2.777983e-01, thấp hơn
  đỉnh thật bốn bậc độ lớn, vì lưới nhảy qua chỗ dốc. Phải xuống tới bước 0.001
  mới thấy, và xuống tới lưới lồng nhau mới đo được đỉnh. Bài học: với mặt lỗi
  kiểu này, một con số lấy từ lưới thô là con số sai chứ không phải con số thô.
- **Tại `w = 5.4`, tường nằm ngoài cửa sổ mà chính bài báo vẽ.** Đỉnh ở
  `b = -2.8612821400`, trong khi hình 6 chỉ vẽ `b` từ -2.8 tới -2.0. Script phải
  nới cửa sổ tìm kiếm xuống -3.0. Nếu giữ nguyên cửa sổ của bài, số trả về là
  1.355472e-01 tại `b = -2.80816320`, và nó vô nghĩa.
- **`torch.nn.utils.clip_grad_norm_` không phải thuật toán 1.** Nó nhân với
  `max_norm / (total_norm + 1e-6)` chứ không phải `max_norm / total_norm`, nên
  cắt xuống hơi thấp hơn ngưỡng. Với gradient có norm `sqrt(50)`, norm sau khi
  cắt là 0.9999998585786636 thay vì 1. Phát hiện lúc viết test, không phải lúc
  đọc tài liệu. Hướng vector thì cả hai bản giữ như nhau.
- **Quỹ đạo gần tường hội tụ rất chậm.** Tại `b = -2.6`, năm trạng thái cuối
  vẫn còn trôi: 1.449689, 1.449753, 1.449802, 1.449840, 1.449869. Tại `b = -2.4`
  thì đứng yên ở 2.008360 từ lâu. Đúng dấu hiệu của một hệ đang ở gần điểm rẽ
  nhánh.
- **Verify của chương 2 mất 91.31 giây**, gấp gần bảy lần toàn bộ phần chương 3
  cộng lại. Chưa sửa gì, vì đó là việc của chương 2; đã ghi vào mục còn treo của
  SPEC.

## Việc còn nợ sau chương này

- Chương 4 sẽ cần chính `jacobians.py` này để lấy đạo hàm qua constant error
  carousel. Giữ nguyên chữ ký hàm nếu được.
- Bảng 1 và bảng 2 ở trên chưa dùng hết trong chương 3. Nếu chương nào trích,
  phải kiểm lại trong bản kỷ yếu chứ không chỉ bản arXiv.

## Dạng in trong sách

Cùng số đo ở trên, viết lại theo dạng chương 3 in ra. Ghi ở đây để mỗi số thập
phân trên trang sách tra ngược được về đúng lần chạy đã sinh ra nó, thay vì chỉ
tra được về dạng ký hiệu khoa học mà script in.

| Dạng script in | Dạng sách in | Chỗ dùng |
|---|---|---|
| `6.2852e-01` | 0.62852 | chuẩn tích Jacobian sau 100 bước, bán kính phổ 1.0 |
| `8.2505e+01` | 82.505 | chuẩn tích Jacobian sau 100 bước, bán kính phổ 1.2 |
| `2.777983e-01` | 0.2777983 | chuẩn gradient lớn nhất tìm được bằng lưới thô bước 0.01 |
| `1.355472e-01` | 0.1355472 | số vô nghĩa trả về khi giữ nguyên cửa sổ của bài tại w = 5.4 |
