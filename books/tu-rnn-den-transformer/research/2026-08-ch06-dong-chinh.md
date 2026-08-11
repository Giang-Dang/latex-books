# Chương 06: Một vector cho mỗi từ (Bahdanau, Cho, Bengio 2015)

Ghi ngày 2026-08-11.

Ghi chú nguồn và số đo cho chương 6. Mọi số thập phân chương 6 in ra đều phải
có mặt ở đây (quyết định 20 trong SPEC).

## Ba bài đã đọc trong phiên này

### 1. Bài chính: Bahdanau, Cho, Bengio 2015

File đọc: `3. Neural Machine Translation by Jointly Learning to Align and
Translate.pdf`, thư mục ghi trong `2026-08-nguon-sau-bai-bao.md`. Bản
arXiv:1409.0473v7, cs.CL, đề ngày 19 May 2016, 15 trang, 444482 byte.

Kiểm lại vân tay trước khi đọc, bằng `Get-FileHash -Algorithm SHA256`:

```
84801C8410DA51B449D379D2FA4939A416123F2C93991077A680F863026022A7
```

Khớp với manifest. Trang bìa ghi **Published as a conference paper at ICLR
2015**, nên chương 6 không mang món nợ venue mà chương 3 và chương 5 đã phải
trả.

**Bẫy ngày tháng, giống bài Vaswani.** Bản arXiv v7 đề 19 May 2016, sau hội
nghị ICLR 2015 một năm. Manifest đã cảnh báo. Chương không được viết "các tác
giả viết năm 2015 rằng" cho câu chữ lấy từ file này mà chưa đối chiếu.

### 2. Cho và cộng sự 2014b, đọc toàn văn (món nợ SPEC giao cho chương 6)

SPEC ghi bài này mới chỉ đọc tới tóm tắt. Nay đọc hết. Hai bản đã tải:

| Bản | URL | Byte | SHA-256 |
|-----|-----|------|---------|
| arXiv:1409.1259v2, 7 Oct 2014 | `arxiv.org/pdf/1409.1259` | 364541 | `0a947ddd0fa96198d776f6a9f5e59f37b0965e9658eea41e4b574c25f2842528` |
| ACL Anthology W14-4012 | `aclanthology.org/W14-4012.pdf` | 310196 | `f86daf916fcd28b24e8493545925421b925a7b60ee0a73c2e1e72f634a580226` |

Cả hai 9 trang. Bản ACL đánh số trang in 103 tới 111, khớp trường `pages` trong
file `.bib` mà chính Anthology xuất ra (đọc ngày 2026-08-11):

```
booktitle = "Proceedings of SSST-8, Eighth Workshop on Syntax, Semantics and
             Structure in Statistical Translation"
month = oct, year = "2014", address = "Doha, Qatar",
publisher = "Association for Computational Linguistics",
doi = "10.3115/v1/W14-4012", pages = "103--111"
```

**Một cái bẫy công cụ, ghi lại vì nó suýt làm hỏng phần đọc.** Lệnh `file` báo
cả hai PDF là 6 trang, và lần trích đầu tiên chỉ lấy được 6 trang: đúng chỗ
thân bài đứt giữa câu "In fact, if we limit the lengths of both the source".
Cây trang của hai file này bị chẻ (`/Count 6`, `/Count 3`, `/Count 9`), nên một
bộ đếm chỉ đọc `/Count` đầu tiên sẽ báo thiếu. Đếm `/Type /Page` cho ra 9. Ba
trang bị bỏ sót chứa **hình 4, hình 5, hình 6 và toàn bộ mục 5.2 với phần kết
luận**, tức đúng phần chương 6 cần. Nếu tin `file`, chương này đã viết mà không
có đường cong BLEU theo độ dài câu.

Cách kiểm: đếm `/Type /Page` trong byte thô, đừng tin số trang một công cụ báo.

#### Số của bài 2014b

Bảng 1, điểm BLEU trên tập test (news-test2014):

```
                All lengths          10-20 words
model      dev     test         dev     test
RNNenc     13.15   13.92        19.12   20.99
grConv      9.97    9.97        16.60   17.50
Moses      30.64   33.30        28.92   32.00
No UNK:
RNNenc     21.01   23.45        24.73   27.03
grConv     17.19   18.22        21.74   22.94
Moses      32.77   35.63        32.20   35.40
```

Chú thích bảng: hàng `Moses+RNNenc` 31.48/34.64 là kết quả của Cho 2014a dùng
RNNenc chấm điểm lại phrase table; hàng `Moses+LSTM` 32/35.65 là kết quả của
Sutskever 2014 xếp hạng lại n-best của Moses.

**Ba hiệu số chương in ra, và phép trừ đứng sau mỗi cái.** Không phải số đo,
là số học trên số của bài, nhưng chúng vẫn là số thập phân in ra giấy nên
chúng phải trace về đâu đó, và chỗ đó là đây:

```
toan bo, moi do dai:   33.30 - 13.92 = 19.38
cau 10-20 tu:          32.00 - 20.99 = 11.01
cau 10-20 tu, khong UNK: 35.40 - 27.03 =  8.37
```

Cả ba đều là khoảng cách Moses trừ RNNenc trên cột `test`, và cả ba đọc theo
một chiều: siết điều kiện lại thì khoảng cách co lại.

Ghi thêm một chuyện về chính cái gate đang đọc file này. `8.37` **lọt** qua
`number` check mà không cần dòng trên, vì `research/2026-08-09-ch02-symptoms.md`
có một giá trị loss 8.3705 ở `T_mem=20`. Một số của chương 6 trace về một phép
đo của chương 2 chẳng liên quan gì. Đúng cái lỗ mà SPEC đã ghi trong writing
rules: check chỉ hỏi con số **có mặt** ở đâu đó trong `research/`, không hỏi nó
có mặt ở chỗ đúng. `19.38` thì không may mắn thế nên nó fires, và đó là lý do
duy nhất tôi biết ba con số này cần được ghi lại.

**Câu quan trọng nhất với chương 6**, mục 5.1, chép nguyên:

> "In fact, if we limit the lengths of both the source sentence and the
> reference translation to be between 10 and 20 words and use only the
> sentences with no unknown words, the BLEU scores on the test set are 27.81
> and 33.08 for the RNNenc and Moses, respectively."

Và ngay sau đó:

> "Note that we observed a similar trend even when we used sentences of up to
> 50 words to train these models."

Câu thứ hai đáng giá ngang câu thứ nhất: độ tụt **không phải** hệ quả của việc
huấn luyện trên câu ngắn. Mô hình chính trong bài huấn luyện trên câu tối đa 30
từ, và người ta dễ bác kết quả bằng cách nói mô hình chưa từng thấy câu dài.
Bài đã chặn đường đó.

Hình 4(a): BLEU của RNNenc theo độ dài câu, làm trơn bằng cửa sổ 10. Đỉnh
khoảng 20 điểm ở độ dài 10 tới 15, xuống gần 0 ở độ dài 70 tới 80. Hình 4(c):
BLEU theo số từ ngoài từ điển, từ khoảng 24 xuống khoảng 14. Hình 5: cùng phép
đo cho hệ Moses, đường đi **ngang và hơi lên**, nằm trong dải 30 tới 35 suốt
mọi độ dài. Đây là hình làm cho kết quả có nghĩa: không phải câu dài khó với
mọi hệ, mà là câu dài khó với hệ nơ-ron này.

Cả ba là hình vẽ, không có bảng số phía sau, nên **chương chỉ được mô tả hình
dạng, không được trích số từ trục**. Hai con số 27.81 và 33.08 ở trên là số duy
nhất trong phần độ dài câu mà bài viết thành chữ.

**Giả thuyết bài đưa ra, mục 5.1**, chép nguyên:

> "The most obvious explanatory hypothesis is that the fixed-length vector
> representation does not have enough capacity to encode a long sentence with
> complicated structure and meaning. In order to encode a variable-length
> sequence, a neural network may "sacrifice" some of the important topics in
> the input sentence in order to remember others."

**Nhưng kết luận của chính bài lại đổ cho chỗ khác**, mục 6:

> "Despite the radical difference in the architecture between RNN and grConv
> which were used as an encoder, both models suffer from the curse of sentence
> length. This suggests that it may be due to the lack of representational
> power in the decoder."

Hai câu này không cùng chỉ vào một chỗ: mục 5.1 chỉ vào vector cố định, mục 6
chỉ vào decoder. Bài Bahdanau sửa ở phía encoder. Đây là chỗ đáng viết ra trong
chương, và **phải viết cẩn thận**: đây không phải bài tự mâu thuẫn. Mục 6 lập
luận rằng vì cả hai encoder rất khác nhau đều hỏng như nhau nên lỗi có thể nằm
ở phần dùng chung, tức decoder. Lập luận ấy hợp lý và hoá ra không phải chỗ mà
lời giải đến từ. Ba trong bốn tác giả của 2014b (Cho, Bahdanau, Bengio) là tác
giả của bài 2015.

Thiết lập của 2014b: corpus 348M từ chọn bằng phương pháp Axelrod, chỉ dùng cặp
câu mà cả hai phía dài tối đa 30 từ, 30000 từ thường gặp nhất mỗi phía. RNNenc
1000 nơ-ron ẩn, grConv 2000, embedding 620 chiều cả hai. Khoảng 110 giờ huấn
luyện, tương đương 296144 lần cập nhật cho grConv và 846322 cho RNNenc.
Beam-search bề rộng `s = 10`.

**Một chi tiết đáng đối chiếu với chương 5.** Mục 4.2.1 của 2014b: họ **có**
chuẩn hoá điểm theo độ dài, "we do not use a usual log-probability but one
normalized with respect to the length of the translation. This prevents the RNN
decoder from favoring shorter translations". Chương 5 đo phép chuẩn hoá ấy trên
corpus đồ chơi và thấy nó không đổi một chữ số nào. Không mâu thuẫn: chương 5
đã nói rõ đó là bản vá cho một lỗi mà corpus đồ chơi không có. Ghi lại vì đây
là bằng chứng rằng lỗi ấy có thật ở quy mô thật.

### 3. Luong, Pham, Manning 2015, cho hộp cầu nối

Bản ACL Anthology D15-1166, EMNLP 2015, Lisbon, trang 1412-1421,
DOI 10.18653/v1/D15-1166. SHA-256:

```
e8aca09523b8807edcafb48b8ee9fa60478e9be3a3682f9ffa61fd00de40e79a
```

Đọc trang 1412-1419. Ba chỗ khác Bahdanau, bài tự liệt kê ở mục 3.1 dưới đề
mục "Comparison to (Bahdanau et al., 2015)":

1. Luong dùng trạng thái tầng LSTM trên cùng ở cả encoder lẫn decoder; Bahdanau
   dùng nối trạng thái xuôi và ngược của encoder hai chiều, decoder một chiều
   không xếp tầng.
2. Đường tính của Luong là `h_t -> a_t -> c_t -> h~_t`; của Bahdanau là
   `h_{t-1} -> a_t -> c_t -> h_t`, rồi qua deep output và một tầng maxout.
   **Tức Bahdanau chấm điểm bằng trạng thái *trước* bước, Luong bằng trạng thái
   *sau*.**
3. Bahdanau chỉ thử một hàm chấm điểm, `concat`; Luong thử bốn.

Ba hàm content-based của Luong, mục 3.1 phương trình (8):

```
dot      h_t^T h~_s
general  h_t^T W_a h~_s
concat   W_a [h_t ; h~_s]
```

cộng một hàm location-based, phương trình (9): `a_t = softmax(W_a h_t)`.

Bảng 4, WMT'14 Anh-Đức, newstest2014:

```
model              ppl    BLEU before  BLEU after unk
global (location)  6.4    18.1         19.3
global (dot)       6.1    18.6         20.5
global (general)   6.1    17.3         19.1
local-m (general)  6.2    18.6         20.4
local-p (dot)      6.6    18.0         19.6
local-p (general)  5.9    19           20.9
```

Kết luận của mục 5.3: `dot` hợp với global, `general` hợp với local. Và một câu
chương nên trích, vì nó nói về đúng hàm mà Bahdanau chọn:

> "For content-based functions, our implementation of concat does not yield
> good performances and more analysis should be done to understand the reason."

Chú thích 15 cho số: perplexity của concat là 6.7 (global), 7.1 (local-m), 7.1
(local-p).

Bảng 6, alignment error rate trên 508 câu Europarl Anh-Đức của RWTH:

```
global (location)  0.39
local-m (general)  0.34
local-p (general)  0.36
ensemble           0.34
Berkeley Aligner   0.32
```

Kèm câu này, mục 5.4, đáng giá cho mục ma trận đồng chỉnh của chương 6:

> "The AER obtained by the ensemble, while good, is not better than the local-m
> AER, suggesting the well-known observation that AER and translation scores
> are not well correlated (Fraser and Marcu, 2007)."

Nghĩa là một ma trận đồng chỉnh đẹp **không** phải bằng chứng bản dịch tốt hơn.
Chương 6 in một ma trận đẹp, nên chương 6 phải nói câu đó ra.

Số khác của Luong: tăng 5.0 BLEU so với hệ không attention đã có dropout và đảo
câu nguồn; ensemble 8 mô hình đạt 23.0 BLEU WMT'14 Anh-Đức, hơn Jean et al.
2015 (21.6) 1.4 điểm; WMT'15 Anh-Đức đạt 25.9 so với 24.9 của hệ tốt nhất
trước đó. Hệ thắng WMT'14 phrase-based có LM lớn đạt 20.7.

## Bài chính: những gì đọc thẳng từ bài

### Kiến trúc, mục 3 và phụ lục A

Phương trình (4): `p(y_i | y_1..y_{i-1}, x) = g(y_{i-1}, s_i, c_i)`, với
`s_i = f(s_{i-1}, y_{i-1}, c_i)`.

Phương trình (5): `c_i = sum_{j=1}^{Tx} alpha_ij h_j`.

Phương trình (6): `alpha_ij = exp(e_ij) / sum_k exp(e_ik)`, `e_ij = a(s_{i-1}, h_j)`.

Phụ lục A.1.2, mô hình đồng chỉnh:

```
a(s_{i-1}, h_j) = v_a^T tanh(W_a s_{i-1} + U_a h_j)
W_a in R^{n' x n},  U_a in R^{n' x 2n},  v_a in R^{n'}
```

Câu mở đầu phụ lục A.1.2, tức lý do bài chọn một tầng ẩn chứ không chọn thứ gì
nặng hơn, chép nguyên:

> "The alignment model should be designed considering that the model needs to
> be evaluated `T_x x T_y` times for each sentence pair of lengths `T_x` and
> `T_y`. In order to reduce computation, we use a single-layer multilayer
> perceptron."

Đây là chỗ đầu tiên trong bài nhắc tới tích `T_x x T_y`, và mục 6.1 là chỗ thứ
hai, nơi bài gọi nó là `drawback`. Hai chỗ ấy cách nhau sáu trang và chương 6
đọc chúng cùng nhau.

Và ngay sau đoạn trên, câu biện minh cho phép tối ưu duy nhất bài nêu:

> "Since U_a h_j does not depend on i, we can pre-compute it in advance to
> minimize the computational cost."

Phương trình (7), encoder hai chiều: `h_j = [forward_h_j ; backward_h_j]`. Ma
trận embedding `E` **dùng chung** giữa hai chiều, còn ma trận trọng số thì
không ("We share the word embedding matrix E between the forward and backward
RNNs, unlike the weight matrices").

Phụ lục A.2.2: `s_0 = tanh(W_s backward_h_1)`. Trạng thái khởi tạo của decoder
lấy từ chiều **ngược**, ở vị trí nguồn 1, tức trạng thái cuối của RNN ngược.

Phụ lục A.2.3, kích thước: `n = 1000` đơn vị ẩn, `m = 620` chiều embedding,
`l = 500` cho tầng maxout, `n' = 1000` cho mô hình đồng chỉnh.

Phụ lục B.1, khởi tạo: ma trận hồi quy khởi tạo trực giao ngẫu nhiên; `W_a` và
`U_a` lấy từ `N(0, 0.001^2)`; **`v_a` và mọi vector bias khởi tạo bằng 0**; mọi
ma trận khác từ `N(0, 0.01^2)`.

Phụ lục B.2: SGD với Adadelta (`eps = 1e-6`, `rho = 0.95`), cắt chuẩn L2 của
gradient ở ngưỡng 1, minibatch 80 câu, huấn luyện khoảng 5 ngày.

**Một câu cho phép chương thay GRU bằng LSTM**, phụ lục A.1.1:

> "It is therefore possible to use LSTM units instead of the gated hidden unit
> described here, as was done in a similar context by Sutskever et al. (2014)."

Đây là chỗ bài tự cho phép, nên module companion dùng `LstmLayer` của chương 5
là đi theo bài chứ không phải lệch khỏi bài.

**Một câu nữa, cùng phụ lục, cho biết mô hình này rút về chính chương 5 khi
nào**: "Note that the model becomes RNN Encoder-Decoder (Cho et al., 2014a), if
we fix c_i to forward_h_Tx."

### Số của bài, bảng 1 và bảng 2

Bảng 1, BLEU trên tập test:

```
model           All     No UNK
RNNencdec-30    13.93   24.19
RNNsearch-30    21.50   31.44
RNNencdec-50    17.82   26.71
RNNsearch-50    26.75   34.16
RNNsearch-50*   28.45   36.15
Moses           33.30   35.63
```

Chỗ đáng dừng lại: **RNNsearch-30 (21.50) hơn RNNencdec-50 (17.82)**. Mô hình
attention huấn luyện trên câu tối đa 30 từ vượt mô hình vector cố định huấn
luyện trên câu tối đa 50 từ. Bài nói thẳng chỗ ấy ở cuối mục 5.1.

Bảng 2, thống kê huấn luyện:

```
model          updates(x1e5)  epochs  hours  GPU            train NLL  dev NLL
RNNenc-30      8.46           6.4     109    TITAN BLACK    28.1       53.0
RNNenc-50      6.00           4.5     108    Quadro K-6000  44.0       43.6
RNNsearch-30   4.71           3.6     113    TITAN BLACK    26.7       47.2
RNNsearch-50   2.88           2.2     111    Quadro K-6000  40.7       38.1
RNNsearch-50*  6.67           5.0     252    Quadro K-6000  36.7       35.2
```

Dữ liệu: WMT'14 Anh-Pháp, 348M từ sau khi chọn bằng phương pháp Axelrod từ 850M
(Europarl 61M, news commentary 5.5M, UN 421M, hai corpus crawl 90M và 272.5M).
Tập test news-test-2014, 3003 câu. Shortlist 30000 từ mỗi thứ tiếng.

### Ba câu về bản chất, để chương trích

Tóm tắt, chỗ nêu vấn đề:

> "we conjecture that the use of a fixed-length vector is a bottleneck in
> improving the performance of this basic encoder-decoder architecture"

**Chữ "conjecture" là chữ của bài.** Bài không tự đo chỗ thắt bằng cách thu hẹp
vector; nó dẫn Cho 2014b và Pouget-Abadie 2014 làm bằng chứng thực nghiệm (mục
7), rồi đề xuất cách sửa. Chương 5 của sách này mới là chỗ đo bằng cách thu
hẹp. Chương 6 không được viết như thể bài Bahdanau đã đo chuyện đó.

Chú thích 2, trang 2, câu ngắn mà là toàn bộ ý tưởng:

> "Although most of the previous works ... used to encode a variable-length
> input sentence into a fixed-length vector, it is not necessary, and even it
> may be beneficial to have a variable-length vector, as we will show later."

Mục 6.1, chỗ bài tự nêu cái giá, và là hạt giống của chương 8 và chương 12:

> "Our approach, on the other hand, requires computing the annotation weight of
> every word in the source sentence for each word in the translation. This
> drawback is not severe with the task of translation in which most of input
> and output sentences are only 15-40 words. However, this may limit the
> applicability of the proposed scheme to other tasks."

Tức `Tx * Ty` phép chấm điểm, và bài **biết** điều đó, gọi nó là hạn chế, rồi
gạt đi bằng lý do quy mô câu. Đúng chỗ Transformer sẽ đẩy tới bậc hai theo độ
dài.

Mục 5.2.1, về đồng chỉnh mềm so với cứng, cho cụm "the man" dịch thành
"l' homme":

> "Any hard alignment will map [the] to [l'] and [man] to [homme]. This is not
> helpful for translation, as one must consider the word following [the] to
> determine whether it should be translated into [le], [la], [les] or [l']."

Và: đồng chỉnh mềm xử lý được cụm nguồn và cụm đích khác độ dài "without
requiring a counter-intuitive way of mapping some words to or from nowhere
([NULL])". Câu này khớp thẳng với loại từ tiếng Việt trong corpus của sách: một
từ đích không ứng với từ nguồn nào.

## Số đo của tôi, tag `ch06`

Máy: xem dòng `describe_environment()` ở đầu mỗi output, `python 3.12.13 |
torch 2.11.0+cpu | numpy 2.2.6 | Windows AMD64`.

Cấu hình dùng chung, lấy nguyên từ `seq2seq.py` của chương 5 chứ không đặt lại:
6000 cặp train, 300 cặp test, batch 128, 14 epoch, learning rate 0.005 với
Adam, cắt gradient ở norm 5.0, embedding 32 chiều. Ngưỡng câu ngắn 11 token,
đúng ngưỡng chương 5, đặt trước khi nhìn kết quả. Trong 300 câu test có 148 câu
ngắn và 152 câu dài.

### Bảng bề rộng, `experiments/ch06_width.py`

Chạy `python experiments/ch06_width.py`. Nguồn đảo, giải mã tham lam, một seed
(seed 0) mỗi dòng.

```
d_hidden  model      params   loss     exact    short    long
16        fixed      9173     0.8733   0.0033   0.0068   0.0000
16        attention  15413    0.5933   0.0600   0.1216   0.0000
32        fixed      20133    0.5584   0.1433   0.2905   0.0000
32        attention  40805    0.0088   1.0000   1.0000   1.0000
64        fixed      54341    0.1429   0.5200   0.9797   0.0724
64        attention  128453   0.0019   0.9967   1.0000   0.9934

short = source of at most 11 tokens (148 of 300), long = the rest
```

**Ba dòng `fixed` tái lập đúng bảng chương 5**, từng chữ số và kể cả cột loss:
chương 5 in 0.8733/0.0033 ở 16, 0.5584/0.1433 ở 32, 0.1429/0.5200 ở 64, cùng
short và long. Đây là phép kiểm rằng hai chương đặt số cạnh nhau được. Chương 5
còn có 4 (0.0000), 8 (0.0000) và 128 (loss 0.0251, exact 0.8533, short 1.0000,
long 0.7105), lấy từ note chương 5.

Cột loss là trung bình 20 batch cuối, `sum(losses[-20:]) / 20`, đúng cách chương
5 tính. Lần đo nháp đầu tiên tôi in `losses[-1]` và ra 0.7378 / 0.4655 / 0.3752
/ 0.0067 / 0.0372 / 0.0015; những số đó **không** phải số của bảng và ghi ra đây
để không ai nhặt nhầm chúng.

Đo riêng ngoài script, để biết attention hỏng ở đâu (không in trong sách trừ
khi cần): attention ở `d_h = 4` cho 4433 tham số và exact 0.0000; ở `d_h = 8`
cho 7325 tham số và 0.0000. Vậy attention **không** cứu được mọi bề rộng. Ngưỡng
của nó nằm giữa 16 và 32, và dưới ngưỡng ấy nó hỏng vì trạng thái decoder quá
hẹp, không phải vì đường về câu nguồn.

Con số so sánh chéo mà chương dùng: attention ở `d_h = 32` (40805 tham số,
1.0000) so với fixed ở `d_h = 128` (171909 tham số, 0.8533). Ít hơn 4.2 lần
tham số và cao hơn.

### Đường gradient, `experiments/ch06_gradient.py`

Đo **tại khởi tạo, chưa huấn luyện**. `d_hidden = 32`, cùng seed cho cả hai mô
hình nên embedding xuất phát giống nhau. Lấy loss ở riêng một bước đích, bước
5, rồi đọc chuẩn của gradient tới embedding của từng từ nguồn. Chọn bước 5 chứ
không bước 0 vì trạng thái khởi tạo của decoder dựng từ encoder bằng một đường
riêng, nên bước 0 có thêm một lối mà các bước sau không có.

```
source_len  fixed min/max  attention min/max  ratio
5           0.237278       0.853556           3.6x
9           0.113478       0.626161           5.5x
14          0.028660       0.554965           19.4x
18          0.012126       0.604488           49.9x
21          0.005483       0.586938           107.0x
```

Đây là bảng quan trọng nhất của chương. Cột `fixed` **tụt theo độ dài câu**, từ
0.237278 ở câu 5 token xuống 0.005483 ở câu 21 token, tức hơn 43 lần. Cột
`attention` **đứng yên** trong dải 0.55 tới 0.86. Tỷ số giữa hai cột đi từ 3.6
lên 107.0.

Profile trên câu test dài nhất, 21 token, mỗi cột chia cho phần tử lớn nhất của
chính nó:

```
j   source word   fixed     attention
1   a             0.0055    0.6493
2   big           0.0069    0.6951
3   cat           0.0069    0.7488
4   carries       0.0130    0.9483
5   a             0.0134    0.6718
6   white         0.0162    0.7804
7   book          0.0229    0.7809
8   in            0.0336    0.7891
9   the           0.0481    0.7796
10  garden        0.0471    0.7056
11  and           0.0734    0.8282
12  a             0.0803    0.7465
13  small         0.1111    0.7344
14  dog           0.1781    0.8336
15  carries       0.2186    1.0000
16  a             0.2391    0.6914
17  big           0.3990    0.7692
18  cat           0.3895    0.8106
19  at            0.6097    0.7753
20  the           0.7639    0.6209
21  window        1.0000    0.5869
```

Cột `fixed` tăng gần đều từ đầu câu tới cuối câu và chỉ đạt 1.0000 ở token cuối,
đúng chỗ encoder dừng. Cột `attention` không có xu hướng nào.

Ba lần đo thêm ở các bước đích khác, `d_h = 32`, câu 21 token, để chắc bước 5
không phải chỗ đặc biệt (không in trong sách):

Đo bằng một đoạn rời chứ không bằng script trong tag, nên chép ra đúng số chữ
số mà nó in, bốn chữ số có nghĩa:

```
target step  fixed min/max  attention min/max
0            5.034e-03      2.284e-01
5            5.483e-03      5.869e-01
10           1.922e-02      5.302e-01
```

### Ma trận đồng chỉnh, `experiments/ch06_alignment.py`

Một mô hình, `d_h = 32`, 14 epoch, **nguồn không đảo** (để ma trận đọc xuôi).
loss 0.0075, exact 0.9967.

Câu in trong sách: `the black cat wants a new lamp`.

```
target        1     2     3     4     5     6     7
con        0.07  0.15  0.39  0.38  0.01  0.00  0.00
mèo        0.00  0.04  0.95  0.01  0.00  0.00  0.00
đen        0.00  0.82  0.15  0.03  0.00  0.00  0.00
muốn       0.00  0.00  0.00  0.99  0.01  0.00  0.00
một        0.00  0.00  0.00  0.05  0.95  0.00  0.00
cái        0.00  0.00  0.00  0.00  0.00  0.05  0.95
đèn        0.00  0.00  0.00  0.00  0.00  0.18  0.82
mới        0.00  0.00  0.00  0.00  0.00  0.98  0.02
```

Cột 1 tới 7 là `the black cat wants a new lamp`.

Hai chỗ bắt chéo: `mèo` nhìn `cat` (vị trí 3, 0.95) rồi `đen` nhìn `black` (vị
trí 2, 0.82); `đèn` nhìn `lamp` (vị trí 7, 0.82) rồi `mới` nhìn `new` (vị trí 6,
0.98). Đường chéo không làm được chuyện đó.

Hai loại từ hành xử khác nhau và chỗ ấy đáng đọc. `cái` dồn 0.95 vào `lamp`,
tức nó bám vào danh từ mà nó phân loại. Còn `con` thì tản: 0.39 vào `cat`, 0.38
vào `wants`, 0.15 vào `black`. Loại từ không ứng với từ tiếng Anh nào, nên đây
đúng là trường hợp Bahdanau mô tả ở mục 5.2.1, chỗ đồng chỉnh mềm khỏi phải ánh
xạ một từ tới `[NULL]`.

Phép đo định lượng, trên toàn bộ 300 câu test, đi theo output của chính mô hình
chứ không theo câu tham chiếu:

```
noun-adjective pairs in the model's own output: 625
of those, adjective attends left of the noun: 609
crossing rate: 0.9744
```

Một đồng chỉnh đường chéo cho 0.0000 ở phép đo này, theo cấu tạo.

### Encoder hai chiều và phép đảo câu, `experiments/ch06_encoder.py`

```
encoder        d_h  source    params  exact   short   long
bidirectional  32   raw       40805   0.9967  1.0000  0.9934
bidirectional  32   reversed  40805   1.0000  1.0000  1.0000
forward only   32   raw       27365   0.9500  0.9932  0.9079
forward only   32   reversed  27365   0.8667  0.9932  0.7434
forward only   42   raw       41495   1.0000  1.0000  1.0000
```

Bảng này **không** có cột `loss`, khác hai bảng kia của chương, và đó là chuyện
sắp chữ chứ không phải chuyện đo. Bản đầu có cột loss (0.0075, 0.0088, 0.0964,
0.0903, 0.0218) và dòng rộng nhất dài 71 ký tự. Sách đặt bảng này trong hộp
`measured`, mà bề rộng bên trong hộp hẹp hơn bề rộng trang khoảng ba cột, nên
71 ký tự bị ngắt dòng ngay trên trang in. `Listings.MaxLineLength = 73` không
thấy: nó đo theo bề rộng trang. Đọc bản PDF mới thấy. Bỏ cột loss là cách thu
hẹp ở nguồn, đúng luật của quyết định 31, và không mục nào của chương đọc con
số loss của bảng này.

Hai kết quả, và cái thứ hai là cái tôi không đoán trước.

**Phép đảo câu nguồn hết tác dụng.** Với encoder hai chiều, đảo được 0.0033
(0.9967 lên 1.0000). Chương 5 đo được 0.1789 trung bình trên ba seed, toàn bộ
rơi vào câu dài. Đúng dự đoán của lập luận khoảng cách: không còn đường dài nào
để rút ngắn.

**Còn chiều ngược thì không đáng đồng nào trên corpus này.** Đọc thô thì
bidirectional (0.9967) hơn forward only (0.9500) và phần hơn nằm ở câu dài
(0.9934 so với 0.9079). Nhưng bidirectional có 40805 tham số còn forward only
có 27365, nên phép so ấy lẫn "đọc hai chiều" với "to hơn". Dòng cuối là phép
đối chứng: forward only ở `d_h = 42` có 41495 tham số, hơn bidirectional 1.7%,
và đạt **1.0000**. Vậy phần hơn là phần tham số, không phải phần chiều ngược.

**Chuyện này không bác bài báo, nó bác corpus.** Mục 3.2 muốn annotation tóm
tắt cả từ đứng sau, và lý do là ngữ nghĩa: cần ngữ cảnh phải để gỡ nhập nhằng.
Văn phạm của corpus này **không có nhập nhằng nào** - docstring của
`toy_corpus.py` đã ghi từ chương 5: không hình thái, không hợp giống số, không
nhập nhằng, không từ hiếm. Một corpus không có nhập nhằng thì không thể cho
thấy chiều ngược dùng để làm gì. Chương phải nói ra chuyện đó chứ không được
trình bày dòng cuối như một phát hiện về bài báo.

Chọn `d_h = 42` bằng cách đếm tham số trước, không huấn luyện:

```
d_h  params (forward only)
32   27365
34   29951
36   32657
38   35483
40   38429
42   41495
44   44681
```

`42` là chỗ gần 40805 nhất từ phía trên.

**Một chỗ nữa: forward only + đảo câu thì *hại*.** 0.9500 xuống 0.8667, và chỗ
mất nằm gọn ở câu dài, 0.9079 xuống 0.7434. Câu ngắn không đổi (0.9932 cả hai).
Chưa đo được cơ chế; đây là quan sát, chương ghi nó như quan sát và bài tập
tier ba hỏi lại.

### Thời gian chạy và ngân sách

Lần chạy `verify.py` đầy đủ ở tag `ch06`, cùng máy, cùng ngày:

```
[ok  ] chapter 6 tests                        4.11s
[ok  ] experiments/ch06_gradient.py           1.68s
[ok  ] experiments/ch06_alignment.py         27.90s
[ok  ] experiments/ch06_width.py            102.77s
[ok  ] experiments/ch06_encoder.py          102.93s

total 680.47s, budget 900s
verify: ok
```

Chương 6 thêm 239.39 giây. Chạy riêng từng script ngoài `verify.py` thì nhanh
hơn một chút vì máy rảnh hơn: 5.92s, 0.34s, 22.41s, 103.19s và 96.64s. Hai bộ
số lệch nhau tới ba lần ở script rẻ nhất, và đó chính là lý do phần ngân sách
bên dưới không đặt sát số đo.

Mốc trước khi thêm chương 6, đo trên máy này ngày 2026-08-11: toàn bộ
`verify.py` ở tag `ch05` chạy 487.27s, trong đó chapter 2 verify 101.42s,
ch05_bottleneck 69.63s, ch05_reverse 127.18s, ch05_search 104.20s, ch04_adding
35.18s, chapter 3 tests 14.98s.

`BUDGET_TOTAL` nâng từ 600 lên 900. Lý do đầy đủ nằm trong comment ở
`verify.py`; tóm tắt: 600 đặt từ hồi repo dừng ở chương 3, và độ tản giữa các
lần chạy trên cùng code đã đo được là 557.52 / 495.51 / 487.27, tức 70 giây.
Một ngân sách chỉ hơn số đo 40 giây thì không phải ngân sách.

## Ba chỗ đã sai và sửa được trong lúc dựng

Ghi lại theo yêu cầu của README trong thư mục này: ghi cả những phép đo hoá ra
không thú vị, và cả những chỗ hỏng.

1. **`file` báo sai số trang PDF của Cho 2014b.** Đã nói ở trên. Ba trang cuối,
   chứa hình 4 và hình 5, suýt không được đọc.

2. **Đọc thô bảng encoder thì kết luận ngược.** Bốn dòng đầu nói chiều ngược
   đáng giá 0.0467 exact. Dòng đối chứng nói nó đáng giá 0. Nếu không đếm tham
   số thì chương đã in một câu sai về bài báo.

3. **Ban đầu định đo đường gradient trên mô hình đã huấn luyện.** Bỏ, vì hai mô
   hình huấn luyện xong thì gradient phản ánh cái corpus dạy được chứ không
   phản ánh đường đi trong đồ thị tính toán, mà đường đi mới là thứ phần dẫn
   xuất nói tới. Đo tại khởi tạo là chỗ so được. Cùng lựa chọn mà chương 4 đã
   làm cho đạo hàm qua carousel.
