# Chương 05: Encoder-decoder (Sutskever, Vinyals, Le 2014)

Ghi ngày 2026-08-10.

Ghi chú nguồn và số đo cho chương 5. Mọi số thập phân chương 5 in ra đều phải
có mặt ở đây (quyết định 20 trong SPEC).

## Bài báo

File đọc: `4. Sequence to Sequence Learning with Neural Networks.pdf`, thư mục
trong `2026-08-nguon-sau-bai-bao.md`. Bản arXiv:1409.3215v3, đề ngày 14 Dec
2014, 9 trang. 112084 byte.

### Venue: món nợ từ phiên skeleton, nay trả xong

Manifest ghi trang bìa file **không nói venue**, và ghi đó là việc chương 05
phải làm. Đã tra:

- `papers.nips.cc/paper_files/paper/2014` liệt kê bài dưới tên kỷ yếu
  **Advances in Neural Information Processing Systems 27**, biên tập Z.
  Ghahramani, M. Welling, C. Cortes, N. Lawrence, K. Weinberger, nhà xuất bản
  Curran Associates, ISBN 9781510800410. Đọc ngày 2026-08-10.
- Số trang **3104-3112**, lấy từ DBLP `conf/nips/SutskeverVL14`. Ghi rõ nguồn
  vì file BibTeX mà chính papers.nips.cc xuất ra để trống trường `pages`; hai
  chỗ này không cùng một nguồn và không được trộn lẫn.

Bản arXiv đánh trang 1 tới 9, kỷ yếu đánh 3104 tới 3112. **Số trang hai bản
không dùng lẫn được**, giống hệt tình huống bài Pascanu ở chương 3.

### Cái bẫy trung tâm của chương này

Manifest đã cảnh báo từ phiên skeleton, và đọc toàn văn thì nó còn rõ hơn.
Chuyện người ta hay kể là "Seq2Seq hỏng ở câu dài, nên Bahdanau ra đời".
Câu đó sai với chính lời của cả ba bài.

1. **Tóm tắt của Sutskever nói ngược lại:** "Additionally, the LSTM did not
   have difficulty on long sentences."
2. **Mục 3.7 tên là "Performance on long sentences"** và mở đầu bằng "We were
   surprised to discover that the LSTM did well on long sentences". Chú thích
   hình 3: "There is no degradation on sentences with less than 35 words, there
   is only a minor degradation on the longest sentences."
3. **Kết luận, mục 5:** "We were also surprised by the ability of the LSTM to
   correctly translate very long sentences. We were initially convinced that
   the LSTM would fail on long sentences due to its limited memory, and other
   researchers reported poor performance on long sentences with a model similar
   to ours [5, 2, 26]."
4. **Mục 4 của chính Sutskever gán kết quả ấy cho người khác:** "Bahdanau et
   al. [2] also attempted direct translations with a neural network that used
   an attention mechanism to overcome the poor performance on long sentences
   experienced by Cho et al. [5]."

**Và "Cho et al." nào mới là chỗ dễ sai tiếp theo.** Bahdanau phân biệt hai bài
Cho 2014 khác nhau, và phần mở đầu của Bahdanau viết:

> "A potential issue with this encoder-decoder approach is that a neural
> network needs to be able to compress all the necessary information of a
> source sentence into a fixed-length vector. This may make it difficult for
> the neural network to cope with long sentences, especially those that are
> longer than the sentences in the training corpus. Cho et al. (2014b) showed
> that indeed the performance of a basic encoder-decoder deteriorates rapidly
> as the length of an input sentence increases."

- **Cho et al. 2014a** = "Learning Phrase Representations using RNN
  Encoder-Decoder for Statistical Machine Translation", EMNLP 2014, trang
  1724-1734, arXiv:1406.1078. Đây là bài chương 04 đã trích cho đơn vị có cổng.
- **Cho et al. 2014b** = "On the Properties of Neural Machine Translation:
  Encoder-Decoder Approaches", SSST-8, Doha, tháng 10 năm 2014, trang 103-111,
  DOI 10.3115/v1/W14-4012, arXiv:1409.1259. **Đây mới là bài đo độ tụt theo độ
  dài câu.** Tóm tắt, chép nguyên: "We show that the neural machine translation
  performs relatively well on short sentences without unknown words, but its
  performance degrades rapidly as the length of the sentence and the number of
  unknown words increase."

Mới đọc tóm tắt của 1409.1259, chưa đọc thân bài. Chương chỉ được trích ở mức
phát biểu, không được trích số.

### Mô hình, đọc thẳng từ mục 2

Mục tiêu là ước lượng `p(y_1..y_T' | x_1..x_T)` với `T'` khác `T` được. Cách
làm, chép nguyên: LSTM tính xác suất ấy "by first obtaining the fixed-
dimensional representation v of the input sequence (x_1, ..., x_T) given by the
last hidden state of the LSTM, and then computing the probability of y_1, ...,
y_T' with a standard LSTM-LM formulation whose initial hidden state is set to
the representation v".

Phương trình (1):

```
p(y_1..y_T' | x_1..x_T) = prod_{t=1}^{T'} p(y_t | v, y_1..y_{t-1})
```

Mỗi phân phối `p(y_t | v, y_1..y_{t-1})` là một softmax trên toàn bộ từ điển.
Mỗi câu kết thúc bằng ký hiệu `<EOS>`, và bài nói rõ vì sao: nó "enables the
model to define a distribution over sequences of all possible lengths".

**Ba chỗ bài nói mô hình thật của họ khác mô tả trên**, mục 2:

1. Hai LSTM khác nhau, một cho input một cho output, "because doing so
   increases the number model parameters at negligible computational cost and
   makes it natural to train the LSTM on multiple language pairs
   simultaneously".
2. LSTM sâu hơn hẳn LSTM nông, nên họ chọn 4 tầng.
3. Đảo thứ tự từ của câu nguồn. "instead of mapping the sentence a, b, c to the
   sentence alpha, beta, gamma, the LSTM is asked to map c, b, a to alpha,
   beta, gamma ... This way, a is in close proximity to alpha, b is fairly
   close to beta, and so on, a fact that makes it easy for SGD to 'establish
   communication' between the input and the output."

**Ngữ cảnh vào một lần duy nhất, ở trạng thái khởi tạo.** Không nạp lại ở mỗi
bước decoder. Đây là chỗ khác Cho 2014a, nơi decoder đọc `c` ở mọi bước, và nó
là lý do vector ấy là chỗ thắt chứ không phải một gợi ý.

### "LSTM formulation from Graves" là bản nào

Mục 2 viết "We use the LSTM formulation from Graves [10]", tức
arXiv:1308.0850. Đã đọc mục 2.1 của bản v5 (5 Jun 2014), phương trình (7) tới
(11), chép nguyên:

```
i_t = sigma(W_xi x_t + W_hi h_{t-1} + W_ci c_{t-1} + b_i)
f_t = sigma(W_xf x_t + W_hf h_{t-1} + W_cf c_{t-1} + b_f)
c_t = f_t c_{t-1} + i_t tanh(W_xc x_t + W_hc h_{t-1} + b_c)
o_t = sigma(W_xo x_t + W_ho h_{t-1} + W_co c_t + b_o)
h_t = o_t tanh(c_t)
```

Graves ghi rõ "The weight matrices from the cell to gate vectors (e.g. W_ci)
are diagonal". Nghĩa là bản Sutskever dùng có **cả cổng quên của Gers 2000 lẫn
peephole của Gers 2002**, và tanh ở cả hai chỗ nén. Chương 04 đã dựng đúng hai
hộp cầu nối ấy, nên chương 05 nối vào được mà không phải giải thích lại.

Graves cũng nói thẳng chỗ chương 04 đã dựng cả một mục: "The original LSTM
algorithm used a custom designed approximate gradient calculation that allowed
the weights to be updated after every timestep [16]. However the full gradient
can instead be calculated with backpropagation through time [11], the method
used in this paper."

### Số của bài (số của họ, không phải số tôi đo)

Mục 3.1, dữ liệu: WMT'14 Anh-Pháp, tập con 12M câu gồm 348M từ tiếng Pháp và
304M từ tiếng Anh. Từ điển 160,000 từ nguồn và 80,000 từ đích; ngoài từ điển
thì thay bằng `UNK`.

Mục 3.4, mô hình: 4 tầng, 1000 cell mỗi tầng, embedding 1000 chiều. "Thus the
deep LSTM uses 8000 real numbers to represent a sentence." 384M tham số, trong
đó 64M là kết nối hồi quy thuần (32M encoder, 32M decoder). Khởi tạo đều trong
[-0.08, 0.08]. SGD không momentum, learning rate cố định 0.7; sau 5 epoch thì
giảm nửa mỗi nửa epoch; tổng cộng 7.5 epoch. Batch 128. Mỗi tầng thêm vào giảm
perplexity gần 10%.

Cắt gradient, chép nguyên: "For each training batch, we compute s = ||g||_2,
where g is the gradient divided by 128. If s > 5, we set g = 5g/s." Xếp câu
cùng độ dài vào một minibatch cho tốc độ gấp đôi.

Mục 3.5: một GPU chạy khoảng 1,700 từ mỗi giây, quá chậm, nên họ dùng máy 8
GPU và đạt 6,300 từ mỗi giây; huấn luyện mất khoảng mười ngày.

Bảng 1, BLEU trên ntst14:

| Phương pháp | BLEU |
|---|---|
| Bahdanau và cộng sự | 28.45 |
| Baseline SMT | 33.30 |
| Một LSTM xuôi, beam 12 | 26.17 |
| Một LSTM đảo, beam 12 | 30.59 |
| Ensemble 5 LSTM đảo, beam 1 | 33.00 |
| Ensemble 2 LSTM đảo, beam 12 | 33.27 |
| Ensemble 5 LSTM đảo, beam 2 | 34.50 |
| Ensemble 5 LSTM đảo, beam 12 | 34.81 |

Chú thích bảng 1: "an ensemble of 5 LSTMs with a beam of size 2 is cheaper than
of a single LSTM with a beam of size 12".

Bảng 2, dùng chung với hệ SMT: baseline 33.30; Cho và cộng sự 34.54; kết quả
WMT'14 tốt nhất 37.0; rescoring 1000-best bằng một LSTM xuôi 35.61, bằng một
LSTM đảo 35.85, bằng ensemble 5 LSTM đảo 36.5; oracle khoảng 45.

Mục 3.6, câu bài tự tổng kết chỗ đứng của kết quả, chép nguyên: kết quả của họ
là lần đầu \"a pure neural translation system outperforms a phrase-based SMT
baseline on a large scale MT task by a sizeable margin, despite its inability
to handle out-of-vocabulary words\". Và ngay sau đó: \"The LSTM is within 0.5
BLEU points of the best WMT'14 result if it is used to rescore the 1000-best
list of the baseline system.\"

Mục 3.2 về beam search, chép nguyên đoạn quyết định: "We search for the most
likely translation using a simple left-to-right beam search decoder which
maintains a small number B of partial hypotheses, where a partial hypothesis is
a prefix of some translation. At each timestep we extend each partial
hypothesis in the beam with every possible word in the vocabulary. This greatly
increases the number of the hypotheses so we discard all but the B most likely
hypotheses according to the model's log probability. As soon as the '<EOS>'
symbol is appended to a hypothesis, it is removed from the beam and is added to
the set of complete hypotheses." Và: "our system performs well even with a beam
size of 1, and a beam of size 2 provides most of the benefits of beam search".

Mục 3.3, đảo câu nguồn: perplexity trên tập test giảm từ 5.8 xuống 4.7, BLEU
tăng từ 25.9 lên 30.6. Lời giải thích của bài là về khoảng cách: "By reversing
the words in the source sentence, the average distance between corresponding
words in the source and target language is unchanged. However, the first few
words in the source language are now very close to the first few words in the
target language, so the problem's minimal time lag is greatly reduced." Và chỗ
bài tự nói là bất ngờ: "LSTMs trained on reversed source sentences did much
better on long sentences than LSTMs trained on the raw source sentences (see
sec. 3.7), which suggests that reversing the input sentences results in LSTMs
with better memory utilization."

Mục 4, quyền ưu tiên: "Our work is closely related to Kalchbrenner and Blunsom
[18], who were the first to map the input sentence into a vector and then back
to a sentence, although they map sentences to vectors using convolutional
neural networks, which lose the ordering of the words." Kalchbrenner và Blunsom
là "Recurrent Continuous Translation Models", EMNLP 2013, trang 1700-1709; chỉ
tra thư mục trên ACL Anthology, chưa đọc bài, nên chương chỉ được dùng đúng câu
gán quyền ưu tiên này.

Mục 5, một chỗ bài tự nhận chưa kiểm: "while we were unable to train a standard
RNN on the non-reversed translation problem (shown in fig. 1), we believe that
a standard RNN should be easily trainable when the source sentences are
reversed (although we did not verify it experimentally)."

## Số tôi đo

### Môi trường và cách chạy lại

Repo companion: https://github.com/Giang-Dang/rnn-to-transformer-lab, tag
`ch05`.

Tag `ch05` được dời một lần trong phiên này, và ghi lại vì dời một tag đã push
là chuyện phải nhìn thấy được. Lý do: audit chỉ ra hai chữ ký hàm mà sách in ra
đã bị cắt bỏ annotation cho vừa 73 cột, trong khi quyết định 31 nói phải *ngắt
dòng* chứ không phải cắt. Sửa ở phía repo cho hai bên khớp nhau, nên
`encode` và `decode_forced` bây giờ ngắt dòng trong chính source. Cùng lần đó
sửa một comment trong `toy_corpus.py` nói sai rằng động từ tiếng Anh dài một
hoặc hai token; mọi động từ tiếng Anh trong văn phạm đúng một token. Không có
thay đổi hành vi nào, và `verify.py` chạy lại sau khi dời.

```
git clone git@github.com:Giang-Dang/rnn-to-transformer-lab.git
cd rnn-to-transformer-lab
git checkout ch05
conda env create -f environment.yml
conda activate rnn-to-transformer-lab
python verify.py --only ch05
```

Mọi script in ra dòng phiên bản trước khi in số:

```
python 3.12.13 | torch 2.11.0+cpu | numpy 2.2.6 | Windows AMD64
```

Máy đo: laptop, CPU, không dùng card đồ hoạ.

### Tập dữ liệu: vì sao là corpus sinh ra chứ không phải corpus có thật

Mục mở trong SPEC nói tập chạy xuyên chương 5 tới 8 là "một tập song ngữ
Việt-Anh cỡ nhỏ", đề xuất chứ chưa chốt. Chốt ở phiên này: **corpus sinh từ một
văn phạm, nằm trong repo, không tải gì**. Ba ràng buộc cùng lúc, và không tập
công khai nào thoả cả ba:

1. Phải chạy xong trên CPU trong ngân sách của quyết định 27.
2. Phải tái lập được từ một seed, không phụ thuộc mạng, để `verify.py` chạy
   được ở máy khác.
3. Hai thứ tiếng phải khác thứ tự từ đủ để ma trận đồng chỉnh của chương 6 cho
   thấy một chỗ bắt chéo chứ không phải một đường chéo.

Điểm thứ ba là điểm duy nhất corpus này mô hình hoá thật: **cụm danh từ đảo**.
Tiếng Anh đặt tính từ trước danh từ, tiếng Việt đặt sau; tiếng Anh đánh dấu
xác định bằng mạo từ, tiếng Việt dùng loại từ, và loại từ không có từ tiếng Anh
tương ứng.

```
the black cat  ->  con  mèo  đen
a  new  lamp   ->  một cái  đèn  mới
```

Cái corpus này **không** mô hình hoá, và chương không được nói ngược: văn phạm
hữu hạn và phi ngữ cảnh nên học thuộc được; không có hình thái, không có hợp
giống số, không có nhập nhằng, không có từ hiếm, nên bài toán ngoài từ điển,
thứ ăn mất phần lớn BLEU của Sutskever, không thể xảy ra ở đây; và câu thì vô
nghĩa về mặt nội dung ("con mèo mang một cái đèn mới").

`python experiments/ch05_corpus.py`:

```
source vocabulary 34 types, target 37 types (both closed, both include <pad> <sos> <eos>)

split  pairs  src min  src max  src mean  tgt min  tgt max  tgt mean
train  6000   5        21       12.232    5        25       13.716
test   300    5        21       12.397    6        24       13.877

target longer than source in 0.7800 of training pairs
source sentences shared between train and test: 0
```

Ba câu một mệnh đề đầu tiên của tập huấn luyện, chép nguyên cả ba:

```
  en  the white bird wants the chair at the window
  vi  con chim trắng muốn cái ghế cạnh cửa sổ
  en  the cat wants a dog
  vi  con mèo muốn một con chó
  en  the horse carries the small hat
  vi  con ngựa mang cái mũ nhỏ
```

Sách chỉ in hai cặp đầu, vì cặp thứ ba không thêm gì cho lập luận ở chỗ đó;
việc cắt là việc của trang sách, còn note này giữ nguyên output. Script cũng in
ba câu hai mệnh đề đầu tiên, và chúng vượt 100 cột nên không đặt vừa khổ chữ
của sách. Chính vì thế script chia sẵn hai nhóm thay vì in năm câu đầu bất kỳ.

Số cặp bị loại vì trùng giữa train và test: đo được 0 câu chung, bằng cách rút
dư rồi lọc, chứ không phải bằng cách giả định.

### Công thức đo: khớp đúng cả câu, không phải BLEU

Mọi bảng dưới đây đo **exact match**: cả câu đích đúng từng token thì tính 1,
sai một token thì tính 0. Không dùng BLEU, có chủ ý. Trên một corpus nhỏ và đều
thế này BLEU đo một thứ không đáng tin, còn cái hỏng mà chương quan tâm là mô
hình đặt tính từ sai bên, tức một câu sai chứ không phải một câu hơi kém hơn.

Cột `short` là câu nguồn từ 11 token trở xuống, `long` là dài hơn. Ngưỡng 11 là
biên giữa một mệnh đề và hai mệnh đề của văn phạm, chọn trước khi nhìn kết quả,
không phải sau. Trong 300 câu test thì 148 câu ngắn và 152 câu dài.

### Cấu hình dùng chung

Bốn script chương 5 in ra các bảng mà chương đặt cạnh nhau, nên chúng phải cùng
một thiết lập, và thiết lập ấy nằm một chỗ trong `seq2seq.py` chứ không chép
vào từng script: 6000 cặp huấn luyện, 300 cặp test, batch 128, 14 epoch,
learning rate 0.005, Adam, cắt gradient ở norm 5.0, `d_hidden = 128`,
embedding 32 chiều.

**14 epoch là ngân sách chứ không phải hội tụ.** Cùng mô hình chạy 20 epoch cho
exact match 0.9200 và 40 epoch cho 0.9425, so với 0.8533 ở 14 epoch. Chương in
số ở 14 vì mọi so sánh trong chương cần hai vế dừng ở cùng một chỗ, và vì 15
lần huấn luyện phải nằm trong ngân sách cả lần chạy.

### Đo 1: chỗ thắt, đo bằng cách bóp vector ngữ cảnh

`python experiments/ch05_bottleneck.py`. Giữ nguyên corpus, optimizer, seed và
số lần cập nhật; chỉ đổi bề rộng vector ngữ cảnh. Decoder nhận đúng
`2 * d_hidden` số thực, bất kể câu nguồn dài bao nhiêu.

```
d_hidden  context  params   loss     exact    short    long
4         8        3641     1.5756   0.0000   0.0000   0.0000
8         16       5229     1.1748   0.0000   0.0000   0.0000
16        32       9173     0.8733   0.0033   0.0068   0.0000
32        64       20133    0.5584   0.1433   0.2905   0.0000
64        128      54341    0.1429   0.5200   0.9797   0.0724
128       256      171909   0.0251   0.8533   1.0000   0.7105
```

Chạy hết 69.52 giây.

Chỗ đáng đọc không phải cột `exact` mà là hai cột cuối. Vector hẹp **không**
hỏng đều: ở `d_hidden = 64`, câu ngắn đã đạt 0.9797 trong khi câu dài còn
0.0724. Đó chính là hình dạng của "câu phải nhét vừa vào vector", đo được chứ
không phải phát biểu.

Một seed mỗi dòng. Chấp nhận được ở đây vì hiệu ứng giữa hai đầu bảng là cả
quãng từ 0 tới gần hết, còn đo 2 bên dưới chỉ chênh vài điểm nên phải lặp.

### Đo 2: đảo câu nguồn

`python experiments/ch05_reverse.py`. Ba seed mỗi vế, và in cả từng seed chứ
không chỉ trung bình, vì độ tản giữa các seed ở quy mô này rộng hơn hiệu ứng
đang đo.

```
source     seed  loss     exact    short    long
raw        0     0.0644   0.6733   1.0000   0.3553
raw        1     0.1392   0.5367   1.0000   0.0855
raw        2     0.0997   0.5933   1.0000   0.1974
reversed   0     0.0251   0.8533   1.0000   0.7105
reversed   1     0.0652   0.6433   0.9797   0.3158
reversed   2     0.0353   0.8433   1.0000   0.6908

mean over seeds:
source     exact    short    long
raw        0.6011   1.0000   0.2127
reversed   0.7800   0.9932   0.5724

reversed minus raw:
  exact  +0.1789
  short  -0.0068
  long   +0.3596
```

Chạy hết 125.55 giây.

Đây là chỗ kết quả sắc hơn lời của bài. Lập luận của Sutskever là về khoảng
cách, và lập luận ấy dự đoán một thứ mạnh hơn "đảo thì tốt hơn": phần lời phải
rơi vào câu dài, vì với câu ngắn thì mọi từ đã đủ gần rồi. Đo được đúng thế:
câu ngắn đứng yên ở 1.0000 so với 0.9932, câu dài đi từ 0.2127 lên 0.5724.

**So từng cặp cùng seed thì 3 trên 3 lần đảo thắng không đảo**, và đó mới là
cách đọc đúng bảng này, vì hai vế cùng seed dùng chung cả khởi tạo lẫn thứ tự
batch. Trung bình một mình thì không nói được điều đó: seed 1 đảo (0.6433) còn
thấp hơn seed 0 không đảo (0.6733).

### Đo 3: beam search và ensemble

`python experiments/ch05_search.py`. Cả hai đều đổi cái đi ra khỏi một mô hình
đã huấn luyện xong mà không đổi mô hình, và bảng 1 của bài báo cáo chúng cùng
nhau, nên đo cùng nhau trên cùng ba mô hình.

Ba mô hình chỉ khác nhau ở seed, tức khác cả khởi tạo lẫn thứ tự minibatch,
đúng hai thứ mà bài nói năm thành viên ensemble của họ khác nhau:

```
one model at a time, beam 2:
seed  exact    short    long
0     0.8733   1.0000   0.7500
1     0.6767   0.9797   0.3816
2     0.8700   1.0000   0.7434
```

Độ tản giữa ba seed là 0.6767 tới 0.8733, tức gần 20 điểm. **Đây là bối cảnh
mọi con số khác trong chương phải được đọc cùng.**

Bề rộng beam, riêng mô hình seed 0:

```
beam  exact    short    long     mean output length
1     0.8533   1.0000   0.7105   13.883
2     0.8733   1.0000   0.7500   13.887
5     0.8833   1.0000   0.7697   13.877
12    0.8833   1.0000   0.7697   13.877
```

Khớp hình dạng bài mô tả: beam 1 đã chạy tốt, beam 2 lấy được 0.0200 trên tổng
0.0300 mà beam mang lại, tức hai phần ba, và beam 12 không hơn beam 5 một chữ
số nào. Độ dài output trung bình bám sát độ dài tham chiếu 13.877 ở mọi beam,
nên không có thiên lệch độ dài ở đây.

Cỡ ensemble, beam 2:

```
models  exact    short    long
1       0.8733   1.0000   0.7500
2       0.9467   1.0000   0.8947
3       0.9867   1.0000   0.9737
```

Chạy hết 94.54 giây.

**So hai cột ấy với nhau mới là chỗ đáng nói.** Nới beam từ 1 lên 12 được
0.0300. Thêm hai mô hình được 0.1134, gấp gần bốn lần, và trên câu dài thì
0.7500 lên 0.9737. Bài cho cùng thứ tự độ lớn: một LSTM đảo beam 12 được 30.59,
ensemble 5 LSTM beam 12 được 34.81, còn nới beam từ 1 lên 12 trên cùng
ensemble 5 chỉ đi từ 33.00 lên 34.81.

Ensemble 3 (0.9867) cao hơn mô hình đơn tốt nhất trong ba (0.8733) 0.1134,
nên đây không phải chuyện chọn được mô hình may mắn.

### Đo 4: luật dừng sai của beam search, và giá của nó

Đây là một phép đo về code của chính tôi chứ không về bài báo, và nó không nằm
trong tag: bản `beam_decode` ở tag `ch05` đã đúng. Sách in số này nên số phải
tra ngược được, và cách tái lập là dán hàm dưới đây vào một script rồi chạy nó
cạnh bản trong tag.

**Cảnh báo, và đây là lý do mục này tồn tại ở dạng hiện tại.** Bản nháp đầu của
chương in 0.7550, 0.7875, 0.8075 và 0.8918 cho chỗ này. Bốn số ấy có thật,
nhưng chúng đến từ một lần chạy thăm dò *trước* khi cấu hình dùng chung được
chốt: `N_TEST = 400` chứ không phải 300, và seed của generator thứ tự batch là
1 chứ không phải `100 + seed`. Chúng không tái lập được ở tag `ch05` và audit
bắt được. Đo lại đúng cấu hình đã chốt:

```
stop rule  beam  exact    short    long     mean output length
greedy     -     0.8533   1.0000   0.7105   13.883
broken     1     0.8533   1.0000   0.7105   13.883
broken     2     0.8400   0.9527   0.7303   13.827
broken     5     0.8767   1.0000   0.7566   13.863
broken     12    0.8800   1.0000   0.7632   13.867
fixed      1     0.8533   1.0000   0.7105   13.883
fixed      2     0.8733   1.0000   0.7500   13.887
fixed      5     0.8833   1.0000   0.7697   13.877
fixed      12    0.8833   1.0000   0.7697   13.877
```

Kết luận định tính không đổi và bây giờ mới có số chống lưng: ở beam 2 luật sai
cho 0.8400, thấp hơn greedy 0.8533, và chỗ mất nằm ở câu **ngắn** (1.0000 xuống
0.9527) chứ không phải câu dài (0.7105 lên 0.7303). Câu ngắn là câu có
hypothesis kết thúc sớm, nên chúng đúng là nhóm mà luật "dừng khi đủ `B`
hypothesis hoàn tất" cắt ngang.

Hàm `broken`, chép nguyên phần khác với bản trong tag: bỏ dòng cắt tỉa theo
`best_finished`, nạp lại `live` cho đủ `beam` phần tử bất kể bao nhiêu
hypothesis vừa kết thúc, rồi thoát khi `len(finished) >= beam`.

```python
candidates.sort(key=lambda it: it[1], reverse=True)
live = []
for tokens, score, hyp_states in candidates:
    if len(live) >= beam:
        break
    if tokens[-1] == eos:
        finished.append((tokens[:-1], score))
    else:
        live.append((tokens, score, hyp_states))
if len(finished) >= beam:
    break
```

Chuẩn hoá theo độ dài trên chính bản `broken` ấy: beam 2 cho 0.8400, 0.9527,
0.7303, tức **không đổi một chữ số nào**; chỉ độ dài trung bình nhúc nhích từ
13.827 lên 13.840. Beam 5 cũng vậy, 0.8767 và 13.867.

## Đo rồi mà không dùng, ghi lại để khỏi đo lại

- **Beam search không đơn điệu theo bề rộng beam, và tôi đã viết một test sai
  vì tưởng nó đơn điệu.** Lập luận sai: beam rộng sinh ra tập ứng viên bao tập
  của beam hẹp, nên hypothesis trả về phải có log-xác suất không nhỏ hơn. Chỗ
  hổng: mỗi bước chỉ giữ `B` ứng viên *tốt nhất*, và tiền tố mà beam hẹp giữ
  lại có thể xếp dưới hạng `B` trong tập ứng viên lớn hơn của beam rộng, nên bị
  loại. Phản ví dụ đo được, mô hình `d_hidden = 16` huấn luyện 1 epoch, seed
  generator 6: beam 2 trả về hypothesis điểm `-4.758864402770996`, beam 5 trả
  về `-9.162103652954102`. Test đã đổi thành khẳng định đúng thứ nó bảo vệ, và
  một test riêng khoá lại chuyện `decode_forced` và `decoder.step` cho cùng
  logits.
- **Cách đọc đầu tiên cho đo 4 là sai, và sai theo kiểu dễ tin.** Tôi cho rằng
  thủ phạm là thiên lệch độ dài, tức beam search thích câu ngắn vì log-xác suất
  cộng dồn toàn số âm. Số ở đo 4 bác bỏ: lệch 0.05 token, và chuẩn hoá độ dài
  không đổi được chữ số nào. Bài học kép: một cái tên nghe đúng không phải một
  chẩn đoán, và một con số đo ở cấu hình khác không phải một con số.
- **Corpus bản đầu sinh ra "a old chair".** Tiếng Anh cần "an" trước nguyên âm,
  tiếng Việt không có luật ấy. Đã sửa, và chỗ sửa lại thành một ví dụ nữa cho
  chuyện một token bên nguồn không ứng với gì bên đích.
- **`conda run -n <env> python -c` không nhận lệnh nhiều dòng**, báo
  `NotImplementedError: Support for scripts where arguments contain newlines
  not implemented`. Gọi thẳng
  `envs/rnn-to-transformer-lab/python.exe` thì được.
- **In tiếng Việt ra stdout hỏng trên Windows.** `UnicodeEncodeError` từ
  `cp1252`, và `verify.py` bắt stdout qua pipe nên gặp đúng lỗi ấy chứ không
  chỉ ở console. Đã thêm `utf8_stdout()` vào `determinism.py`; mọi script
  chương 5 gọi nó trước dòng in đầu tiên.

## Việc còn nợ sau chương này

- Cho và cộng sự 2014b (arXiv:1409.1259) mới đọc tóm tắt. Chương 6 muốn trích
  đường cong BLEU theo độ dài của bài đó thì phải đọc thân bài trước.
- Kalchbrenner và Blunsom 2013 mới tra thư mục, chưa đọc. Chương nào muốn nói
  gì hơn câu gán quyền ưu tiên của Sutskever thì phải đọc bài.
- Corpus sinh ra này cố ý không có từ ngoài từ điển. Chương nào muốn nói về
  `UNK` và về việc BLEU của Sutskever bị phạt vì từ ngoài từ điển thì phải dựng
  thêm, hoặc chỉ được trích số của bài.
- Mô hình của repo là một tầng, không peephole, còn bài dùng bốn tầng và bản
  Graves có peephole. Chương 5 nói rõ chỗ đó. Chương nào cần đo ảnh hưởng của
  số tầng thì phải dựng thêm.
