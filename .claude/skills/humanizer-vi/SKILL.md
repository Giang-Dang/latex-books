---
name: humanizer-vi
description: >
  Xóa dấu vết văn AI khỏi văn bản tiếng Việt và viết lại theo tone người dùng chọn.
  Dùng khi cần viết lại, biên tập hoặc rà soát bất kỳ văn bản tiếng Việt nào cho tự nhiên
  hơn: luận văn, báo cáo seminar, README, mô tả PR, blog kỹ thuật, email gửi giáo sư,
  post mạng xã hội, script thuyết trình, và bản thảo sách: chương sách, lab cuối chương,
  phụ lục, lời nói đầu, lời giới thiệu bìa. Kích hoạt cả khi người dùng chỉ nói "viết lại cho
  tự nhiên", "bớt giọng AI", "nghe như người viết", "sửa văn phong", "humanize", "làm mượt
  đoạn này", hoặc dán một đoạn tiếng Việt kèm câu hỏi nghe có giống AI viết không.
  Văn bản tiếng Anh thì dùng skill humanizer thay cho skill này.
license: MIT
metadata:
  version: "1.1.0"
---

# Humanizer tiếng Việt

Biên tập văn bản tiếng Việt để nó đọc như người viết, theo đúng tone mà người dùng chọn.

## Bốn ràng buộc cứng

1. **Giữ trọn thông tin, được đổi hình dạng.** Mọi dữ kiện trong bản gốc phải còn trong bản viết
   lại, nhưng độ dài không cần đều tay: nén chỗ nhạt, dừng lâu chỗ đáng dừng, gộp hoặc tách đoạn
   thoải mái. Khi giữ thông tin và giữ bố cục cũ mâu thuẫn nhau, thông tin thắng.
2. **Không bịa dữ kiện.** Bản viết lại không được chứa dữ kiện, tên, con số, ngày tháng, trích dẫn
   hay nguồn nào không có trong bản gốc. Đổi một câu mơ hồ thành câu cụ thể chỉ được phép khi cái
   cụ thể đó lấy từ bản gốc hoặc từ người dùng. Câu không có căn cứ thì cắt, không tô vẽ.
3. **Một cặp xưng hô duy nhất.** File tone quy định cặp xưng hô. Chốt xong thì giữ nguyên từ đầu
   đến cuối bài.
4. **Giữ thuật ngữ tiếng Anh mà dân dev và AI Việt vẫn dùng tiếng Anh** (overfitting, pull request,
   embedding, deploy, baseline). Chỉ dịch khi bản dịch đã phổ biến hơn bản gốc trong cộng đồng.
   Dịch cưỡng ép là một dấu vết AI, không phải sự chỉn chu.

## Chọn tone trước khi viết

| Tone | File cần đọc | Dùng cho |
| --- | --- | --- |
| Nghiên cứu | `references/tone-nghien-cuu.md` | luận văn, báo cáo seminar, related work, tóm tắt paper |
| Kỹ thuật | `references/tone-ky-thuat.md` | README, ADR, tài liệu, mô tả PR, comment code |
| Blog | `references/tone-blog.md` | blog cá nhân, bài chia sẻ kỹ thuật |
| Công việc | `references/tone-cong-viec.md` | email, báo cáo tiến độ gửi giáo sư hoặc quản lý |
| Giảng dạy | `references/tone-giang-day.md` | tutorial, bài hướng dẫn cho người mới |
| Mạng xã hội | `references/tone-mang-xa-hoi.md` | post LinkedIn, Facebook, X |
| Thuyết trình | `references/tone-thuyet-trinh.md` | script nói cho seminar, bảo vệ, demo |

Bản thảo sách có bộ tone riêng, vì các phần của một cuốn sách cần các giọng khác nhau:

| Tone | File cần đọc | Dùng cho |
| --- | --- | --- |
| Chương sách | `references/tone-chuong-sach.md` | thân chương sách kỹ thuật viết theo giọng người làm nghề |
| Giáo trình | `references/tone-giao-trinh.md` | giáo trình, chuyên khảo học thuật |
| Kể chuyện | `references/tone-ke-chuyen.md` | phi hư cấu đại chúng, chương dẫn dắt bằng câu chuyện |
| Thực hành | `references/tone-thuc-hanh.md` | lab cuối chương, bài làm theo từng bước, cookbook |
| Phụ lục | `references/tone-phu-luc.md` | phụ lục, bảng thuật ngữ, bảng tra cứu, ma trận phiên bản |
| Lời nói đầu | `references/tone-loi-noi-dau.md` | lời nói đầu, lời tựa, lời cảm ơn, cách đọc sách |
| Bìa sách | `references/tone-bia-sach.md` | lời giới thiệu bìa sau, mô tả sách trên trang bán |

Cách chốt tone:

- Người dùng đã nêu rõ tone, hoặc đưa một mẫu văn phong của chính họ: dùng luôn, không hỏi.
- Chưa rõ: gọi `AskUserQuestion` đúng một lần. Công cụ này chỉ nhận tối đa 4 lựa chọn, nên hãy
  chọn 4 tone khả dĩ nhất theo loại văn bản đang xử lý (văn bản sách thì ưu tiên bảng tone sách),
  rồi liệt kê các tone khả dĩ còn lại trong phần mô tả của lựa chọn cuối kèm câu "chọn Other nếu
  muốn một trong các tone này". Một vòng hỏi, phủ đủ 14 tone.
- Có tone rồi thì đọc đúng một file tone tương ứng. Không đọc các file còn lại.
- Mẫu văn phong do người dùng đưa vào luôn thắng file tone khi hai bên xung đột. Bắt chước tác giả
  quan trọng hơn quét sạch dấu vết.

Ở chế độ nhúng (xem phần Chế độ gọi), không hỏi. Suy ra tone từ loại văn bản và chạy tiếp.

## Dấu vết văn AI trong tiếng Việt

### A. Nhồi ý nghĩa và tâng bốc

**Từ cần cảnh giác:** đóng vai trò then chốt, vô cùng quan trọng, đánh dấu bước ngoặt, mở ra chương
mới, khẳng định vị thế, nâng tầm, ghi dấu ấn, mang đậm bản sắc, hành trình, cột mốc, làn sóng,
trong bối cảnh hiện nay, trong kỷ nguyên số, bức tranh toàn cảnh.

Mô hình ngôn ngữ bơm tầm quan trọng cho một chi tiết bằng cách gắn nó vào một xu thế lớn hơn.

**Trước:** Việc ra mắt phiên bản 2.0 vào năm 2024 đã đánh dấu một bước ngoặt quan trọng trong hành
trình phát triển của sản phẩm, góp phần khẳng định vị thế của đội ngũ trong bối cảnh chuyển đổi số.

**Sau:** Nhóm phát hành phiên bản 2.0 năm 2024.

### B. Đuôi mệnh đề giả chiều sâu

**Từ cần cảnh giác:** ..., qua đó ...; ..., từ đó ...; ..., góp phần ...; ..., đồng thời khẳng
định ...; ..., thể hiện ...; ..., cho thấy ...

Đây là dạng tiếng Việt của lỗi dán đuôi `-ing` trong văn AI tiếng Anh: một mệnh đề gắn thêm vào
cuối câu để câu có vẻ sâu sắc, trong khi nó chỉ nói lại ý vừa nói.

**Trước:** Hệ thống dùng hàng đợi để tách khâu ghi log khỏi luồng chính, qua đó giúp giảm độ trễ,
đồng thời góp phần nâng cao trải nghiệm người dùng.

**Sau:** Hệ thống đẩy khâu ghi log sang hàng đợi, nhờ vậy luồng chính không phải chờ và độ trễ giảm.

### C. Né động từ "là" và "có"

**Từ cần cảnh giác:** đóng vai trò là, được xem như, được coi là, chính là, sở hữu, mang trong mình,
tồn tại, được biết đến như.

**Trước:** Redis đóng vai trò là lớp cache của hệ thống. Cụm máy chủ sở hữu 12 node và mang trong
mình khả năng tự phục hồi.

**Sau:** Redis là lớp cache của hệ thống. Cụm có 12 node và tự phục hồi được.

### D. Danh hóa và bị động thừa

**Từ cần cảnh giác:** việc + động từ, sự + động từ, được ... bởi, thông qua việc, nhằm mục đích.

Tiếng Việt mạnh ở câu chủ động có chủ ngữ rõ. Văn AI hay biến động từ thành danh từ rồi phải mượn
một động từ rỗng ("thực hiện", "tiến hành") để chống đỡ.

**Trước:** Việc đánh giá mô hình được thực hiện bởi nhóm nghiên cứu thông qua sự so sánh với ba
baseline.

**Sau:** Nhóm nghiên cứu đánh giá mô hình bằng cách so với ba baseline.

Chiều ngược lại cũng có thật: "Mẫu được thu thập trong sáu tháng" hoàn toàn tự nhiên khi ai thu
thập không quan trọng. Sửa khi câu chủ động rõ hơn, không quét sạch chữ "được" một cách máy móc.

### E. Dấu vết dịch máy từ tiếng Anh

**Từ cần cảnh giác:** Điều quan trọng cần lưu ý là, Trong thế giới ngày nay, Hãy cùng đi sâu vào,
yếu tố thay đổi cuộc chơi, Nói cách khác, Cuối cùng nhưng không kém phần quan trọng.

Ba lỗi cấu trúc đi kèm: chuỗi "của" chồng tầng, chữ "một" thừa do dịch mạo từ tiếng Anh, và đại từ
"nó" đặt ở chỗ mà tiếng Việt bỏ trống chủ ngữ thì tự nhiên hơn.

**Trước:** Điều quan trọng cần lưu ý là hiệu suất của mô hình của chúng tôi phụ thuộc vào chất
lượng của dữ liệu huấn luyện. Trong thế giới ngày nay, đây là một yếu tố thay đổi cuộc chơi.

**Sau:** Hiệu suất mô hình phụ thuộc vào chất lượng dữ liệu huấn luyện.

### F. Xưng hô trôi

Một bài trộn lẫn tôi, mình, chúng tôi, chúng ta; hoặc dùng "chúng ta" ở chỗ chỉ có một tác giả.

**Trước:** Trong bài này mình sẽ trình bày cách chúng tôi tối ưu pipeline. Chúng ta có thể thấy
rằng tôi đã giảm thời gian build xuống một nửa.

**Sau:** Bài này nói về cách mình tối ưu pipeline. Thời gian build giảm một nửa.

### G. Nhịp và cấu trúc

**Dấu hiệu:** bộ ba đối xứng ("nhanh chóng, chính xác và hiệu quả"), dải giả ("từ startup nhỏ đến
tập đoàn lớn" khi hai đầu không nằm trên cùng một thang đo), "không chỉ ... mà còn ...", xoay vòng
từ đồng nghĩa (mô hình, mạng nơ-ron, thuật toán, hệ thống cùng chỉ một thứ trong bốn câu liền), và
chuỗi câu cụt dồn dập để tạo kịch tính.

**Trước:** Công cụ này nhanh chóng, chính xác và hiệu quả. Từ các startup nhỏ đến những tập đoàn
lớn, ai cũng có thể dùng. Nó không chỉ tiết kiệm thời gian mà còn nâng cao chất lượng.

**Sau:** Công cụ chạy nhanh và cho kết quả chính xác, nên tiết kiệm được kha khá thời gian.
Startup nhỏ hay tập đoàn lớn đều dùng được.

### H. Dấu câu và trình bày

Tiếng Việt viết tay gần như không dùng gạch ngang dài `—` (U+2014) hay gạch ngang ngắn `–` (U+2013)
để chen mệnh đề, nên đây là dấu vết mạnh nhất trong nhóm này. Thay bằng dấu chấm, dấu phẩy, dấu hai
chấm hoặc ngoặc đơn. Gạch đầu dòng cho lời thoại và cho danh sách thì giữ nguyên, đó là quy ước
tiếng Việt thật.

```text
Trước: Cách này rẻ hơn — và nhanh hơn — so với việc tự dựng cụm máy chủ…
Sau:   Cách này rẻ hơn và nhanh hơn so với tự dựng cụm máy chủ...
```

Các dấu hiệu còn lại trong nhóm: dấu ba chấm `…` (U+2026) thay cho ba dấu chấm thường, nháy cong
thay nháy thẳng, in đậm rải khắp câu, bullet mở đầu bằng `**Tiêu đề:**` rồi lặp lại chính tiêu đề
đó, emoji trang trí đầu heading, và viết hoa đầu mọi từ trong tiêu đề (tiếng Việt chỉ viết hoa chữ
đầu và danh từ riêng).

### I. Mở bài, kết bài, giọng nịnh

**Từ cần cảnh giác:** Hãy cùng tìm hiểu, Trong bài viết này mình sẽ, Không để các bạn chờ lâu,
Câu hỏi rất hay, Bạn hoàn toàn đúng, Hy vọng bài viết hữu ích, Cảm ơn bạn đã đọc đến đây,
Tương lai đầy hứa hẹn, Đây chắc chắn là xu hướng tất yếu, Tùy thuộc vào từng trường hợp cụ thể.

**Trước:** Câu hỏi rất hay! Trong bài viết này, mình sẽ cùng bạn đi sâu vào Docker. Hy vọng bài
viết hữu ích với mọi người, tương lai của container chắc chắn còn rất hứa hẹn!

**Sau:** Cắt cả hai đoạn. Vào thẳng nội dung Docker, và dừng ở dữ kiện cuối cùng thay vì chào tạm biệt.

## Cái không phải dấu vết AI

Gọt nhầm văn người viết còn tệ hơn bỏ sót một dấu vết. Những thứ sau, đứng một mình, không kết luận
được gì:

- **Từ Hán-Việt trang trọng.** Văn viết tiếng Việt vốn trang trọng hơn văn nói rất nhiều.
- **Câu dài nhiều mệnh đề trong văn học thuật.** Đó là chuẩn của thể loại.
- **Giữ nguyên thuật ngữ tiếng Anh.** Đó là chuẩn của cộng đồng dev Việt, không phải lười dịch.
- **Nháy cong đơn lẻ.** Word, Google Docs và phần lớn CMS tự bo nháy.
- **Công thức hành chính** như "Kính gửi", "Căn cứ vào", "Trân trọng". Quy ước có sẵn, không phải máy viết.
- **Trích dẫn, tên riêng, tên tổ chức, tên sách** có chứa từ trong danh sách cảnh giác. Không sửa
  chữ nằm trong ngoặc kép hay trong tên gọi.
- **Một câu ngắn để nhấn ý.** Chỉ đánh dấu khi có cả một chuỗi câu cụt liên tiếp.

Chỉ khi các dấu hiệu chụm lại thành cụm thì mới là bằng chứng. Một chữ "góp phần" không nói lên
điều gì; "góp phần" cộng bộ ba đối xứng cộng "khẳng định vị thế" cộng một đoạn kết chúc mừng tương
lai thì đã là lời thú nhận.

### Dấu hiệu người viết thật, phải giữ lại

- Tiếng lóng dev Việt: "chạy ngon", "toang", "fix cứng", "deploy phát ăn ngay".
- Code-switching tự nhiên: "model này train xong bị overfit".
- Chi tiết cụ thể khó bịa: một con số lẻ, tên phiên bản, một câu người thật nói.
- Cảm xúc lẫn lộn chưa giải quyết: "mình thấy cách này ổn, mà vẫn gợn, chưa nói rõ được vì sao".
- Câu dài ngắn xen kẽ, và những chỗ tác giả tự ngắt lời mình giữa chừng.

## Chế độ gọi

- **Dán văn bản (mặc định).** Người dùng đưa đoạn văn thẳng vào hội thoại. Trả bản nháp, vài gạch
  đầu dòng nêu chỗ vẫn còn lộ giọng AI, rồi bản cuối.
- **File.** Người dùng chỉ vào một file. Đọc file, chạy vòng lặp trong đầu, ghi đè file bằng bản
  cuối, và chỉ báo tóm tắt ngắn ra hội thoại thay vì dán lại toàn bộ. Chỉ đụng vào văn xuôi: giữ
  nguyên code block, frontmatter, bảng số liệu, đích của link.
- **Nhúng.** Một tác vụ khác đang dùng skill này như một bước (viết mô tả PR, viết commit message,
  viết một đoạn tài liệu). Chỉ xuất văn bản cuối. Không nháp, không gạch đầu dòng, không tóm tắt.

## Quy trình

1. Chốt tone và đọc file tone tương ứng.
2. Đọc kỹ bản gốc, đánh dấu từng chỗ dính các nhóm A đến I.
3. Viết **bản nháp**. Đọc thầm thành tiếng: câu có trôi không, độ dài câu có thay đổi không, xưng
   hô có nhất quán không.
4. Tự hỏi hai câu và trả lời ngắn gọn: **"Đoạn này còn lộ giọng AI ở chỗ nào?"** và **"Bản viết
   lại có dữ kiện, tên, con số hay nguồn nào không có trong bản gốc không?"** Bịa dữ kiện là lỗi
   nặng, kể cả khi câu bịa nghe tự nhiên hơn câu gốc.
5. Viết **bản cuối** xử lý hết hai câu trên.

Quét lần cuối trước khi trả lời:

- Không còn ký tự `—` (U+2014), `–` (U+2013), `…` (U+2026) trong bản cuối, trừ khi mẫu văn phong
  của người dùng có dùng chúng.
- Nháy thẳng, không nháy cong.
- Đúng một cặp xưng hô từ đầu đến cuối.
- Không emoji trang trí, không heading viết hoa từng từ.
- Không đoạn kết chúc mừng tương lai, không lời chào tạm biệt.
