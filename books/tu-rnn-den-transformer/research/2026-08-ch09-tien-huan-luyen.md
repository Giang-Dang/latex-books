# Chương 09: Tiền huấn luyện: BERT, GPT, và quy luật scaling

Ghi ngày 2026-08-12.

Ghi chú nguồn và số đo cho chương 9. Mọi số thập phân chương 9 in ra đều phải
có mặt ở đây (quyết định 20 trong SPEC).

Chương 9 là chương đầu tiên của sách mà corpus của quyết định 35 không với tới
được. Văn phạm ấy hữu hạn, từ điển đóng, và một mô hình học được nó chính xác,
nên không có phân phối nào để một pha tiền huấn luyện chuyển giao sang. Vì vậy
chương này không huấn luyện gì cả. Cái nó làm thay là **đếm**: mọi con số tiêu
đề mà bốn bài báo này in ra đều được dựng lại từ chính siêu tham số các bài ấy
in, và chương ghi lại con số nào quay về được và con số nào không.

Hệ quả cho `verify.py`: chương 9 thêm ba mục và không mục nào huấn luyện mô
hình, tổng 4.90s. `BUDGET_TOTAL` không phải động tới, và đây là lần đầu kể từ
chương 4 một chương không thêm giây huấn luyện nào. Xem quyết định 62, vốn nói
chương tiếp theo cần nâng ngân sách thì không nên nâng.

**Về quyết định 60.** Chương 8 phải cam kết đưa bản chạy gốc vào companion repo
vì bảng của nó là số đồng hồ, phụ thuộc máy. Chương 9 không có bảng nào như thế.
Mọi số dưới đây là dạng đóng hoặc là phép đếm số nguyên, nên chạy lại
`experiments/ch09_counts.py` và `experiments/ch09_laws.py` trên bất kỳ máy nào
cũng cho đúng từng chữ số. Bản thân script là bản sao chính tắc.

## 0. Danh sách nguồn và bản đã đọc

Bốn bài này **không** nằm trong manifest sáu bài báo gốc
(`2026-08-nguon-sau-bai-bao.md`), và không có bản cứng trong thư mục Papers.
Tất cả đọc qua bản tải về từ web trong phiên này.

| Bài | Bản đã đọc | Venue trên trang bìa |
|---|---|---|
| Devlin et al., BERT | ACL Anthology N19-1423, 16 trang; cùng với arXiv 1810.04805v1 (14 trang) và v2 (16 trang) | NAACL-HLT 2019, tập 1, trang 4171-4186 |
| Radford et al., GPT-1 | PDF trên cdn.openai.com, 12 trang | **Im lặng.** Chân trang 1 chỉ ghi "Preprint. Work in progress." Không có ngày |
| Radford et al., GPT-2 | PDF trên cdn.openai.com, 24 trang | **Im lặng.** Không hội nghị nào in ở header hay footer |
| Brown et al., GPT-3 | arXiv 2005.14165v4 (22/07/2020, 75 trang) và bản NeurIPS 2020 (25 trang) | NeurIPS 2020, tập 33, trang 1877-1901 |
| Kaplan et al., scaling laws | arXiv 2001.08361v1 (23/01/2020) | **Im lặng.** arXiv chỉ có v1; không tìm thấy venue nào |
| Hoffmann et al., Chinchilla | arXiv 2203.15556v1 và bản NeurIPS 2022 | NeurIPS 2022, tập 35, trang 30016-30030 |

Quyết định 47 áp dụng cho ba bài trong số này, và cả ba đều có chuyện để nói.
Xem mục 5.

## 1. Cùng một kiến trúc: các bài tự nói

### 1.1 BERT, mục 3 (ACL trang 4173)

Nguyên văn, và đây là câu trục của cả chương:

> BERT's model architecture is a multi-layer bidirectional Transformer encoder
> based on the original implementation described in Vaswani et al. (2017) and
> released in the tensor2tensor library. Because the use of Transformers has
> become common and our implementation is almost identical to the original, we
> will omit an exhaustive background description of the model architecture and
> refer readers to Vaswani et al. (2017) as well as excellent guides such as
> "The Annotated Transformer."

**Bản v1 viết câu này khác.** v1: "Because the use of Transformers has become
ubiquitous recently and our implementation is effectively identical to the
original". Chương trích bản ACL, vì đó là bản đã xuất bản.

Siêu tham số, cùng mục:

> We primarily report results on two model sizes: BERT_BASE (L=12, H=768,
> A=12, Total Parameters=110M) and BERT_LARGE (L=24, H=1024, A=16, Total
> Parameters=340M).

Chú thích 3: "In all cases we set the feed-forward/filter size to be 4H, i.e.,
3072 for the H = 768 and 4096 for the H = 1024."

Từ điển: "We use WordPiece embeddings (Wu et al., 2016) with a 30,000 token
vocabulary." Độ dài tối đa 512 token.

### 1.2 GPT-1, mục 4.1 (trang 5)

> Our model largely follows the original transformer work [62]. We trained a
> 12-layer decoder-only transformer with masked self-attention heads (768
> dimensional states and 12 attention heads). For the position-wise
> feed-forward networks, we used 3072 dimensional inner states.

Cùng trang: "We used a bytepair encoding (BPE) vocabulary with 40,000 merges",
"contiguous sequences of 512 tokens", "We used learned position embeddings
instead of the sinusoidal version proposed in the original work", và
"lambda was set to 0.5".

**Bài không in số tham số ở bất kỳ đâu**, và cũng không in kích thước từ điển:
40,000 là số phép merge, còn từ điển BPE là số merge cộng bảng chữ cái cơ sở
cộng token đặc biệt. Con số 117M thường được trích không có trong bài. Đọc hết
12 trang để xác nhận điều này chứ không suy ra.

### 1.3 GPT-2, mục 2.3 (trang 4)

> The model largely follows the details of the OpenAI GPT model with a few
> modifications. Layer normalization was moved to the input of each sub-block,
> similar to a pre-activation residual network, and an additional layer
> normalization was added after the final self-attention block. A modified
> initialization which accounts for the accumulation on the residual path with
> model depth is used. We scale the weights of residual layers at
> initialization by a factor of 1/sqrt(N) where N is the number of residual
> layers. The vocabulary is expanded to 50,257. We also increase the context
> size from 512 to 1024 tokens and a larger batchsize of 512 is used.

Bảng 2, nguyên văn:

| Parameters | Layers | d_model |
|---|---|---|
| 117M | 12 | 768 |
| 345M | 24 | 1024 |
| 762M | 36 | 1280 |
| 1542M | 48 | 1600 |

Mục 3: "The smallest model is equivalent to the original GPT, and the second
smallest equivalent to the largest model from BERT."

### 1.4 GPT-3, mục 2.1 (arXiv v4 trang 8)

> We use the same model and architecture as GPT-2 [RWC+19], including the
> modified initialization, pre-normalization, and reversible tokenization
> described therein, with the exception that we use alternating dense and
> locally banded sparse attention patterns in the layers of the transformer,
> similar to the Sparse Transformer [CGRS19].

Bảng 2.1, nguyên văn cả tám hàng:

| Model Name | n_params | n_layers | d_model | n_heads | d_head | Batch Size | Learning Rate |
|---|---|---|---|---|---|---|---|
| GPT-3 Small | 125M | 12 | 768 | 12 | 64 | 0.5M | 6.0e-4 |
| GPT-3 Medium | 350M | 24 | 1024 | 16 | 64 | 0.5M | 3.0e-4 |
| GPT-3 Large | 760M | 24 | 1536 | 16 | 96 | 0.5M | 2.5e-4 |
| GPT-3 XL | 1.3B | 24 | 2048 | 24 | 128 | 1M | 2.0e-4 |
| GPT-3 2.7B | 2.7B | 32 | 2560 | 32 | 80 | 1M | 1.6e-4 |
| GPT-3 6.7B | 6.7B | 32 | 4096 | 32 | 128 | 2M | 1.2e-4 |
| GPT-3 13B | 13.0B | 40 | 5140 | 40 | 128 | 2M | 1.0e-4 |
| GPT-3 175B | 175.0B | 96 | 12288 | 96 | 128 | 3.2M | 0.6e-4 |

Chú thích bảng: "All models were trained for a total of 300 billion tokens."

**Hai hàng của bảng này không thỏa `n_heads * d_head = d_model`**, quan hệ mà
sáu hàng còn lại thỏa đúng: XL in `d_model` 2048 với 24 head cỡ 128 (tích là
3072), và 13B in `d_model` 5140 với 40 head cỡ 128 (tích là 5120). Đọc lại
trang 8 ở độ phân giải đầy đủ để loại trừ lỗi đọc; bài in đúng như vậy. Chép
nguyên, không sửa.

Phụ lục D bảng D.1 in cho hàng 175B: tổng compute huấn luyện
3.64e+03 petaflop/s-days, tức 3.14e+23 flops, và số tham số ghi ở hàng ấy là
**174,600M**, không phải 175.0B của bảng 2.1. Chú thích bảng D.1 định nghĩa
1 petaflop/s-day = 8.64e+19 flops.

## 2. Dựng lại các con số tiêu đề

Chạy `python experiments/ch09_counts.py` tại tag `ch09`. Toàn bộ đầu ra dưới
đây là dạng đóng, không đo đồng hồ, nên tái lập được từng chữ số trên mọi máy.

Công thức, trong `rnn_to_transformer_lab/scaling.py`, kiểm bằng
`tests/test_ch09.py` đối chiếu với `sum(p.numel())` trên chính module repo dựng:
một khối là bốn phép chiếu `d x d`, hai ma trận truyền thẳng `d x d_ff` và
`d_ff x d`, hai layer norm.

### 2.1 BERT

```
model       vocab   pooler mlm   rebuilt        paper      ratio
BERT-base   30000   True   False 109,081,344       110M    0.9916
BERT-base   30522   True   False 109,482,240       110M    0.9953
BERT-base   30522   True   True  110,104,890       110M    1.0010
BERT-large  30000   True   False 334,607,360       340M    0.9841
BERT-large  30522   True   False 335,141,888       340M    0.9857
BERT-large  30522   True   True  336,224,058       340M    0.9889
```

30000 là con số bài in; 30522 là con số checkpoint phát hành mang. In cả hai vì
bài chỉ nói con số thứ nhất.

Chương làm tròn ba hàng của bảng này khi in trong văn xuôi: 109.48M cho
109,482,240, 110.10M cho 110,104,890, và 335.14M cho 335,141,888.

**BERT-base quay về được, BERT-large thì không.** 110M làm tròn từ 109.48M là
hợp lý; 340M không làm tròn từ 335.14M dưới bất kỳ cách đọc nào trong sáu cách
trên. Khoảng cách là 1.4%. Chương in cả sáu hàng và nói thẳng là không biết
340M đếm thêm cái gì.

### 2.2 GPT-1

```
vocabulary   rebuilt
40000        116,169,216    (merges only)
40256        116,365,824
40478        116,536,320
```

Dải chứ không phải một số, vì bài không in kích thước từ điển. 40478 là từ điển
của checkpoint phát hành, không phải con số bài in.

### 2.3 GPT-2

```
model         printed    V=50257 n=1024        gap        gap / d_model
GPT-2 117M       117M   124,439,808    (1.0636)   7,439,808      9687
GPT-2 345M       345M   354,823,168    (1.0285)   9,823,168      9593
GPT-2 762M       762M   774,030,080    (1.0158)  12,030,080      9398
GPT-2 1542M     1542M   1,557,611,200  (1.0101)  15,611,200      9757

model         V that reproduces the printed count
GPT-2 117M        40,570
GPT-2 345M        40,664
GPT-2 762M        40,858
GPT-2 1542M       40,500
```

Bốn hàng giải độc lập ra bốn kích thước từ điển nằm trong khoảng 1% của nhau,
quanh 40,500 tới 40,900. Mục 2.3 của chính bài nói từ điển được mở rộng **lên**
50,257. Nên bảng 2 in số tham số đếm bằng từ điển trước khi mở rộng.

Đây là suy luận từ số học, không phải điều bài nói. Chương in nó ở dạng ấy:
bốn phép giải, và một câu của bài đặt cạnh.

### 2.4 GPT-3

```
model         heads*d_head  d_model  rebuilt             paper      ratio
GPT-3 Small   768           768      125,226,240          0.125B   1.0018
GPT-3 Medium  1024          1024     355,871,744          0.350B   1.0168
GPT-3 Large   1536          1536     760,300,032          0.760B   1.0004
GPT-3 XL      3072          2048     1,315,723,264        1.300B   1.0121  <- not d_model
GPT-3 2.7B    2560          2560     2,651,553,280        2.700B   0.9821
GPT-3 6.7B    4096          4096     6,658,404,352        6.700B   0.9938
GPT-3 13B     5120          5140     12,952,938,780      13.000B   0.9964  <- not d_model
GPT-3 175B    12288         12288    174,604,259,328     175.000B   0.9977
```

Hàng 175B dựng lại được 174,604,259,328, tức 174,604M. Bảng D.1 của chính bài
in 174,600M. Bảng 2.1 in 175.0B. Hai bảng trong cùng một bài không khớp nhau, và
phép dựng lại đứng về phía phụ lục.

### 2.5 Bảng embedding

```
model        total               embedding       non-embedding    emb share
GPT-1        116,536,320         31,480,320      85,056,000       0.2701
GPT-2 1542M  1,557,611,200       82,049,600      1,475,561,600    0.0527
BERT-base    109,482,240         23,837,184      85,645,056       0.2177
GPT-3 175B   174,604,259,328     642,723,840     173,961,535,488  0.0037
```

0.2701 xuống 0.0037 là hệ số 73 trên đúng dải mà các quy luật được khớp. Đây là
lý do định nghĩa `N` của Kaplan không phải chuyện sổ sách.

Hàng GPT-1 dùng từ điển 40,478 của checkpoint phát hành, vốn không phải con số
bài in (mục 2.2 ở trên). Đầu kia của dải cho:

```
vocab 40000: total 116,169,216  embedding 31,113,216  share 0.2678
vocab 40478: total 116,536,320  embedding 31,480,320  share 0.2701
```

Chênh lệch 0.2678 so với 0.2701 không đụng tới điều bảng nói, nên chương in hàng
40,478 và ghi chú chỗ không chắc ngay trong hộp.

## 3. C = 6ND, và cái nó bỏ quên

### 3.1 Kaplan nói gì

Mục 2.1 (trang 6), nguyên văn:

> For contexts and models with d_model > n_ctx/12, the context-dependent
> computational cost per token is a relatively small fraction of the total
> compute. Since we primarily study models where d_model >> n_ctx/12, we do not
> include context-dependent terms in our training compute estimate. Accounting
> for the backwards pass (approximately twice the compute as the forwards
> pass), we then define the estimated non-embedding compute as C ~ 6N floating
> point operations per training token.

Phương trình 2.2: `C_forward ~ 2N + 2 n_layer n_ctx d_model`.

Định nghĩa `N`, mục 1.3: "the number of model parameters, excluding all
vocabulary and positional embeddings." Mục 2.1: "we do not include these when
discussing the 'model size' N; we will see that this produces significantly
cleaner scaling laws."

Mục 2.1 đặt cấu hình chuẩn: "with the standard d_attn = d_ff/4 = d_model".

Bảng 1, nguyên văn cả bảng:

| Operation | Parameters | FLOPs per Token |
|---|---|---|
| Embed | (n_vocab + n_ctx) d_model | 4 d_model |
| Attention: QKV | n_layer d_model 3 d_attn | 2 n_layer d_model 3 d_attn |
| Attention: Mask | - | 2 n_layer n_ctx d_attn |
| Attention: Project | n_layer d_attn d_model | 2 n_layer d_attn d_embd |
| Feedforward | n_layer 2 d_model d_ff | 2 n_layer 2 d_model d_ff |
| De-embed | - | 2 d_model n_vocab |
| Total (Non-Embedding) | N = 2 d_model n_layer (2 d_attn + d_ff) | C_forward = 2N + 2 n_layer n_ctx d_attn |

Chú thích bảng: "Sub-leading terms such as nonlinearities, biases, and layer
normalization are omitted."

Ô hàng `Attention: Project` in `d_embd`, một ký hiệu không được định nghĩa ở
đâu khác trong bài; mọi chỗ khác viết `d_model`. Nhiều khả năng là lỗi in, và
dưới quy ước `d_attn = d_model` của chính bài thì nó không đổi con số. Chép
nguyên và ghi lại.

### 3.2 Bảng 1 chỉ đếm một trong hai tích n^2

Attention có **hai** phép nhân ma trận mang `n^2`: `Q K^T`, rồi phép lấy tổ hợp
`V` theo trọng số softmax. Bảng 1 chỉ có một hàng mang `n_ctx`, và phương trình
2.2 mang đúng cùng một hệ số, nên bảng và công thức nhất quán với nhau và cùng
thiếu một tích.

Phụ lục F của Hoffmann liệt kê cả hai, nguyên văn:

> - Key @ Query logits: 2 x seq_len x seq_len x (key_size x num_heads)
> - Softmax: 3 x num_heads x seq_len x seq_len
> - Softmax @ query reductions: 2 x seq_len x seq_len x (key_size x num_heads)

Đo, `experiments/ch09_counts.py` mục 4:

```
d_model  n_ctx   kaplan attn   exact attn    ratio  kaplan total  exact total
768      512     786,432       1,572,864     2.00   14,942,208    15,728,640
1600     1024    3,276,800     6,553,600     2.00   64,716,800    67,993,600
12288    2048    50,331,648    100,663,296   2.00   3,674,210,304 3,724,541,952
```

Tỷ lệ đúng 2.00 ở cả ba cấu hình. Nửa tham số của hai phép đếm khớp nhau chính
xác; chỉ số hạng attention lệch.

**Ai đúng.** `tests/test_ch09.py::test_flops_per_token_against_torchs_own_counter`
so phép đếm dạng đóng với `torch.utils.flop_counter.FlopCounterMode` trên một
stack thật, ở `(L, d, n)` bằng `(2, 64, 32)`, `(4, 128, 64)` và `(2, 256, 128)`.
Chênh lệch là 0 ở cả ba. Đây là cùng phép kiểm chéo chương 8 dùng cho một tầng,
nâng lên cho cả stack.

### 3.3 Sai số của 6ND, dạng đóng

```
configuration                   n_ctx   ratio    1 + n/(6d)  attn share
GPT-1        L12 d768           512     1.1095   1.1111      0.1000
GPT-2 1542M  L48 d1600          1024    1.1059   1.1067      0.0964
GPT-3 175B   L96 d12288         2048    1.0277   1.0278      0.0270
GPT-3 175B, 4x context          8192    1.1110   1.1111      0.1000
GPT-3 175B, 16x context         32768   1.4443   1.4444      0.3077
```

Tỷ lệ chính xác trên `2N`, và `D` triệt tiêu khỏi nó. Xấp xỉ `1 + n/(6d)` bám
số đo trong vòng 0.002 ở khắp bảng.

Phần attention trong một lượt truyền xuôi là `n / (6d + n)`, chỉ phụ thuộc tỷ
số `n/d`, và bằng một nửa tại `n = 6d`:

```
d_model  n = 6*d_model  cost.quadratic_half_point
768      4608           4608
1600     9600           9600
12288    73728          73728
```

`6d` chính là `n = 2d + d_ff` của chương 8 ở `d_ff = 4d`. Hai chương tới cùng
một ngưỡng từ hai phía: chương 8 hỏi khi nào phần bậc hai chiếm nửa một tầng,
chương 9 hỏi khi nào xấp xỉ của Kaplan sai một nửa. Cùng một `n`.

### 3.4 Bảng A4 của Hoffmann: không dựng lại được

Bảng A4, nguyên văn:

| Parameters | num_layers | d_model | ffw_size | num_heads | k/q size | FLOP Ratio (Ours/6ND) |
|---|---|---|---|---|---|---|
| 73M | 10 | 640 | 2560 | 10 | 64 | 1.03 |
| 305M | 20 | 1024 | 4096 | 16 | 64 | 1.10 |
| 552M | 24 | 1280 | 5120 | 10 | 128 | 1.08 |
| 1.1B | 26 | 1792 | 7168 | 14 | 128 | 1.04 |
| 1.6B | 28 | 2048 | 8192 | 16 | 128 | 1.03 |
| 6.8B | 40 | 3584 | 14336 | 28 | 128 | 0.99 |

Phụ lục F kết luận: "We find the differences in FLOP calculation to be very
small and they do not impact our analysis."

**Bảng này không tái lập được từ bài.** Phép đếm của phụ lục F gồm cả
`2 x seq_len x vocab_size x d_model` cho embedding và
`2 x seq_len x d_model x vocab_size` cho logits cuối, nên tỷ lệ phụ thuộc cả độ
dài chuỗi lẫn kích thước từ điển, và **bài không in con số nào trong hai**. Đã
tìm trong mục huấn luyện và trong toàn bộ phụ lục A tới I. Bài chỉ nói về từ
điển của riêng Chinchilla, gián tiếp: "The vocabulary is very similar - 94.15%
of tokens are the same as those used for training Gopher."

Quét hai ẩn ấy trên chín cặp, `n` trong {1024, 2048, 4096} nhân `V` trong
{32000, 32768, 51200}, bằng `experiments/ch09_laws.py` mục 7 tại tag `ch09`.
Phép đếm cài theo đúng phụ lục F, kể cả dòng softmax mà Kaplan bỏ, và mẫu số
dùng số tham số có tính embedding theo đúng quy ước của bài. Đầu ra đầy đủ:

```
published:    1.03   1.10   1.08   1.04   1.03   0.99

n_ctx  vocab   rebuilt ratios                          worst gap
1024   32000    1.48   1.26   1.20   1.14   1.12   1.07   0.455
1024   32768    1.49   1.27   1.20   1.15   1.13   1.07   0.458
1024   51200    1.56   1.31   1.24   1.17   1.15   1.08   0.532
2048   32000    1.68   1.41   1.33   1.24   1.20   1.11   0.645
2048   32768    1.68   1.42   1.33   1.24   1.21   1.11   0.647
2048   51200    1.72   1.45   1.36   1.26   1.23   1.12   0.694
4096   32000    2.06   1.71   1.57   1.42   1.36   1.21   1.026
4096   32768    2.06   1.71   1.57   1.42   1.37   1.21   1.025
4096   51200    2.05   1.73   1.59   1.43   1.38   1.21   1.017
```

Cặp gần nhất là `n_ctx=1024, vocab=32000`, vẫn lệch **0.455** ở hàng tệ nhất.
Không cặp nào tới gần. Chương in ba hàng đại diện (1024, 2048, 4096 ở
`V=32000`) và nói rõ script in cả chín.

Ghi lại như một phép đo đã làm và không dùng được, theo luật của `README.md`
trong thư mục này. Chương nói bảng A4 không dựng lại được và nói vì sao, chứ
không in một cột số của riêng mình cạnh cột của bài như thể hai cột so được.

**Bản đầu của phép quét này chạy trong một thư mục tạm và chỉ còn lại dưới dạng
một câu trong ghi chú.** Audit bắt được, và đó đúng là hình dạng quyết định 60
tồn tại để chặn. Bây giờ nó nằm trong `ch09_laws.py` tại tag `ch09`.

## 4. Hai quy luật

### 4.1 Kaplan, mục 1.2 (trang 4)

Nguyên văn cả ba, kể cả dấu `~` của bài:

> 1. For models with a limited number of parameters, trained to convergence on
> sufficiently large datasets:
> L(N) = (N_c/N)^alpha_N ; alpha_N ~ 0.076, N_c ~ 8.8 x 10^13 (non-embedding parameters)
> 2. For large models trained with a limited dataset with early stopping:
> L(D) = (D_c/D)^alpha_D ; alpha_D ~ 0.095, D_c ~ 5.4 x 10^13 (tokens)
> 3. When training with a limited amount of compute, a sufficiently large
> dataset, an optimally-sized model, and a sufficiently small batch size:
> L(C_min) = (C_c^min/C_min)^alpha_C^min ; alpha_C^min ~ 0.050, C_c^min ~ 3.1 x 10^8 (PF-days)

Bài in hai chữ số có nghĩa và dùng `~` chứ không dùng `=`. Chương không thêm
chữ số thứ ba.

Số mũ ấy đổi ra phần trăm, `experiments/ch09_laws.py` mục 6 tại tag `ch09`:

```
factor on N   loss multiplier   reduction
2             0.9487            5.1%
10            0.8395            16.1%
100           0.7047            29.5%
```

Chương in hàng giữa: gấp mười mô hình thì mất mát giảm **16.1%**.

**Ba phép khớp khác nhau cho cùng một ký hiệu.** Bảng 3 mục 5 khớp dạng hai
biến `L(N, S)` và cho `alpha_N = 0.077`, `N_c = 6.5e13`; phụ lục A bảng 5 cho
`L(C)` dạng thô `alpha_C = 0.057`, `C_c = 1.6e7` PF-days. Chú thích 3 trang 4
nói rõ nên dùng đường `C_min`: "it is the trend with C_min that should be used
to make predictions". Trích `N_c` hay `alpha_C` mà không nói lấy từ phương
trình nào là trích sai.

Bảng 6 phụ lục A, phân bổ tối ưu:

```
N_opt = 1.3e9 * C_min^0.73
B_crit = 2.0e6 * C_min^0.24
S_min = 5.4e3 * C_min^0.03
D_opt = 2e10 * C_min^0.27
```

Trang 5: "which closely matches the empirically optimal results N ~
C_min^0.73, B ~ C_min^0.24, and S ~ C_min^0.03. As the computational budget C
increases, it should be spent primarily on larger models, without dramatic
increases in training time or dataset size."

Lịch learning rate, mục 2.2 trang 7, và đây là chỗ Hoffmann sẽ phản đối:

> Unless otherwise noted, we train models with the Adam optimizer for a fixed
> 2.5 x 10^5 steps with a batch size of 512 sequences of 1024 tokens. ... We
> found that results at convergence were largely independent of learning rate
> schedule. Unless otherwise noted, all training runs included in our data used
> a learning rate schedule with a 3000 step linear warmup followed by a cosine
> decay to zero.

Ba luật, đo tại `experiments/ch09_laws.py` mục 1:

```
N (non-embedding)   L(N)      D (tokens)      L(D)      C_min (PF-days)  L(C)
1.0e+07             3.3712    1.0e+08         3.5041    1.0e+00          2.6581
1.0e+08             2.8300    1.0e+09         2.8156    1.0e+02          2.1114
1.0e+09             2.3756    1.0e+10         2.2624    1.0e+04          1.6771
1.0e+10             1.9943    1.0e+11         1.8179    1.0e+06          1.3322
```

### 4.2 Hoffmann, tóm tắt

> By training over 400 language models ranging from 70 million to over 16
> billion parameters on 5 to 500 billion tokens, we find that for
> compute-optimal training, the model size and the number of training tokens
> should be scaled equally: for every doubling of model size the number of
> training tokens should also be doubled.

Phần mở đầu trang 2:

> Specifically, given a 10x increase computational budget, they suggest that
> the size of the model should increase 5.5x while the number of training
> tokens should only increase 1.8x. Instead, we find that model size and the
> number of training tokens should be scaled in equal proportions.

Bảng 2 nguyên văn, kể cả phân vị:

| Approach | Coeff. a (N_opt ~ C^a) | Coeff. b (D_opt ~ C^b) |
|---|---|---|
| 1. Minimum over training curves | 0.50 (0.488, 0.502) | 0.50 (0.501, 0.512) |
| 2. IsoFLOP profiles | 0.49 (0.462, 0.534) | 0.51 (0.483, 0.529) |
| 3. Parametric modelling of the loss | 0.46 (0.454, 0.455) | 0.54 (0.542, 0.543) |
| Kaplan et al. (2020) | 0.73 | 0.27 |

Chú thích bảng: "The 10th and 90th percentiles are estimated via bootstrapping
data (80% of the dataset is sampled 100 times) and are shown in parenthesis."
Đây là phân vị bootstrap, không phải khoảng tin cậy cổ điển; chương gọi đúng
tên.

Phụ lục D.2 phương trình 10:

> L(N, D) = E + A/N^{0.34} + B/D^{0.28}, with E = 1.69, A = 406.4, B = 410.7.

Số nhân của một hệ số compute, đo tại mục 2 của `ch09_laws.py`:

```
compute x   Kaplan: model x   Kaplan: data x   Hoffmann: each x
2           1.66              1.21             1.41
10          5.37              1.86             3.16
100         28.84             3.47             10.00
1000        154.88            6.46             31.62
```

Hàng `10` là hàng phần mở đầu của Hoffmann diễn đạt lại. Bài viết "5.5x" và
"1.8x"; số mũ của chính Kaplan cho 5.37 và 1.86. Bài làm tròn số của đối thủ
chứ không trích.

### 4.3 Bảng 2 hàng 3 không dựng lại được từ alpha và beta đã in

Phương trình 4 dẫn `a = beta/(alpha+beta)` và `b = alpha/(alpha+beta)`. Với
`alpha = 0.34` và `beta = 0.28` của phụ lục D.2:

```
  a = beta/(alpha+beta)  = 0.4516  rounds to 0.45
  b = alpha/(alpha+beta) = 0.5484  rounds to 0.55
  a + b = 1.0000  (exactly 1 by construction)

  beta/alpha must be          0.8519
  with alpha = 0.34, beta would be  0.2896
  with beta = 0.28, alpha would be   0.3287
```

Bảng 2 in 0.46 và 0.54, và 0.4516 không làm tròn thành 0.46. Nên `alpha` và
`beta` in ở phụ lục D.2 đã được làm tròn, và đường biên tính trước khi làm
tròn. Không phải mâu thuẫn, nhưng có nghĩa là hàm mất mát và đường biên không
cùng dựng lại được từ hằng số bài in. `a + b = 1` thì đúng chính xác, theo cấu
trúc.

### 4.4 Chinchilla so với Gopher

Bảng 1: Gopher 280 tỷ tham số trên 300 tỷ token; Chinchilla 70 tỷ trên 1.4
nghìn tỷ. Bảng 4: Gopher 80 tầng, 128 head, key/value 128, `d_model` 16,384;
Chinchilla 80 tầng, 64 head, key/value 128, `d_model` 8,192. Chú thích bảng 4:
"The feed-forward size is always set to 4 x d_model."

Trang 9: "Both Chinchilla and Gopher have been trained for the same number of
FLOPs but differ in the size of the model and the number of training tokens."

MMLU: tóm tắt in 67.5% và "greater than a 7% improvement over Gopher"; mục
4.2.2 và bảng 6 in **67.6%** và "improving upon Gopher by 7.6%", với Gopher
5-shot ở 60.0%. Hai con số này lệch nhau **trong chính bài**, giống hệt ở cả
bản arXiv lẫn bản NeurIPS. Chương dùng 67.6 vì đó là số bảng 6 đo, và nói ra
chỗ lệch.

Đo tại `ch09_laws.py` mục 4:

```
model         N            D            C = 6ND      L(N, D)
Gopher        2.8e+11      3e+11        5.040e+23    1.9933
Chinchilla    7e+10        1.4e+12      5.880e+23    1.9366
```

Hai ngân sách lệch nhau hệ số **1.1667** dưới 6ND, tức **16.7%**, trên chính
con số bảng 1 của
bài, trong khi bài nói chúng bằng nhau. Để bằng nhau dưới 6ND, Chinchilla cần
1.200e+12 token thay vì 1.4e+12.

Cách giải thích khả dĩ, và chương nói rõ nó chưa kiểm được: bài không dùng 6ND
cho phép đếm của mình, phụ lục F đếm đủ mọi số hạng, và bảng A4 nói phép đếm đủ
chạy từ 0.99 tới 1.10 lần 6ND tùy hình dạng mô hình. Gopher rộng gấp đôi
Chinchilla nên hai mô hình nằm ở hai chỗ khác nhau của dải ấy. Không kiểm được
vì mục 3.4 ở trên.

### 4.5 GPT-3 dưới hàm mất mát của Chinchilla

```
model                      N            D            L(N, D)
GPT-3 as trained           1.75e+11     3e+11        2.0023
compute-matched, 20 D/N    5.123e+10    1.025e+12    1.9609
```

Cùng `C = 3.150e+23`, và phép khớp thích mô hình nhỏ hơn, hơn **0.0414** nat.
Hàng 175B của bảng 3 muốn 3.7e+12 token so với 3.0e+11 đã dùng, hệ số **12.3**.

Mô hình đối chứng dựng bằng chính quy tắc 20 token trên tham số: `C = 6N(20N) =
120N^2`, nên `N = sqrt(C/120)`.

### 4.6 Bảng 3, và quy tắc hai mươi token

Bảng 3 nguyên văn, cộng hai cột chương tính thêm:

```
parameters     tokens        D/N     6ND          table's FLOPs  ratio
400 Million    8.000e+09     20.0    1.920e+19    1.920e+19      1.0000
1 Billion      2.020e+10     20.2    1.212e+20    1.210e+20      1.0017
10 Billion     2.051e+11     20.5    1.231e+22    1.230e+22      1.0005
67 Billion     1.500e+12     22.4    6.030e+23    5.760e+23      1.0469
175 Billion    3.700e+12     21.1    3.885e+24    3.850e+24      1.0091
280 Billion    5.900e+12     21.1    9.912e+24    9.900e+24      1.0012
520 Billion    1.100e+13     21.2    3.432e+25    3.430e+25      1.0006
1 Trillion     2.120e+13     21.2    1.272e+26    1.270e+26      1.0016
10 Trillion    2.162e+14     21.6    1.297e+28    1.300e+28      0.9978
```

`D/N` chạy từ 20.0 tới 22.4 và trôi lên theo quy mô. **Bài không viết quy tắc
ấy ra ở đâu cả**; đã đọc hết phần chính và phụ lục A tới I. Nó là một cách đọc
cột, và chương gọi đúng tên như vậy (quyết định 54 cùng tinh thần: một thứ chưa
được phát biểu thì không được trích như thể đã).

Cột cuối là phép kiểm rằng bảng 3 dựng bằng `C = 6ND`; khớp tới 0.5% ở **bảy**
trong chín hàng. Hai hàng ngoài ngưỡng là 67B, lệch 4.7% vì cột token làm tròn
tới 1.5e+12, và 175B, lệch 0.91% ở 3.7e+12. (Bản đầu của ghi chú này và của
chương viết "tám trong chín"; audit bắt được, và hàng 175B là hàng bị đếm nhầm
vào trong ngưỡng.)

### 4.7 Kaplan tự đánh giá đường tối ưu của mình

```
C_min (PF-days)   N_opt          D_opt          D/N
1.0e+02           3.749e+10      6.935e+10      1.85
1.0e+04           1.081e+12      2.405e+11      0.22
1.0e+06           3.118e+13      8.337e+11      0.03
```

Tỷ số token trên tham số **giảm** theo ngân sách, và đó là toàn bộ chỗ bất
đồng: Kaplan tiêu hệ số compute mới chủ yếu vào tham số, Hoffmann giữ tỷ số cố
định.

### 4.8 Hoffmann giải thích chỗ khác nhau thế nào

Mục 2, nguyên văn:

> Our work differs from Kaplan et al. (2020) in several important ways. First,
> the authors use a fixed number of training tokens and learning rate schedule
> for all models; this prevents them from modelling the impact of these
> hyperparameters on the loss. In contrast, we find that setting the learning
> rate schedule to approximately match the number of training tokens results in
> the best final loss regardless of model size - see Figure A1. For a fixed
> learning rate cosine schedule to 130B tokens, the intermediate loss estimates
> (for D' << 130B) are therefore overestimates of the loss of a model trained
> with a schedule length matching D'. Using these intermediate losses results in
> underestimating the effectiveness of training models on less data than 130B
> tokens, and eventually contributes to the conclusion that model size should
> increase faster than training data size as compute budget increases. In
> contrast, our analysis predicts that both quantities should scale at roughly
> the same rate. Secondly, we include models with up to 16B parameters, as we
> observe that there is slight curvature in the FLOP-loss frontier (see
> Appendix E) - in fact, the majority of the models used in our analysis have
> more than 500 million parameters, in contrast the majority of runs in Kaplan
> et al. (2020) are significantly smaller - many being less than 100M
> parameters.

**Bài đưa đúng hai lý do**, và không lý do nào là chuyện embedding. Đã đọc cả
đoạn để xác nhận. Chỗ duy nhất embedding xuất hiện là phụ lục F, kỹ thuật thuần
túy:

> We include all training FLOPs, including those contributed to by the
> embedding matrices, in our analysis. Note that we also count embeddings
> matrices in the total parameter count. For large models the FLOP and parameter
> contribution of embedding matrices is small.

Nên hai bài định nghĩa `N` ngược nhau - Kaplan trừ embedding, Hoffmann cộng -
và **không bài nào nối chuyện ấy với chỗ số mũ khác nhau**. Lời giải thích
"Kaplan sai vì bỏ embedding" được lặp lại rộng rãi và không có trong bài nào.
Chương nói ra điều đó chứ không nhắc lại nó.

## 5. Quyết định 47: ba bài có nhiều hơn một bản

### 5.1 BERT: v1 khác v2 và khác cả về số

Diff từng trang giữa arXiv v1 (14 trang) và bản ACL/v2 (16 trang):

- Bảng 1, hàng BERT_LARGE: v1 in QNLI **91.1** và Average **81.9**; v2/ACL in
  QNLI **92.7** và Average **82.1**. Mọi ô khác của hàng ấy giống nhau.
- Tóm tắt: v1 "80.4% (7.6% point absolute improvement)"; v2/ACL "80.5% (7.7%
  point absolute improvement)". MultiNLI: cùng 86.7% nhưng v1 nói cải thiện
  5.6% còn v2/ACL nói 4.6%.
- v1 kết tóm tắt bằng "outperforming human performance by 2.0."; câu ấy biến
  mất khỏi v2/ACL. v2/ACL thêm SQuAD v2.0, vốn chưa tồn tại lúc v1 nộp.
- Thân bài mục 4.1.1: v1 "4.4% and 6.7%" và "4.7% absolute accuracy
  improvement" cho MNLI; v2/ACL "4.5% and 7.0%" và "4.6%". **v1 tự mâu thuẫn
  với chính tóm tắt của nó** (4.7% so với 5.6%).
- v2/ACL chuyển "Effect of Number of Training Steps" và phần so BERT với ELMo
  và OpenAI GPT xuống phụ lục A.4 và C.1, và **thêm hẳn một ablation không có
  trong v1**: "Ablation for Different Masking Procedures", phụ lục C.2 bảng 8.
- Gạch đầu dòng đóng góp thứ ba, mục 1, là hai câu khác hẳn nhau.

Chương trích bản ACL và nói bản nào ở chỗ nào số liệu lệch.

### 5.2 GPT-3: bản NeurIPS thiếu đúng cái bảng chương này dùng

Bản NeurIPS 2020 dài 25 trang, chỉ phần chính cộng thư mục, **không có phụ
lục**. Mục 2.1 của bản ấy viết "More details on the sizes and architectures of
our models can be found in the appendix" ở đúng chỗ bản arXiv đặt bảng 2.1. Tìm
chuỗi "300 billion" trong bản NeurIPS: **không có kết quả nào**. Tóm tắt của
bản NeurIPS cũng ngắn hơn hẳn, mất ba câu mở và hai câu kết của bản arXiv.

Nên chương trích bảng 2.1, bảng 2.2 và bảng D.1 theo **arXiv v4**, và
`refs.bib` ghi rõ điều đó. Trích chúng theo bản NeurIPS là trích một bảng bản
ấy không in.

### 5.3 Hoffmann: metadata của NeurIPS mang nhan đề khác với chính bài

Trang tóm tắt và bản BibTeX chính thức trên proceedings.neurips.cc đều ghi nhan
đề là "An empirical analysis of compute-optimal large language model training",
trong khi file PDF phục vụ từ chính URL ấy in "Training Compute-Optimal Large
Language Models" trên trang bìa, giống bản arXiv. Đã tải cả trang tóm tắt, bản
BibTeX và file PDF để đối chiếu. `refs.bib` lấy nhan đề từ trang bìa và ghi
chuyện này ở trường `note`.

Ngoài metadata, diff nội dung giữa arXiv v1 và bản NeurIPS: trang bìa, tóm tắt,
bảng 1, bảng 2, bảng 3, bảng A4, các con số MMLU và phần thảo luận - **không
tìm thấy khác biệt số nào**.

### 5.4 Kaplan chỉ có một bản

arXiv 2001.08361 chỉ liệt kê v1, nộp 23/01/2020. Không tìm thấy venue. Ghi lại
là im lặng chứ không kết luận là chưa từng xuất bản.

## 6. Các trích dẫn còn lại chương dùng

### 6.1 Vì sao masked LM tồn tại (BERT mục 3.1)

> Unfortunately, standard conditional language models can only be trained
> left-to-right or right-to-left, since bidirectional conditioning would allow
> each word to indirectly "see itself", and the model could trivially predict
> the target word in a multi-layered context.

Thủ tục che, cùng mục:

> In all of our experiments, we mask 15% of all WordPiece tokens in each
> sequence at random. ... If the i-th token is chosen, we replace the i-th
> token with (1) the [MASK] token 80% of the time (2) a random token 10% of the
> time (3) the unchanged i-th token 10% of the time.

### 6.2 Mật độ tín hiệu, đo tại `ch09_counts.py` mục 5

```
objective                targets/token  FLOPs/target, relative
left-to-right LM         1.0000         1.0000
masked LM at 15%         0.1500         6.6667

at BERT-base's shape, one pretraining sequence of 512 tokens:
  positions in the sequence        512
  positions an LM predicts         512
  positions BERT predicts          76
```

Số học thuần túy từ 15% của mục 3.1 và độ dài 512 của phụ lục A.2. `76` là
`floor(512 * 0.15)`.

### 6.3 NSP và phép cắt bỏ của nó (BERT mục 3.1 và 5.1)

> when choosing the sentences A and B for each pre-training example, 50% of the
> time B is the actual next sentence that follows A (labeled as IsNext), and
> 50% of the time it is a random sentence from the corpus (labeled as NotNext).

Câu mở của mục 5.1, chương trích nguyên văn:

> We first examine the impact brought by the NSP task. In Table 5, we show that
> removing NSP hurts performance significantly on QNLI, MNLI, and SQuAD 1.1.

Bảng 5, nguyên văn:

| Tasks | MNLI-m (Acc) | QNLI (Acc) | MRPC (Acc) | SST-2 (Acc) | SQuAD (F1) |
|---|---|---|---|---|---|
| BERT_BASE | 84.4 | 88.4 | 86.7 | 92.7 | 88.5 |
| No NSP | 83.9 | 84.9 | 86.5 | 92.6 | 87.9 |
| LTR & No NSP | 82.1 | 84.3 | 77.5 | 92.1 | 77.8 |
| + BiLSTM | 82.1 | 84.1 | 75.7 | 91.6 | 84.9 |

### 6.4 Dữ liệu và chi phí hai pha

BERT: "For the pre-training corpus we use the BooksCorpus (800M words) (Zhu et
al., 2015) and English Wikipedia (2,500M words)."

BERT phụ lục A.2: "Training of BERT_BASE was performed on 4 Cloud TPUs in Pod
configuration (16 TPU chips total). Training of BERT_LARGE was performed on 16
Cloud TPUs (64 TPU chips total). Each pre-training took 4 days to complete."

BERT mục 4: "Compared to pre-training, fine-tuning is relatively inexpensive.
All of the results in the paper can be replicated in at most 1 hour on a single
Cloud TPU, or a few hours on a GPU, starting from the exact same pre-trained
model."

BERT tóm tắt: "the pre-trained BERT model can be fine-tuned with just one
additional output layer to create state-of-the-art models for a wide range of
tasks, such as question answering and language inference, without substantial
task-specific architecture modifications."

GPT-1 mục 4.1: "It contains over 7,000 unique unpublished books from a variety
of genres including Adventure, Fantasy, and Romance. Crucially, it contains long
stretches of contiguous text, which allows the generative model to learn to
condition on long-range information."

GPT-2 mục 2.1: "contains slightly over 8 million documents for a total of 40 GB
of text. We removed all Wikipedia documents from WebText."

GPT-3 bảng 2.2, hỗn hợp dữ liệu:

| Dataset | Quantity (tokens) | Weight in training mix | Epochs elapsed at 300B |
|---|---|---|---|
| Common Crawl (filtered) | 410 billion | 60% | 0.44 |
| WebText2 | 19 billion | 22% | 2.9 |
| Books1 | 12 billion | 8% | 1.9 |
| Books2 | 55 billion | 8% | 0.43 |
| Wikipedia | 3 billion | 3% | 3.4 |

### 6.5 GPT-1, hai mục tiêu và trọng số

Phương trình (1) là `L1`, phương trình (4) là `L2`, phương trình (5) là
`L3(C) = L2(C) + lambda * L1(C)`, và mục 4.1 đặt `lambda` bằng 0.5.

Mục 3.3: "we use a traversal-style approach [52], where we convert structured
inputs into an ordered sequence that our pre-trained model can process. These
input transformations allow us to avoid making extensive changes to the
architecture across tasks."

## 7. Cái chương này không đo được, và đã ghi lại là không đo

Theo `README.md` của thư mục này: ghi cả những phép đo hóa ra không dùng được.

1. **Bảng A4 của Hoffmann**, mục 3.4. Đã quét chín cặp `(n, V)` và không cặp
   nào tái lập cột đã in. Nguyên nhân là bài không in hai tham số ấy.
2. **Một thí nghiệm tiền huấn luyện trên corpus của quyết định 35.** Không
   chạy, và lý do là lý do thiết kế chứ không phải lý do ngân sách. Văn phạm
   hữu hạn, từ điển đóng, không có nhập nhằng (quyết định 35 và 44), nên tập
   kiểm tra rút từ cùng văn phạm không phải một miền khác - nó là cùng một
   phân phối. Một mô hình "tiền huấn luyện" trên nó rồi "tinh chỉnh" sang nó
   chỉ đang huấn luyện lâu hơn. Số đo sẽ có, và sẽ không đo cái mà chương này
   nói về. SPEC đã cảnh báo đúng chỗ này trước phiên làm việc.
3. **Thống kê `q . k` sau huấn luyện** (quyết định 54) vẫn chưa đo. Chương 9
   không cần nó và không đo nó.
