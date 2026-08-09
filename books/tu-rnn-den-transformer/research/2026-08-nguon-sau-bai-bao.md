# Nguồn: sáu bài báo gốc

Ghi ngày 2026-08-09.

Cuốn sách này dựng trên sáu file PDF nằm ngoài repo. File này là con trỏ tới
chúng, không phải bản sao của chúng.

## Vì sao repo không chứa các PDF

`latex-books` có remote công khai (`git@github.com:Giang-Dang/latex-books.git`).
Bài "Long Short-Term Memory" là bài tạp chí Neural Computation của MIT Press, và
đẩy nó lên một repo trên GitHub là phát hành lại một tác phẩm có bản quyền, chứ
không phải lưu trữ nội bộ. Bốn bài trên arXiv có giấy phép dễ thở hơn nhưng
không vì thế mà cần nằm trong repo: thứ một phiên làm việc sau cần là biết đọc
file nào, ở đâu, và có đúng bản mình đã trích hay không. Ba thứ đó là bảng bên
dưới, tốn vài kilobyte thay vì bảy megabyte.

Nếu về sau muốn có bản sao cục bộ cho tiện, để nó ngoài cây git. Đừng thêm luật
bỏ qua `*.pdf` trong thư mục sách: `figures/images/` có thể chứa hình dạng PDF
và luật đó sẽ nuốt mất chúng.

## Thư mục gốc

```
C:\Users\dangv\OneDrive\Programming\Papers\Transformers
```

Số thứ tự trong tên file là thứ tự tải về của tác giả, không phải thứ tự thời
gian và cũng không phải thứ tự chương. Sách đọc chúng theo trục vấn đề: chương 3
đọc bài số 1, chương 4 đọc bài số 2, chương 5 đọc bài số 4, chương 6 đọc bài số
3, chương 7 đọc bài số 5, chương 11 đọc bài số 6.

## Bảng đối chiếu

Cột "bản đã đọc" lấy từ chính trang bìa của file, không lấy từ trí nhớ. Cột
"venue trên trang bìa" chỉ ghi khi file tự nói; chỗ nào file im lặng thì ghi là
im lặng, và chương tương ứng phải tự xác minh trước khi trích số trang.

| File | Chương dùng | Bản đã đọc | Venue trên trang bìa |
|------|-------------|-----------|----------------------|
| `1. On the difficulty of training recurrent neural networks.pdf` | 03 | arXiv:1211.5063v2, cs.LG, 16 Feb 2013 | không ghi |
| `2. Long Short-Term Memory.pdf` | 04 | không có số arXiv | Neural Computation 9(8):1735-1780, 1997 |
| `3. Neural Machine Translation by Jointly Learning to Align and Translate.pdf` | 06 | arXiv:1409.0473v7, cs.CL, 19 May 2016 | Published as a conference paper at ICLR 2015 |
| `4. Sequence to Sequence Learning with Neural Networks.pdf` | 05 | arXiv:1409.3215v3, cs.CL, 14 Dec 2014 | không ghi |
| `5. Attention Is All You Need.pdf` | 07 | arXiv:1706.03762v7, cs.CL, 2 Aug 2023 | 31st Conference on Neural Information Processing Systems (NIPS 2017), Long Beach, CA, USA |
| `6. An Image is Worth 16x16 Words- Transformers for Image Recognition at Scale (ViT).pdf` | 11 | arXiv:2010.11929v2, cs.CV, 3 Jun 2021 | Published as a conference paper at ICLR 2021 |

## Vân tay file

Đo bằng `Get-FileHash -Algorithm SHA256` ngày 2026-08-09. Nếu một hash lệch,
file đã bị thay bản khác và mọi số trang trích từ nó phải kiểm lại.

| File | Bytes | SHA-256 |
|------|-------|---------|
| 1. On the difficulty... | 615896 | `67c3d44b0f7cb1fc148069d14066b7aa7617fd37b9d7bd0040dc275506a9bf6e` |
| 2. Long Short-Term Memory | 396938 | `ceb9e53dbc0493f5b3bf5520ed940f3e6b526064d17b2118d77e51f79c0edcc6` |
| 3. Neural Machine Translation... | 444482 | `84801c8410da51b449d379d2fa4939a416123f2c93991077a680f863026022a7` |
| 4. Sequence to Sequence Learning... | 112084 | `5c74e1db863e2d61b869c9b0603494b34c41fb05db1a4fa7f9a83d5a42b7350f` |
| 5. Attention Is All You Need | 2215244 | `bdfaa68d8984f0dc02beaca527b76f207d99b666d31d1da728ee0728182df697` |
| 6. An Image is Worth 16x16 Words | 3743814 | `8ce7b83971a14508ca711a27c875c9b6914c4f6767cf3150fb1ca6c07aa056d6` |

## Hai chỗ vênh đã thấy ngay từ trang bìa

Ghi lại vì cả hai đều đủ sức làm hỏng một chương nếu đọc lướt.

1. **Bản arXiv của "Attention Is All You Need" đề ngày 2 Aug 2023**, sáu năm sau
   hội nghị. Trích câu chữ từ file này rồi gán cho năm 2017 là gán sai. Chương 7
   phải đối chiếu với bản kỷ yếu trước khi nói "các tác giả viết năm 2017 rằng".
   Bản Bahdanau cũng vậy: v7 đề 19 May 2016 trong khi hội nghị là ICLR 2015.
2. **Sutskever và cộng sự nói ngược điều người ta hay gán cho họ.** Tóm tắt của
   họ viết thẳng: "the LSTM did not have difficulty on long sentences". Người
   chỉ ra encoder-decoder tụt theo độ dài câu là Cho và cộng sự 2014, và chính
   phần mở đầu của Bahdanau dẫn nguồn như vậy. Chương 5 và 6 không được kể câu
   chuyện "Seq2Seq hỏng ở câu dài nên Bahdanau ra đời" theo kiểu đơn giản hoá
   đó, vì nó sai với chính lời của cả hai bài.

## Số liệu đọc thẳng từ tóm tắt

Đây là số của tác giả gốc, không phải số tôi đo. Chương nào dùng thì trích dẫn,
và mọi con số ở đây đều phải kiểm lại trong phần thân bài của bài báo trước khi
in, vì tóm tắt hay làm tròn.

- Sutskever và cộng sự, WMT'14 Anh-Pháp: BLEU 34.8 trên toàn bộ tập test; hệ
  phrase-based SMT đối chứng đạt 33.3; dùng LSTM xếp hạng lại 1000 giả thuyết
  của hệ SMT đó thì lên 36.5.
- Vaswani và cộng sự, WMT 2014: BLEU 28.4 Anh-Đức, hơn kết quả tốt nhất trước đó
  (kể cả ensemble) trên 2 BLEU; BLEU 41.8 Anh-Pháp cho một model đơn, sau 3.5
  ngày trên tám GPU.

## Việc còn nợ

- Chương 03 phải xác minh venue của bài Pascanu. File không ghi, và bài này gần
  như chắc chắn có bản kỷ yếu với đánh số trang khác.
- Chương 05 phải xác minh venue của bài Sutskever, cùng lý do.
- Chưa đọc gì ngoài trang bìa của cả sáu file. Mọi thứ trong file này là những gì
  trang 1 nói. Phần nội dung là việc của bước research từng chương.
