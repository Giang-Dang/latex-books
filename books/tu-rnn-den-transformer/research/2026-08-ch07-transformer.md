# Chương 07: Kiến trúc Transformer (Vaswani và cộng sự 2017)

Ghi ngày 2026-08-11.

Ghi chú nguồn và số đo cho chương 7. Mọi số thập phân chương 7 in ra đều phải
có mặt ở đây (quyết định 20 trong SPEC).

## 1. Hai bản của cùng một bài, và chúng không phải một tài liệu

Đây là phát hiện đắt nhất của phiên này, và nó xác nhận đúng cảnh báo mà
`2026-08-nguon-sau-bai-bao.md` đã ghi từ ngày đọc trang bìa.

### Bản trong tay tác giả

File `5. Attention Is All You Need.pdf`, thư mục ghi trong manifest. Bản
arXiv:1706.03762v7, cs.CL, đề ngày **2 Aug 2023**, 15 trang, 2215244 byte,
SHA-256 khớp manifest:

```
bdfaa68d8984f0dc02beaca527b76f207d99b666d31d1da728ee0728182df697
```

Trang bìa ghi `31st Conference on Neural Information Processing Systems (NIPS
2017), Long Beach, CA, USA`.

### Bản kỷ yếu NIPS 2017

Tải ngày 2026-08-11 từ:

```
https://proceedings.neurips.cc/paper_files/paper/2017/file/
3f5ee243547dee91fbd053c1c4a845aa-Paper.pdf
```

569417 byte, SHA-256:

```
d87d482d5ae7960e2e43d7dd6d21377e60e73e8fce1bf2a01aff7aca8a08c537
```

Đếm trang: `/Count 11` và 11 lần `/Type /Page` trong byte thô. Không bị chẻ cây
trang như hai bản Cho 2014b của chương 6, nên không có bẫy số trang ở đây.

### Chỗ hai bản khác nhau

Kiểm bằng cách đọc từng trang cả hai file, không đọc bản chuyển sang text.

| Chỗ | Kỷ yếu NIPS 2017 (11 trang) | arXiv v7 (15 trang) |
|-----|------------------------------|---------------------|
| Mục 6.3 và bảng 4, phân tích cú pháp tiếng Anh | **không có** | có, F1 91.3 và 92.7 |
| Phụ lục Attention Visualizations, hình 3 tới 5 | **không có** | có |
| Câu về constituency parsing trong tóm tắt | **không có** | có |
| Danh mục tài liệu | tới [32] | tới [40] |
| BLEU Anh-Pháp của Transformer (big) | **41.0** ở cả tóm tắt, bảng 2 và thân bài | **41.8** ở tóm tắt và bảng 2, **41.0** ở thân bài mục 6.1 |

**Bản arXiv v7 tự mâu thuẫn với chính nó.** Tôi đọc lại trang 8 của cả hai file
ở độ phân giải đầy đủ để chắc chắn, vì đây là con số trung tâm:

- arXiv v7, bảng 2, hàng `Transformer (big)`: EN-DE `28.4`, EN-FR `41.8`.
- arXiv v7, mục 6.1, đoạn thứ hai: \enquote{our big model achieves a BLEU score
  of 41.0, outperforming all of the previously published single models}.
- Kỷ yếu, bảng 2, cùng hàng: EN-DE `28.4`, EN-FR `41.0`.
- Kỷ yếu, mục 6.1: cùng câu, cũng `41.0`.

Nghĩa là con số `41.8` mà gần như mọi chỗ trích lại chỉ có trong bảng và tóm tắt
của một bản sửa năm 2023, còn thân bài của chính bản ấy vẫn ghi `41.0`. Chương 7
in cả hai và nói rõ cái nào ở đâu.

Các số còn lại của bảng 2 giống nhau ở cả hai bản: Anh-Đức base `27.3`, big
`28.4`; Anh-Pháp base `38.1`. Chi phí huấn luyện `3.3 * 10^18` FLOP cho base và
`2.3 * 10^19` cho big; `3.5` ngày trên tám GPU P100 cho big, `12` giờ và
`100000` bước cho base, `300000` bước cho big.

Ghi chú phiên bản: bản v1 ngày 12 Jun 2017 **không có** chú thích số 4 giải
thích phép chia cho căn `d_k`, và bảng 3 của v1 ghi `d_ff = 1024` trong khi phần
chữ của chính v1 ghi `2048`. Cả hai chỗ đã đúng ở bản kỷ yếu. Chương 7 không
dùng v1 làm nguồn cho gì cả; ghi lại để phiên sau khỏi đi lại đường này.

## 2. Câu chữ trích nguyên văn

Mọi câu dưới đây giống hệt nhau ở bản kỷ yếu và bản arXiv v7, trừ chỗ ghi rõ là
khác. Số trang là số trang của bản arXiv v7.

**Chú thích số 4, trang 4** (chỗ chương 7 dẫn xuất lại):

> To illustrate why the dot products get large, assume that the components of
> q and k are independent random variables with mean 0 and variance 1. Then
> their dot product, q · k = sum_{i=1}^{d_k} q_i k_i, has mean 0 and variance
> d_k.

Câu trong thân bài mục 3.2.1 mà chú thích ấy treo vào:

> While for small values of d_k the two mechanisms perform similarly, additive
> attention outperforms dot product attention without scaling for larger values
> of d_k. We suspect that for large values of d_k, the dot products grow large
> in magnitude, pushing the softmax function into regions where it has
> extremely small gradients. To counteract this effect, we scale the dot
> products by 1/sqrt(d_k).

Và câu nối thẳng chương này với chương 6, cùng mục:

> The two most commonly used attention functions are additive attention, and
> dot-product (multiplicative) attention. Dot-product attention is identical to
> our algorithm, except for the scaling factor of 1/sqrt(d_k). Additive
> attention computes the compatibility function using a feed-forward network
> with a single hidden layer. While the two are similar in theoretical
> complexity, dot-product attention is much faster and more space-efficient in
> practice, since it can be implemented using highly optimized matrix
> multiplication code.

**Mục 3.2.2, chi phí của nhiều đầu:**

> In this work we employ h = 8 parallel attention layers, or heads. For each of
> these we use d_k = d_v = d_model/h = 64. Due to the reduced dimension of each
> head, the total computational cost is similar to that of single-head
> attention with full dimensionality.

**Mục 3.1, residual và layer norm:**

> We employ a residual connection around each of the two sub-layers, followed
> by layer normalization. That is, the output of each sub-layer is
> LayerNorm(x + Sublayer(x)), where Sublayer(x) is the function implemented by
> the sub-layer itself.

**Mục 3.5, trang 6:**

> The wavelengths form a geometric progression from 2pi to 10000 · 2pi. We
> chose this function because we hypothesized it would allow the model to
> easily learn to attend by relative positions, since for any fixed offset k,
> PE_{pos+k} can be represented as a linear function of PE_{pos}.

> We also experimented with using learned positional embeddings instead, and
> found that the two versions produced nearly identical results (see Table 3
> row (E)). We chose the sinusoidal version because it may allow the model to
> extrapolate to sequence lengths longer than the ones encountered during
> training.

Chữ **hypothesized** là chữ của bài. Bài không chứng minh tính chất ấy và không
đo nó; mục 7.4 của chương là chỗ đo.

**Che: hai câu, và chúng ở hai mục khác nhau.** Chỗ này lần đầu ghi sai, nên ghi
kỹ. Câu về cơ chế nằm ở **mục 3.2.3**:

> We implement this inside of scaled dot-product attention by masking out
> (setting to −inf) all values in the input of the softmax which correspond to
> illegal connections.

Còn câu về phép dịch một bước nằm ở **mục 3.1**, trong đoạn \enquote{Decoder:},
trang 3 của bản kỷ yếu, tức trước đó hẳn một mục:

> We also modify the self-attention sub-layer in the decoder stack to prevent
> positions from attending to subsequent positions. This masking, combined with
> fact that the output embeddings are offset by one position, ensures that the
> predictions for position i can depend only on the known outputs at positions
> less than i.

Câu thứ hai thiếu chữ \enquote{the} sau \enquote{with}. Lỗi ấy có nguyên văn ở
cả v1, bản kỷ yếu và v7, nên nó là lỗi của bài chứ không phải lỗi chép. Trích thì
để nguyên.

**Ba câu nữa chương có trích, ghi ở đây cho đủ nguồn.** Mục 3.2.3, về attention
encoder-decoder:

> This mimics the typical encoder-decoder attention mechanisms in
> sequence-to-sequence models.

Mục 3.5, câu mở đầu, là câu duy nhất bài nói về lý do cần mã hóa vị trí:

> Since our model contains no recurrence and no convolution, in order for the
> model to make use of the order of the sequence, we must inject some
> information about the relative or absolute position of the tokens in the
> sequence.

Mục 5.4, về label smoothing:

> This hurts perplexity, as the model learns to be more unsure, but improves
> accuracy and BLEU score.

**Quy mô dữ liệu của bài**, mục 5.1, để chương 7 so với 6000 cặp của corpus đồ
chơi: WMT 2014 Anh-Đức có khoảng **4.5 triệu** cặp câu; bản Anh-Pháp có 36 triệu
câu. Số 4.5 này chương 7 in ra, nên nó phải nằm ở đây chứ không phải chỉ nằm
trong bài.

**Mục 7, kết luận** (giống nhau ở kỷ yếu và v7; v1 khác):

> We are excited about the future of attention-based models and plan to apply
> them to other tasks. We plan to extend the Transformer to problems involving
> input and output modalities other than text and to investigate local,
> restricted attention mechanisms to efficiently handle large inputs and
> outputs such as images, audio and video. Making generation less sequential is
> another research goals of ours.

Chữ \enquote{another research goals} sai ngữ pháp trong chính bài, ở cả ba bản.

**Bảng 1, mục 4**, chép nguyên:

```
Layer Type                   Complexity per Layer   Sequential   Max Path Length
Self-Attention               O(n^2 . d)             O(1)         O(1)
Recurrent                    O(n . d^2)             O(n)         O(n)
Convolutional                O(k . n . d^2)         O(1)         O(log_k(n))
Self-Attention (restricted)  O(r . n . d)           O(1)         O(n/r)
```

**Bảng 3 hàng (A)**, số đầu attention, giữ nguyên tổng chi phí tính:

```
h    d_k   d_v   PPL    BLEU
1    512   512   5.29   24.9
4    128   128   5.00   25.5
16   32    32    4.91   25.8
32   16    16    5.01   25.4
```

Nhận xét của bài: \enquote{While single-head attention is 0.9 BLEU worse than
the best setting, quality also drops off with too many heads}. Hiệu `25.8 -
24.9 = 0.9`.

Hàng (E), learned positional embedding: PPL `4.92`, BLEU `25.7`, so với base
`25.8`.

**Mục 5.3, optimizer**: Adam với `beta_1 = 0.9`, `beta_2 = 0.98`,
`epsilon = 10^-9`, `warmup_steps = 4000`. **Mục 5.4**: `P_drop = 0.1` cho base,
`epsilon_ls = 0.1`. Cả hai là chuyện của chương 8, ghi ở đây vì chương 7 phải
nói mình *không* dùng chúng.

**Kích thước base**: `d_model = 512`, `N = 6` tầng mỗi phía, `h = 8`,
`d_k = d_v = 64`, `d_ff = 2048`.

## 3. Môi trường đo

Mọi phép đo dưới đây chạy trong repo companion `rnn-to-transformer-lab` tại tag
`ch07`.

```
python 3.12.13 | torch 2.11.0+cpu | numpy 2.2.6 | Windows AMD64
```

**Một cái bẫy công cụ, ghi lại vì mất thời gian thật.** Chạy các script này qua
`conda run -n rnn-to-transformer-lab python ...` thì hỏng khi output có tiếng
Việt: `conda run` gom stdout của tiến trình con rồi in lại bằng cp1252, nên
`utf8_stdout()` trong tiến trình con không cứu được, và lỗi báo ra là một
`UnicodeEncodeError` bên trong chính conda chứ không phải trong script. Gọi
thẳng interpreter của env thì không có tầng ấy:

```
C:/Users/dangv/miniconda3/envs/rnn-to-transformer-lab/python.exe experiments/...
```

`verify.py` không dính vì nó gọi `sys.executable` qua `subprocess`.

## 4. Phép chia cho căn d_k

Đo bằng `experiments/ch07_scaling.py` tại tag `ch07`. Output thô:

```
footnote 4: q.k has mean 0 and variance d_k when q,k ~ N(0,1)
20000 samples per row

d_k    mean       var         var/d_k   sd        sqrt(d_k)
8      0.0226     8.0037      1.0005    2.8291    2.8284
16     0.0594     15.9820     0.9989    3.9977    4.0000
32     0.0047     32.1030     1.0032    5.6659    5.6569
64     0.0533     63.7511     0.9961    7.9844    8.0000
128    0.0184     125.6465    0.9816    11.2092   11.3137
256    -0.0128    256.9861    1.0039    16.0308   16.0000
512    0.1007     508.2525    0.9927    22.5445   22.6274
1024   -0.2621    1034.2814   1.0100    32.1602   32.0000

what that does to one softmax over 64 keys, averaged over 200 rows
grad is the Frobenius norm of the softmax Jacobian

       unscaled                    scaled by 1/sqrt(d_k)
d_k    max_p   entropy  grad       max_p   entropy  grad
8      0.4370  1.9930   0.303610   0.1081  3.6715   0.184700
16     0.6137  1.2680   0.281309   0.1156  3.6583   0.187285
32     0.7398  0.7896   0.235638   0.1120  3.6762   0.184970
64     0.7795  0.6256   0.219978   0.1034  3.6929   0.182454
128    0.8542  0.3930   0.165504   0.1034  3.7018   0.181279
256    0.9055  0.2494   0.114576   0.1061  3.6906   0.182846
512    0.9263  0.1844   0.091270   0.1103  3.6749   0.185140
1024   0.9431  0.1429   0.077089   0.1064  3.6870   0.183148

the premise: what a real projection actually produces
x ~ N(0,1); q = Linear(d_model, d_k)(x) at PyTorch's default init

d_model  d_k    var(component)  var(q.k)   d_k     ratio
512      64     0.333680        7.174865   64      0.112107
512      512    0.333187        56.362167  512     0.110082
64       16     0.328320        1.692329   16      0.105771
64       64     0.330210        7.071695   64      0.110495
```

Ba chuyện đọc được, và chuyện thứ ba là chuyện bài không nói.

1. Chú thích số 4 đúng: `var/d_k` nằm giữa `0.9816` và `1.0100` trên tám bậc.
2. Cái giá của việc không chia: trọng số lớn nhất đi từ `0.4370` lên `0.9431`,
   entropy tụt từ `1.9930` xuống `0.1429`, và chuẩn Frobenius của ma trận Jacobi
   của softmax tụt từ `0.303610` xuống `0.077089`, tức gần bốn lần. Chia rồi thì
   cả ba cột đứng yên: entropy nằm giữa `3.6583` và `3.7018`, gradient giữa
   `0.181279` và `0.187285`, trên toàn bộ dải `d_k` từ 8 tới 1024. Đó mới là
   phát biểu đáng in: phép chia không làm gradient lớn hơn, nó làm gradient
   **không còn phụ thuộc `d_k`**.
3. Giả thiết của chú thích không phải cái mã thật làm. `nn.Linear` của PyTorch
   khởi tạo Kaiming-uniform, tức đều trên `[-1/sqrt(fan_in), 1/sqrt(fan_in)]`,
   nên với input phương sai 1 thì mỗi thành phần output có phương sai `1/3` chứ
   không phải 1: đo được `0.333680`, `0.333187`, `0.328320`, `0.330210`. Kéo
   theo `var(q.k)` bằng khoảng `d_k / 9` chứ không phải `d_k`; tỷ số đo được
   `0.112107`, `0.110082`, `0.105771`, `0.110495`, quanh `1/9 = 0.1111`. Chia
   cho `sqrt(d_k)` do đó chia quá tay khoảng ba lần ở lúc khởi tạo. Điều đó
   **không** làm hỏng lập luận, vì việc của phép chia là bỏ sự phụ thuộc vào
   `d_k` chứ không phải đặt một thang tuyệt đối, và bảng thứ hai cho thấy đúng
   chuyện đó xảy ra. Ghi lại vì đây là chỗ giấy và máy lệch nhau và máy thắng.

Một phiên nghiên cứu độc lập chạy lại phép đo này với 200000 mẫu và một hàm mất
mát khác, ra cùng kết luận và cùng tỷ số `1/9`, kèm dẫn xuất: phương sai của
phân phối đều trên `[-b, b]` là `b^2/3`, với `b = 1/sqrt(fan_in)` cho phương sai
thành phần `1/3`, nên `var(q.k) = d_k * (1/3)^2 = d_k/9`.

**Chưa đo**: thống kê ấy sau khi huấn luyện xong. Mọi con số ở đây là lúc khởi
tạo.

## 5. Mã hóa vị trí

Đo bằng `experiments/ch07_position.py` tại tag `ch07`. Output thô:

```
1. self-attention alone cannot tell two orderings apart
permute the input, permute the output back, compare with the original

d_model  heads  steps  max|difference|
16       4      6      4.470e-08
32       4      12     4.098e-08
64       8      20     7.451e-08

2. PE(pos+k) = M_k PE(pos), and M_k does not depend on pos
M_k built analytically per pair: rotation by k*omega_i

offset k  max|M_k PE(pos) - PE(pos+k)|  over positions
1         1.341e-06                    5 tested
2         1.609e-06                    5 tested
5         1.222e-06                    5 tested
13        1.840e-06                    5 tested
40        2.623e-06                    5 tested

3. PE(pos) . PE(pos+k) depends on k only, d_model 64

offset k  pos=0     pos=1     pos=7     pos=30    spread
1         30.91683  30.91683  30.91683  30.91683  0.00e+00
2         28.30386  28.30386  28.30386  28.30386  1.91e-06
5         23.50397  23.50397  23.50397  23.50397  0.00e+00
13        21.00672  21.00672  21.00672  21.00672  3.81e-06
40        15.39746  15.39746  15.39746  15.39746  3.81e-06
```

Ba chỗ đáng ghi.

**Tính hoán vị.** Sai khác `4.470e-08`, `4.098e-08`, `7.451e-08` là nhiễu của
float32. Nên self-attention không phân biệt được hai thứ tự, đúng nghĩa đen, và
đó là lý do mục 3.5 phải tồn tại. Bài nói lý do ấy bằng một câu và không đo.

**Tính dịch tuyến tính.** Ma trận `M_k` dựng bằng giải tích, mỗi cặp tần số một
phép quay góc `k * omega_i` với `omega_i = 1/10000^(2i/d_model)`, dạng

```
[[ cos t, sin t],
 [-sin t, cos t]]
```

khớp bảng PE tới `1.341e-06` cho tới `2.623e-06` trên mọi `pos` thử. Dấu của ma
trận quay phụ thuộc vào việc bài xếp sin ở cột chẵn và cos ở cột lẻ; một phiên
nghiên cứu độc lập đã đặt sai dấu ở lần dẫn xuất đầu, nên đây là chỗ dễ nhầm.

**Cùng phiên nghiên cứu ấy báo một chuyện đáng ghi hơn**: nếu *hồi quy* `M_k`
bằng bình phương tối thiểu từ một cửa sổ vị trí hữu hạn thay vì dựng nó bằng
giải tích, kết quả trông như thể `M_k` phụ thuộc `pos`. Không phải thế. Ma trận
thiết kế có hạng 27 trên 64 và số điều kiện cỡ `5e18`, vì các chiều bước sóng
dài gần như không quay trên một trăm vị trí, nên bài toán khớp không xác định
được ở đó. Đây là cái bẫy chờ sẵn một người đọc tò mò tự kiểm bằng cách khớp.

**Tích vô hướng chỉ phụ thuộc khoảng cách.** Cột `spread` bằng 0 hoặc bằng
`1.91e-06` tới `3.81e-06`, tức nhiễu float. Tính chất này mạnh hơn cái bài phát
biểu: bài chỉ nói tồn tại một ánh xạ tuyến tính, còn đây nói tích vô hướng của
hai vị trí cách nhau `k` là một hàm của riêng `k`. Dạng đóng là
`sum_i cos(k * omega_i)`, và `pos` triệt tiêu vì
`sin(a)sin(b) + cos(a)cos(b) = cos(a-b)`.

**Nhưng nó không đơn điệu theo `k`, nên nó không mã hóa khoảng cách.** Đây là
chỗ cách giải thích lưu truyền đi quá xa so với bài:

```
d_model  k where it first rises again  value at k=1  min over k<200
32       5                             15.3136       2.2507 at k=161
64       6                             30.9168       7.0883 at k=172
512      44                            249.1021      86.3717 at k=199
```

Ở `d_model = 64`, tích giảm từ `32.000` ở `k = 0` xuống `23.504` ở `k = 5` rồi
**tăng lại** ở `k = 6`. Từ đó trở đi một giá trị của tích ứng với nhiều khoảng
cách khác nhau, nên không đọc ngược ra khoảng cách được. Ở `d_model = 512` chỗ
quay đầu là `k = 44`. Sách này chạy `d_model` 24 tới 32 và câu dài nhất 23
token, tức nằm gọn trong vùng đã quay đầu. Bài **không** phát biểu tính đơn
điệu; cái sai là ở cách kể lại, và chương 7 nói rõ chỗ đó.

**Dải bước sóng.**

```
d_model  shortest/2pi  longest/2pi  paper says  shortfall
64       1.0000        7498.94      10000.0     1.3335x
128      1.0000        8659.64      10000.0     1.1548x
512      1.0000        9646.62      10000.0     1.0366x
```

Bước sóng dài nhất công thức đạt tới là `2pi * 10000^((d-2)/d)`, không phải
`10000 * 2pi`. Ở `d_model = 512` chênh `1.0366` lần nên câu của bài gần đúng; ở
`d_model = 64` chênh `1.3335` lần. Câu \enquote{from 2pi to 10000 · 2pi} đúng
theo nghĩa tiệm cận chứ không đúng theo nghĩa đen.

## 6. Che tương lai

Đo bằng `experiments/ch07_mask.py` tại tag `ch07`. Output thô:

```
target of 10 positions; token at position 5 changed
max|change| in the logits at each output position

position  with mask       without mask
0         0.00000000      0.35483998   <- changed
1         0.00000000      0.08340538   <- changed
2         0.00000000      0.06716216   <- changed
3         0.00000000      0.06518483   <- changed
4         0.00000000      0.09080952   <- changed
5         1.69477415      1.61637926
6         0.14780316      0.07304358

what the leak costs, on the shared recipe: same seed, same batches
the unmasked decoder is scored the only way a decoder can be scored
at generation time, where there is no future to read

decoder self-attention  train loss  exact match (300 test)
masked (the paper)      0.0639      0.6533
unmasked                0.0434      0.0000

inside the softmax against after it, on the same scores

ordinary scores, max|inside - after| = 5.960e-08
scores [900, -900], keep the second only
  inside the softmax: [0.0, 1.0]
  after it:           [nan, nan]
```

**Phép can thiệp.** Đổi token đích ở vị trí 5, mọi vị trí trước đó đổi đúng bằng
`0.00000000`, không phải xấp xỉ 0. Bỏ mask đi thì cả năm vị trí đều động, nhiều
nhất `0.35483998` ở vị trí 0.

**Cái rò rỉ đáng giá bao nhiêu, và đây là số quan trọng nhất của mục.** Cùng
seed, cùng batch, cùng 14 epoch: mô hình có mask được mất mát huấn luyện `0.0639`
và khớp đúng cả câu `0.6533`; mô hình bỏ mask được mất mát huấn luyện **thấp
hơn**, `0.0434`, và khớp đúng cả câu **`0.0000`**. Không sai số nào, không cảnh
báo nào, không câu nào đúng. Mất mát tốt hơn vì mô hình học được cách đọc chính
đáp án; ở lúc sinh câu thì không có đáp án để đọc.

Ghi thêm: chạy thử ở 3 epoch thì mô hình bỏ mask có mất mát `0.6731`, *cao hơn*
mô hình có mask `0.5443`. Nghĩa là nó phải học lấy mới biết khai thác chỗ rò rỉ,
và một phép đo dừng sớm sẽ kết luận ngược. Số in trong sách là số ở 14 epoch.

**Che trong softmax hay che sau softmax.** Bài nói \enquote{in the input of the
softmax}. Đo được rằng che sau rồi chuẩn hóa lại cho **đúng cùng một kết quả**,
lệch `5.960e-08`, tức nhiễu float32. Chuyện đó là đại số chứ không phải may mắn:
hạn chế một softmax xuống một tập con rồi chuẩn hóa lại chính là softmax trên
tập con ấy, vì mẫu số chung triệt tiêu. Nên lý do phải che bên trong không phải
lý do toán học, nó là lý do số học: với hàng điểm `[900, -900]` mà chỉ giữ cột
thứ hai, che bên trong cho `[0.0, 1.0]` còn che bên ngoài cho `[nan, nan]`, vì
phần được giữ đã tràn xuống 0 trước khi kịp chuẩn hóa.

Một phiên nghiên cứu độc lập ra đúng kết luận ấy, và bổ sung rằng lỗi thật hay
gặp không phải \enquote{chuẩn hóa lại sau khi che} mà là **quên chuẩn hóa**;
phiên ấy đo được tổng một hàng còn `0.622` thay vì 1. Cũng phiên ấy xác nhận
hàng nào bị che sạch thì softmax trả về NaN; mask nhân quả có đường chéo nên
không bao giờ sinh ra hàng như thế.

## 7. Bảng trên corpus

Đo bằng `experiments/ch07_corpus.py` tại tag `ch07`. Recipe lấy nguyên từ
`seq2seq`: 6000 cặp huấn luyện, 300 cặp test, batch 128, Adam learning rate
0.005, clip 5.0, đảo câu nguồn, giải mã tham lam, chấm khớp đúng cả câu. Cùng
seed. Chỉ đổi kiến trúc và số epoch.

```
python 3.12.13 | torch 2.11.0+cpu | numpy 2.2.6 | Windows AMD64
train 6000 test 300 batch 128 lr 0.005, source reversed, greedy decoding

model        d     epochs  params   loss     exact    short    long
attention    32    14      40805    0.0088   1.0000   1.0000   1.0000
transformer  24    14      35845    0.1159   0.4700   0.8581   0.0921
transformer  24    28      35845    0.0148   0.8967   1.0000   0.7961
transformer  24    42      35845    0.0008   0.9967   1.0000   0.9934
transformer  24    56      35845    0.0001   0.9967   1.0000   0.9934

short = source of at most 11 tokens (148 of 300), long = the rest
elapsed 65.18s
```

**Hàng đối chứng tái lập chương 6 từng chữ số.** Bảng chương 6 ghi mô hình
attention ở `d_h = 32` với 40805 tham số, mất mát `0.0088`, khớp đúng `1.0000`,
`1.0000` và `1.0000`. Hàng đầu ở đây trùng cả năm số. Nếu nó lệch, mọi chênh
lệch phía dưới còn có thể là chênh lệch của môi trường chạy.

**Bốn hàng Transformer là một lần huấn luyện, chấm ở bốn thời điểm**, không phải
bốn lần huấn luyện riêng. Cùng trọng số, cùng thứ tự batch, cùng trạng thái
optimizer, nên hàng 14 epoch đúng bằng mô hình mà một lần chạy 14 epoch cho ra.

Đọc: ở 14 epoch, đúng recipe chương 6 dùng, Transformer được `0.4700` so với
`1.0000`, và trên câu dài chỉ `0.0921`. Ở 42 epoch nó được `0.9967` và đứng lại
đó ở 56. Số tham số của nó là 35845 so với 40805, tức nó là mô hình **nhỏ hơn**
ở mọi hàng.

Ba lần số epoch, ít tham số hơn, cùng một chỗ đến.

Ghi thêm một chuyện để không ai đọc bảng thành đường thẳng: mất mát giảm đơn
điệu qua bốn mốc (`0.1159`, `0.0148`, `0.0008`, `0.0001`) còn cột khớp đúng cả
câu thì không, vì một lần chạy riêng ở 28 epoch với `d_model = 32` cho `0.6033`
thấp hơn `0.6533` ở 14 epoch. Khớp đúng cả câu là tích của các xác suất từng
token nên nó nhảy chứ không đi mượt.

### Chẩn đoán: vì sao con số ở 14 epoch thấp

Ba phép đo phụ, chạy ngoài `verify.py`, để tách các cách giải thích:

```
test                   exact 0.6533  short 0.9730  long 0.3421  (n=300)
train (first 300)      exact 0.5967  short 0.9781  long 0.2761  (n=300)
teacher-forced token accuracy  all 0.9657  long 0.9499
```

1. **Không phải overfit.** Độ chính xác trên tập huấn luyện `0.5967` không cao
   hơn trên tập test `0.6533`. Mô hình chưa khớp nổi cả dữ liệu huấn luyện.
2. **Không phải hỏng plumbing.** Độ chính xác từng token khi được đưa prefix
   đúng là `0.9657` toàn tập và `0.9499` trên câu dài. Mô hình gần đúng ở mức
   token; khớp đúng cả câu phạt lũy thừa. `0.9499^19 = 0.3765` so với `0.3421`
   đo được trên câu dài, tức phần lớn khoảng cách giữa hai cột giải thích được
   chỉ bằng phép nhân dồn ấy.
3. **Không phải optimizer.** Bảy công thức learning rate thử ở `d_model = 32`,
   14 epoch:

```
recipe                     loss     exact    short    long     s
shared lr 0.005            0.0639   0.6533   0.9730   0.3421   14.1
lr 0.002                   0.0880   0.5267   0.8378   0.2237   20.8
lr 0.001                   0.1466   0.5000   0.9797   0.0329   23.6
lr 0.0005                  0.3503   0.3167   0.6419   0.0000   24.7
paper warmup 100           0.1108   0.4267   0.7365   0.1250   31.1
paper warmup 400           0.1089   0.5000   0.8446   0.1645   27.0
shared lr 0.005, 28ep      0.6033 exact, loss 0.0424, 58.1s
```

Recipe dùng chung đã là recipe tốt nhất trong bảy, kể cả so với lịch warmup của
chính bài (thu nhỏ `warmup_steps` cho vừa 658 bước huấn luyện). Nên chương 7
không được đổ cho optimizer, và chương 8 vẫn là chỗ đo warmup cho tử tế.

**Kiểu lỗi còn lại**, đọc từ output của chính mô hình ở 14 epoch:

```
src : a white bird finds an old lamp and the big bird wants a black horse
want: một con chim trắng tìm thấy một cái đèn cũ và con chim lớn muốn một con ngựa đen
got : một con chim trắng tìm thấy một cái đèn cũ và con ngựa lớn muốn một con chim đen

src : a dog carries a small horse and a bird carries the white horse in the garden
want: một con chó mang một con ngựa nhỏ và một con chim mang con ngựa trắng trong vườn
got : một con chó nhỏ mang một con ngựa và một con chim trắng mang con ngựa trong vườn
```

Mọi lỗi đều cùng một kiểu: đúng từ, sai cụm. Tính từ và danh từ có mặt đủ nhưng
gắn nhầm mệnh đề. Đó là chỗ mạng hồi quy có sẵn thiên kiến mà self-attention
không có, và nó là bản xem trước của khe hở mà chương 8 và chương 10 nhận.

### Số của phiên nghiên cứu độc lập

Một phiên khác dựng Transformer riêng của nó, `d_model = 64`, 2 tầng, 4 đầu,
`d_ff = 128`, dropout 0.1, Adam learning rate 0.001, cùng corpus và cùng seed 5:

```
epochs=14: loss 0.2715, exact 0.4933, 51.82s
epochs=40: loss 0.0732, exact 0.7800, 97.17s
epochs=55: loss 0.0449, exact 0.9200, 164.80s
epochs=80: loss 0.0138, exact 0.9867, 264.64s
```

Cấu hình khác của tôi nên không so trực tiếp được, nhưng chiều thì giống hệt và
nó là chiều quan trọng: mô hình **không** chạm trần, nó thiếu bước. Đó là lý do
bảng chính của chương quét số epoch chứ không quét bề rộng.

## 8. Nhiều đầu

Số tham số không đổi theo số đầu, vì `d_k = d_model / h`, nên bốn phép chiếu giữ
nguyên hình dạng. Kiểm trong `tests/test_ch07.py`.

Một phiên nghiên cứu độc lập đo thời gian chạy thật ở `d_model = 512`, `n = 128`,
batch 8, CPU 20 luồng, 30 lần sau 5 lần làm nóng:

```
   h    mean_ms     std_ms
   1     3.1920     0.1311
   2     3.3179     0.1725
   4     3.3420     0.1705
   8     3.7057     0.3243
  16     3.8436     0.2621
```

`h = 16` chậm hơn `h = 1` khoảng 20 phần trăm. Câu của bài, \enquote{the total
computational cost is similar}, đúng theo FLOP và không đúng theo đồng hồ, ít
nhất trên CPU với một cài đặt viết tay chia đầu bằng reshape. Chương 7 chỉ nói
FLOP và giao đồng hồ cho chương 8, vì con số này phụ thuộc cài đặt và phần cứng
đủ để không nên in thành một phát biểu chung.

## 9. Hai bài cầu nối, và một lỗi tự bắt được

Hai hộp cầu nối của mục 7.5 lúc đầu viết theo tóm tắt của một phiên nghiên cứu
phụ chứ không theo bài. Cả hai đều phải sửa, và cách chúng sai thì đáng ghi hơn
bản thân chỗ sai.

### He và cộng sự 2015

Bản dùng: arXiv:1512.03385v1, 10 Dec 2015. Đọc trang 1, tức tóm tắt, mục 1 và
hình 1.

Bản nháp đầu viết rằng mạng 56 tầng có lỗi huấn luyện cao hơn mạng 20 tầng
\enquote{và đó không phải overfit vì lỗi huấn luyện cũng cao hơn}, tức một câu
vòng tròn: nó lấy chính điều cần giải thích làm lý do. Đọc bài thì thấy lập luận
thật gọn hơn và sắc hơn. Chú thích hình 1, nguyên văn:

> Training error (left) and test error (right) on CIFAR-10 with 20-layer and
> 56-layer "plain" networks. The deeper network has higher training error, and
> thus test error.

Và mục 1:

> such degradation is not caused by overfitting, and adding more layers to a
> suitably deep model leads to higher training error

Overfit đẩy lỗi kiểm tra lên trong khi lỗi huấn luyện đi xuống; ở đây cả hai
cùng lên, nên overfit không giải thích được. Đó là câu chương 7 in ra bây giờ.

### Ba, Kiros và Hinton 2016

Bản dùng: arXiv:1607.06450. Trang abs của arXiv, đọc ngày 2026-08-11, cho thấy
**đúng một phiên bản v1 ngày 21 Jul 2016, không có trường DOI và không có dòng
journal reference nào**. Nên câu \enquote{chưa từng xuất bản chính thức} là câu
đọc được từ chính trang ấy chứ không phải từ trí nhớ.

Đọc ở mức tóm tắt, và mọi câu chương 7 trích đều nằm trong tóm tắt:

> we transpose batch normalization into layer normalization by computing the
> mean and variance used for normalization from all of the summed inputs to the
> neurons in a layer on a single training case

> the effect of batch normalization is dependent on the mini-batch size and it
> is not obvious how to apply it to recurrent neural networks

> Unlike batch normalization, layer normalization performs exactly the same
> computation at training and test times.

Bản nháp đầu nói thêm rằng batch norm phải giữ thống kê riêng cho từng bước
thời gian và một câu dài hơn mọi câu đã gặp thì không có thống kê cho các bước
cuối. Câu ấy đúng theo hiểu biết chung nhưng **không** có trong phần tôi đọc, và
tóm tắt còn nói chuyện gần ngược lại: chính \emph{layer} norm mới là thứ tính
thống kê riêng ở từng bước thời gian một cách dễ dàng. Đã bỏ, thay bằng ba câu
trích trên.

**Bài học chung của cả hai**: hộp cầu nối là văn xuôi nói về một bài báo, nên nó
phải được kiểm tận nguồn đúng như một con số, và trường `note` trong `refs.bib`
khai mình đọc tới mục nào thì bản thân dòng ấy cũng là một tuyên bố phải đúng.
Cả hai `note` đều đã bị sửa trong phiên này vì lần viết đầu khai quá tay.

## 10. Việc còn nợ

- Thống kê `q.k` **sau** khi huấn luyện chưa đo. Mục 4 chỉ nói lúc khởi tạo.
- Chưa đo `d_model` lớn hơn 64 ở số epoch cao; bảng dừng ở chỗ ngân sách dừng.
- Bảng 4 và mục 6.3 của bản arXiv chưa đọc kỹ, vì chương 7 không dùng tới và
  bản kỷ yếu không có chúng.
