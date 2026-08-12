# Chương 10: Bias quy nạp của CNN

Ghi ngày 2026-08-12.

Ghi chú nguồn và số đo cho chương 10. Mọi số thập phân chương 10 in ra đều phải
có mặt ở đây (quyết định 20 trong SPEC).

Chương 10 là chương đầu tiên của sách chạy trên dữ liệu **không** sinh từ văn
phạm của quyết định 35. Tác giả đã chốt trong phiên này: dùng CIFAR-10, chấp
nhận việc tải về, và `verify.py` được phép tải một lần rồi cache. Xem quyết định
69. Chương 11 dùng lại đúng bộ dữ liệu ấy, vì kết quả trung tâm của ViT là một
phép so với CNN trên cùng ảnh.

**Về quyết định 60.** Hai trong ba script của chương này không huấn luyện và
không bấm giờ, nên chạy lại trên máy nào cũng cho đúng từng chữ số; bản thân
script là bản sao chính tắc. Script thứ ba huấn luyện, và bảng của nó phụ thuộc
máy, nên nó ghi bản chạy gốc ra file trong companion repo theo đúng quyết định
60. Xem mục 6.

## 0. Danh sách nguồn và bản đã đọc

Không bài nào trong số này nằm trong manifest sáu bài báo gốc
(`2026-08-nguon-sau-bai-bao.md`). Chỉ ViT có bản cứng trong thư mục Papers; còn
lại tải trong phiên này.

| Bài | Bản đã đọc | Venue trên trang bìa |
|---|---|---|
| LeCun và cộng sự 1989, zip code | PDF bản tạp chí trên site tác giả, `lecun-89e.pdf`, sha256 `378c00b2...c91fff1` | Neural Computation 1(4):541-551 |
| LeCun và cộng sự 1998, LeNet-5 | PDF trên site tác giả, `lecun-01a.pdf` | Proc. IEEE 86(11):2278-2324 |
| Fukushima 1980, Neocognitron | Bản mirror rctn.org; **chỉ đọc abstract** | Biological Cybernetics 36:193-202 |
| Zhang 2019, shift-invariant | arXiv 1904.11486v2, tự ghi "Accepted to ICML 2019" | ICML 2019, PMLR 97 |
| Cordonnier và cộng sự 2020 | arXiv 1911.03584v2, tự ghi "Published as a conference paper at ICLR 2020" | ICLR 2020 |
| Parmar và cộng sự 2018, Image Transformer | arXiv 1802.05751v3 | ICML 2018, PMLR 80 |
| Chen và cộng sự 2020, iGPT | PDF trên cdn.openai.com; **không có bản arXiv** | ICML 2020, PMLR 119:1691-1703 |
| Ramachandran và cộng sự 2019 | arXiv 1906.05909v1, tự ghi "Preprint. Under review" | NeurIPS 2019 |
| Bello và cộng sự 2019 | arXiv 1904.09925v5 | ICCV 2019 |
| Dosovitskiy và cộng sự 2021, ViT | Bản ICLR 2021 trong thư mục Papers, đọc trực tiếp; đối chiếu arXiv 2010.11929 v1 và v2 | ICLR 2021 |
| Krizhevsky 2009, CIFAR | Tech report Univ. of Toronto, PDF đầy đủ | Không hội nghị; tech report |

**Quyết định 47 (một bài có nhiều bản thì trích theo bản).** Đã đối chiếu v1 và
v2 của ViT ở đoạn chương này dựa vào: **không khác nhau**, cả câu văn lẫn bốn
con số headline. Các bài còn lại chỉ đọc một bản, và bản ấy tự nhận là
camera-ready; ghi rõ ở bảng trên bản nào.

**Chỗ chưa kiểm được, ghi ra chứ không lấp:**

- Azulay & Weiss 2019 (JMLR): **không tải được, không đọc.** Chương không trích
  bài này. Nếu sau muốn trích thì phải đọc trước.
- iGPT "2500 V100-days": con số này lan truyền rộng và được gán cho blog post
  của OpenAI. Trang ấy trả về HTTP 403 ở mọi lần thử. **Không xác nhận được câu
  chữ, và quan trọng hơn là không xác nhận được byline có tên kỹ sư cụ thể hay
  không** - mà house style chỉ cho dùng nguồn vendor khi prose nêu tên người.
  Nên chương **không** dùng con số ấy. Nó dùng câu định tính của chính bài, mục
  Discussion, và câu ấy đã đủ.
- Zhang 2019 bảng 6: chỉ thấy qua bản render HTML ar5iv chứ không phải ảnh
  trang PDF. Chương không in số nào từ bảng 6.
- Fukushima 1980: chỉ đọc abstract. Chương chỉ nói đúng hai điều abstract nói -
  có phân cấp cục bộ, và học không có thầy chứ không phải backprop.

## 1. Hai ràng buộc trên một ma trận trọng số

Nguồn: LeCun và cộng sự 1989, mục 3.2, nguyên văn:

> The detection of a particular feature at any location on the input can be
> easily done using the "weight sharing" technique. Weight sharing was
> described in Rumelhart et al. (1986) for the so-called T-C problem and
> consists in having several connections (links) controlled by a single
> parameter (weight). It can be interpreted as imposing equality constraints
> among the connection strengths.

Và LeCun và cộng sự 1998, mục II.A, nguyên văn:

> Convolutional Networks combine three architectural ideas to ensure some
> degree of shift, scale, and distortion invariance: local receptive fields,
> shared weights (or weight replication), and spatial or temporal
> sub-sampling.

Bello và cộng sự 2019, mục 1, nói gọn nhất và chương dùng câu này:

> The design of the convolutional layer imposes 1) locality via a limited
> receptive field and 2) translation equivariance via weight sharing.

### 1.1 Cùng một tầng dưới ba chế độ

Đo bằng `experiments/ch10_counts.py` tại tag `ch10`. Tầng 32x32x3 vào,
32x32x32 ra, kernel 3x3 - đúng tầng đầu của mạng chương này huấn luyện.

```
regime  connections  weights      biases  parameters   conn/param
dense   100,696,064  100,663,296  32,768  100,696,064        1.00
local   917,504      884,736      32,768  917,504            1.00
conv    917,504      864          32      896             1024.00
```

```
each constraint as a divisor on the parameter count
  locality alone           109.75
  sharing, on top         1024.00
  both together         112384.00
```

Chỗ đáng đọc: **hệ số của phép chia do chia sẻ trọng số đúng bằng số vị trí
không gian, 32 x 32 = 1024.** Locality chia theo tỷ số hai trường tiếp nhận,
còn sharing chia theo số chỗ tầng ấy nhìn. Hai ràng buộc không ngang nhau: cái
thứ hai lớn hơn cái thứ nhất gần mười lần.

Số kết nối của `local` và `conv` bằng nhau, đúng như định nghĩa: chia sẻ bỏ đi
tham số tự do chứ không bỏ đi cạnh nào.

### 1.2 Dựng lại LeCun 1989

Quyết định 65 nói một con số sách này in ra từ bảng của bài phải được dựng lại
từ các bảng khác của chính bài trước. Chương 9 chạy phép ấy và ba trong bốn
không quay về. Ở đây cả hai đều quay về, và đó là lý do vẫn phải chạy: một quy
tắc chỉ chạy khi đoán trước là sẽ hỏng thì không phải quy tắc.

Bài in ở mục 3.3: "the network has 1256 units, 64,660 connections, and 9760
independent parameters."

```
layer   connections  weights  biases  parameters  conn/param
H1      19,968       300      768     1,068          18.697
H2      38,592       2,400    192     2,592          14.889
H3      5,790        5,760    30      5,790           1.000
output  310          300      10      310             1.000
TOTAL   64,660       8,760    1,000   9,760           6.625
```

Khớp chính xác cả hai tổng. Tỷ số 64,660 / 9,760 = 6.625 chẵn.

**Hai chỗ đọc ra mà bài không nhấn.**

Thứ nhất, mục 3.3 viết thẳng: "Units do not share their biases (thresholds).
Each unit thus has 25 input lines plus a bias." Nên trong 1,068 tham số tự do
của H1 thì 768 là bias và chỉ 300 là trọng số kernel:

```
  H1 shared weights                300
  H1 unshared biases               768
  biases as a share of H1       0.7191
```

71.91% tham số của tầng tích chập đầu tiên trong lịch sử là bias. Chia sẻ trọng
số bỏ đi trọng số và không đụng tới bias.

Thứ hai, chỗ tham số thật sự nằm:

```
  H1 + H2, the shared layers     3,660
  H3 + output, fully connected   6,100
  fully connected share         0.6250
```

62.50% tham số tự do nằm ở hai tầng kết nối đầy đủ.

### 1.3 Dựng lại LeNet-5

Bài in ở mục II.B: "The network in figure 2 contains 340,908 connections, but
only 60,000 trainable free parameters because of the weight sharing."

```
layer   connections  parameters
C1      122,304      156
S2      5,880        12
C3      151,600      1,516
S4      2,000        32
C5      48,120       48,120
F6      10,164       10,164
output  840          0
TOTAL   340,908      60,000
```

**60,000 là con số chẵn nhưng chính xác chứ không phải làm tròn.** Tổng đúng
bằng 60,000.

Và tổng số kết nối chỉ khớp khi đếm cả tầng ra. LeNet-5 kết thúc bằng 10 unit
RBF, mỗi unit 84 đầu vào, tức 840 kết nối, mà trọng số của chúng bài đặt bằng
tay và không huấn luyện. Nên tầng ấy vào một tổng và không vào tổng kia. Bỏ nó
đi thì tham số vẫn là 60,000 còn kết nối là 340,068, thiếu đúng 840. Đó là cách
hàng ấy được tìm ra.

```
  C1..S4, the shared layers      1,716
  C5 + F6, fully connected      58,284
  fully connected share         0.9714
```

**97.14%.** Kiến trúc giới thiệu chia sẻ trọng số tiêu 97% tham số của nó ở
những tầng không chia sẻ gì. Chia sẻ trọng số không làm mạng nhỏ đi; nó làm bộ
trích đặc trưng nhỏ đi.

## 2. Equivariance chứ không phải invariance

Zhang 2019 mục 3.1 định nghĩa tách bạch hai thứ, nguyên văn:

> A function F~ is shift-equivariant if shifting the input equally shifts the
> output [...] A representation is shift-invariant if shifting the input
> results in an identical representation.

Đo bằng `experiments/ch10_equivariance.py` tại tag `ch10`. Mọi số ở đây đo tại
initialization, seed 0, không huấn luyện gì - vì equivariance là tính chất của
phép tính chứ không phải của trọng số. Đó cũng là lý do các số dưới đây là số
không chính xác chứ không phải số nhỏ.

### 2.1 Một tầng tích chập

```
padding     max |f(shift x) - shift f(x)|
circular    0.000e+00
zeros       1.772e+00
```

```
  whole feature map          1.772e+00
  interior, borders dropped  0.000e+00
```

Circular padding cho **đúng số không**, không phải xấp xỉ không. Zero padding
hỏng, và chỗ hỏng nằm trọn ở viền: bỏ hai pixel viền ra thì phần trong cũng
đúng số không. Nên zero padding không làm yếu equivariance, nó phá equivariance
trên một khung hai pixel và không phá chỗ nào khác.

### 2.2 Subsampling: chỗ tính chất ấy mất

Tầng giảm mẫu hai lần thì shift đầu vào 2 phải cho shift đầu ra 1. So sai chỗ
này là so sai hẳn kết luận - xem mục 7.

```
input shift  output shift  error
0            0             0.000e+00
2            1             0.000e+00
4            2             0.000e+00
6            3             0.000e+00
8            4             0.000e+00
```

Đúng số không ở mọi shift chẵn. Còn shift lẻ thì **không có** shift đầu ra nào
để đem so, nên bảng dưới lấy giá trị tốt nhất trên mọi shift đầu ra:

```
input shift  best output shift  residual  residual/scale
1            -2                 2.327e+00 0.9439
3            -3                 2.258e+00 0.9159
5            -2                 2.258e+00 0.9159
```

Biên độ đầu ra là 2.4651. Nên chỗ tốt nhất mà một shift lẻ đạt được vẫn lệch
hơn chín phần mười biên độ của chính đầu ra. Đây không phải một sự suy giảm tăng
dần theo khoảng cách; tầng ấy không nói được gì về một nửa số shift.

### 2.3 Không phải do max, mà do bỏ mẫu

Zhang 2019 thường được đọc thành "max pooling gây aliasing". Đem đúng phép đo
trên cho ba cách giảm một nửa lưới:

```
layer           even shift  odd shift  scale   odd/scale
MaxPool2d(2)    0.000e+00   2.215e+00  2.429   0.912
AvgPool2d(2)    0.000e+00   1.101e+00  1.343   0.820
Conv stride 2   0.000e+00   2.968e+00  2.427   1.223
```

Cả ba đúng tuyệt đối ở shift chẵn và cả ba sai cỡ biên độ tín hiệu ở shift lẻ.
Hàng thứ ba không có phép max nào. Nên phân đôi chẵn/lẻ là tính chất của việc
vứt đi một mẫu trên hai, không phải của phi tuyến đứng cạnh nó. Chương phải nói
đúng chỗ này chứ không quy cho max pooling.

### 2.4 Chồng lên thì chu kỳ nhân lên

```
pool layers  total stride  exact at shifts of
1            2             2
2            4             4
3            8             8
```

Mạng ba tầng pooling trên ảnh 32 pixel chỉ đúng ở bội của 8, tức 4 trong 32
shift ngang, một phần tám.

Và chuyện này bài 1989 đã nói ra bằng lời, về chính phép giảm mẫu hai pixel của
nó, mục 3.3 nguyên văn:

> For units in layer H1 that are one unit apart, their receptive fields (in the
> input layer) are two pixels apart. Thus the input image is undersampled and
> some position information is eliminated.

Ba mươi năm sau Zhang mới đo cái giá của câu ấy.

## 3. Self-attention biểu diễn được convolution

Cordonnier và cộng sự 2020, định lý 1, nguyên văn từ ảnh trang PDF (arXiv v2,
bản ICLR 2020):

> A multi-head self-attention layer with N_h heads of dimension D_h, output
> dimension D_out and a relative positional encoding of dimension D_p >= 3 can
> express any convolutional layer of kernel size sqrt(N_h) x sqrt(N_h) and
> min(D_h, D_out) output channels.

Tức **N_h = K^2 head cho kernel K x K**, và positional encoding phải là loại
tương đối, số chiều ít nhất 3.

Chú ý một cái bẫy đọc: bản render HTML ar5iv của chính bài này mất ký hiệu căn
và in thành "kernel size N_h x N_h". Ảnh trang PDF rõ ràng có dấu căn. Đây là
lỗi render chứ không phải hai bản bất đồng, nhưng nó đúng loại lỗi mà quyết định
47 dựng ra để chặn.

Kiểm bằng dựng hình, `experiments/ch10_equivariance.py`:

```
kernel  heads  max |heads - conv2d|  output scale  relative
3x3     9      7.629e-06             26.823        2.84e-07
5x5     25     1.717e-05             40.610        4.23e-07
7x7     49     2.670e-05             52.470        5.09e-07
```

Sai lệch tương đối lớn lên chậm theo số head, 2.84 lên 5.09 phần mười triệu khi
số head đi từ 9 lên 49, đúng dáng của sai số cộng dồn float32 khi phép dựng
cộng `K^2` số hạng. Không phải khoảng cách cấu trúc.

**Bảng này từng bị in sai trong phiên.** Bản đầu của chương chép bảng từ một
lần chạy trước khi mục 2b được thêm vào `ch10_equivariance.py`; mục 2b tạo thêm
các tầng ngẫu nhiên nên nó đẩy dòng RNG, và mục 4 chạy sau đó cho số khác. Sáu
trong chín ô lệch. Cả build lẫn gate đều xanh, vì `number` chỉ hỏi con số có
mặt trong một note nào đó hay không, và note lúc ấy mang đúng những con số cũ
ấy - hai chỗ sai cùng một nguồn thì kiểm chéo nhau không phát hiện được gì. Chỉ
đọc lại file canonical đã commit mới thấy. Đây là quyết định 60 ở dạng khác:
không phải file mất, mà file đúng nằm đó và bản in không được đối chiếu lại
sau khi script đổi.

**Cái phép dựng này cho thấy là capacity, không phải learning.** Head ở đây đặt
bằng tay ở giới hạn softmax đã bão hòa. Dựng một tầng self-attention thật mà
softmax bão hòa được thì phải đẩy hệ số của quadratic encoding lên đủ lớn, và
lúc ấy sai lệch báo cáo việc softmax bão hòa tới đâu chứ không báo cáo định lý
đúng hay sai. Chương nói chỗ này ra trên trang.

Bài cũng tự nói phần 1D chưa kiểm thực nghiệm, nguyên văn:

> Since we have not tested empirically if the preceding construction matches
> the behavior of 1D self-attention in practice, we cannot claim that it
> actually learns to convolve an input sequence - only that it has the
> capacity to do so.

Và câu kết luận thực nghiệm của bài, chương dùng làm bản lề sang mục 4:

> Our results seem to suggest that localized convolution is the right inductive
> bias for the first few layers of an image classifying network.

## 4. Các nỗ lực trước ViT

### 4.1 Image Transformer (Parmar và cộng sự 2018)

Lý do phải cục bộ hóa, mục 3.3 nguyên văn:

> The number of positions included in the memory l_m [...] has a tremendous
> impact on the scalability of the self-attention mechanism, which has a time
> complexity in O(h . w . l_m . d) [...] The decoders in our experiments,
> however, produce 32x32 pixel images with 3072 positions, rendering attending
> to all positions impractical.

3072 = 32 x 32 x 3. Đây đúng là chi phí bậc hai của chương 8, gặp lại ở ảnh.

Bảng 4, bits/dim: Image Transformer 1D local đạt CIFAR-10 2.90 và ImageNet
3.77, so với Gated PixelCNN 3.83 trên ImageNet và PixelSNAIL 2.85 trên
CIFAR-10. Abstract: "improving the best published negative log-likelihood on
ImageNet from 3.83 to 3.77."

Bảng 5, CelebA super-resolution, tỷ lệ người đánh giá bị đánh lừa: 2D local
36.11% ± 2.5, 1D local 35.94% ± 3.0, PixelRecursive 11.0%, srez GAN 8.5%,
ResNet 4.0%.

### 4.2 Stand-Alone Self-Attention (Ramachandran và cộng sự 2019)

Abstract nguyên văn:

> A simple procedure of replacing all instances of spatial convolutions with a
> form of self-attention applied to ResNet model produces a fully
> self-attentional model that outperforms the baseline on ImageNet
> classification with 12% fewer FLOPS and 29% fewer parameters.

Bảng 1, ImageNet, ResNet-50: baseline 8.2B FLOPS / 25.6M tham số / 76.9%; full
attention 7.2B / 18.0M / 77.6%; conv-stem + attention 7.0B / 18.0M / 77.4%.

### 4.3 Attention Augmented Convolutions (Bello và cộng sự 2019)

Abstract: cải thiện 1.3% top-1 trên ImageNet so với ResNet50 baseline, và 1.4
mAP trên COCO so với RetinaNet baseline.

### 4.4 iGPT (Chen và cộng sự 2020)

Abstract nguyên văn:

> On CIFAR-10, we achieve 96.3% accuracy with a linear probe, outperforming a
> supervised Wide ResNet, and 99.0% accuracy with full fine-tuning, matching
> the top supervised pre-trained models. An even larger model trained on a
> mixture of ImageNet and web images is competitive with self-supervised
> benchmarks on ImageNet, achieving 72.0% top-1 accuracy on a linear probe of
> our features.

Câu định lượng duy nhất về compute trong chính bài, mục Introduction:

> with significant compute resources (2048 TPU cores)

Và câu tự đánh giá ở mục Discussion, đây là câu chương dùng:

> we observed that our approach requires large models in order to learn high
> quality representations. iGPT-L has 2 to 3 times as many parameters as
> similarly performing models on ImageNet and uses more compute.

Kích thước: iGPT-S L=24 d=512 76M; iGPT-M L=36 d=1024 455M; iGPT-L L=48 d=1536,
bảng 2 ghi 1362M; iGPT-XL L=60 d=3072, bảng 2 ghi 6801M.

**Không dùng con số "2500 V100-days"** - xem mục 0.

## 5. Câu của chính bài ViT

Đọc trực tiếp bản ICLR 2021 trong thư mục Papers. Hai chỗ, và chương dùng cả
hai.

Mục 1, Introduction, trang 2:

> This seemingly discouraging outcome may be expected: Transformers lack some
> of the inductive biases inherent to CNNs, such as translation equivariance
> and locality, and therefore do not generalize well when trained on
> insufficient amounts of data.

Cùng đoạn:

> However, the picture changes if the models are trained on larger datasets
> (14M-300M images). We find that large scale training trumps inductive bias.

Mục 3.1, trang 4, đoạn có tiêu đề in đậm "Inductive bias":

> We note that Vision Transformer has much less image-specific inductive bias
> than CNNs. In CNNs, locality, two-dimensional neighborhood structure, and
> translation equivariance are baked into each layer throughout the whole
> model. In ViT, only MLP layers are local and translationally equivariant,
> while the self-attention layers are global.

Chú ý bài viết **equivariance**, không viết invariance. Bài đúng ở chỗ mục 2
của chương này đo. Và ba thứ bài liệt kê - locality, cấu trúc lân cận hai
chiều, translation equivariance - đúng là ba mục đầu của chương này.

Mục 3.2, câu cuối:

> Note that this resolution adjustment and patch extraction are the only points
> at which an inductive bias about the 2D structure of the images is manually
> injected into the Vision Transformer.

## 6. CIFAR-10 và phép đo của chương

### 6.1 Nguồn dữ liệu

Krizhevsky 2009, mục 3.1, nguyên văn:

> We paid students to label a subset of the tiny images dataset. The labeled
> subset we collected consists of ten classes of objects with 6000 images in
> each class. [...] We call this the CIFAR-10 dataset, after the Canadian
> Institute for Advanced Research, which funded the project.

Chia tập: "the training set receiving a randomly-selected 5000 images from each
class", tức 50,000 train / 10,000 test, ảnh màu 32x32, 10 lớp.

Trang tải: `https://www.cs.toronto.edu/~kriz/cifar.html`, chuyển hướng 301 sang
`https://cave.cs.toronto.edu/kriz/cifar.html`. File `cifar-10-python.tar.gz`,
md5 `c58f30108f718f92721af3b95e74349a`, `Content-Length` đo bằng HTTP HEAD là
170,498,071 byte. Trang ghi "163 MB", tức trang đang dùng MiB gọi là MB;
170,498,071 / 2^20 = 162.6. Không phải hai nguồn bất đồng, chỉ là đơn vị.

Tự kiểm trong phiên này, không chép lại:

```
md5     c58f30108f718f92721af3b95e74349a
sha256  6d958be074577803d12ecdefd02955f39262c83c16fe9348329d7fe0b5c001ce
bytes   170,498,071
```

Loader tự viết, không dùng torchvision. Lý do đo được chứ không phải khẩu vị:
torchvision bản duy nhất còn ăn khớp với `torch==2.11.0` đã ghim là 0.26.0, và
nó kéo thêm pillow; `CIFAR10.__getitem__` của nó trả về `PIL.Image` nên vòng
huấn luyện phải decode lại từng mẫu. Archive là một tarball chứa sáu pickle,
đọc bằng stdlib hết bốn mươi dòng. `environment.yml` giữ nguyên, không thêm phụ
thuộc nào.

**Tải mất 32 phút.** Đo bằng curl với range request:
throughput quanh 90 KB/s tới `cave.cs.toronto.edu`, và lần tải đầy đủ mất
1916.0 giây. Con số này là của mạng máy này chứ không phải của dataset, nhưng
nó lớn tới mức không nhét vào ngân sách nào được, nên `verify.py` không tính
việc tải vào phần bấm giờ: tải một lần bằng
`python -c "from rnn_to_transformer_lab.cifar import fetch; fetch()"` rồi mọi
lần sau đọc cache.

### 6.2 Ba mô hình

Đo bằng `experiments/ch10_cifar.py` tại tag `ch10`. Bản chạy gốc nằm ở
`experiments/ch10_cifar_canonical.txt` trong companion repo, theo quyết định
60, vì bảng của mục này là số huấn luyện và phụ thuộc máy.

```
model         parameters  vs CNN  locality  sharing
CNN           66,570      1.0000  yes       yes
MLP matched   64,753      0.9727  no        no
MLP wide      1,578,506   23.7120 no        no
```

MLP khớp tham số có **21 unit ẩn**. Đó là thứ 66,570 tham số mua được khi không
tham số nào được chia sẻ, và nó là hệ quả trực tiếp của con số 1024 ở mục 1.1.

Quyết định 44 đòi một đối chứng khớp kích thước. Ở đây có hai, và cái thứ hai
mới là cái đóng lập luận: chỉ so với MLP khớp tham số thì phản bác hiển nhiên
là "21 unit thì làm được gì", nên bảng có thêm một MLP 23.71 lần tham số.

### 6.3 Sample efficiency

```
n_train  epochs  model         test acc     spread   train acc
1000     25      CNN           0.4365       0.0326   0.8893
1000     25      MLP matched   0.3163       0.0176   0.9190
1000     25      MLP wide      0.3469       0.0236   1.0000

4000     14      CNN           0.5499       0.0102   0.7637
4000     14      MLP matched   0.3733       0.0042   0.6432
4000     14      MLP wide      0.3915       0.0133   0.9453

16000    7       CNN           0.6399       0.0197   0.7202
16000    7       MLP matched   0.4251       0.0152   0.5100
16000    7       MLP wide      0.4534       0.0120   0.6835

50000    4       CNN           0.7036       0.0019   0.7361
50000    4       MLP matched   0.4478       0.0015   0.4797
50000    4       MLP wide      0.5025       0.0057   0.5743
```

3 seed (0, 1, 2), chấm trên toàn bộ 10,000 ảnh test, cùng một recipe.

**Hàng 50000 từng bị cắt rồi được trả lại.** Nó bị cắt vì với nó phép quét mất
232.25s và cả repo lên 1332.17s so với `BUDGET_TOTAL` 1300, tức `verify.py`
trả về 1; xem quyết định 74. Nó được trả lại khi câu hỏi ngân sách được giải
quyết thay vì trả tiếp: `BUDGET_TOTAL` thành `TOTAL_TARGET` và `TOTAL_CEILING`.
Xem quyết định 75.

Chú ý một tính chất tiện: **ba hàng nhỏ giữ nguyên từng chữ số** giữa bản chạy
ba kích thước và bản bốn kích thước. Vì mỗi hàng chuẩn hóa theo tập con của
chính nó và seed riêng, các hàng độc lập với nhau, nên thêm một hàng không đụng
tới hàng nào khác. Đó cũng là phép kiểm rẻ rằng phép sửa rò rỉ ở mục 6.6 làm
đúng việc nó nói.

```
n_train  CNN-matched  CNN-wide  CNN spread  widest MLP spread
1000     0.1202       0.0897    0.0326      0.0236
4000     0.1767       0.1584    0.0102      0.0133
16000    0.2148       0.1865    0.0197      0.0152
50000    0.2558       0.2011    0.0019      0.0057
```

Ô hẹp nhất của cả hai cột khoảng cách là 0.0897, ở hàng 1000, so với spread lớn
nhất của chính hàng ấy là 0.0326: gấp 2.75 lần. Đó là tỷ lệ chặt nhất trong
bảng và nó vẫn không phải trường hợp bảng layer norm chương 8, nhưng nó cũng
không rộng rãi, nên hàng 1000 là hàng không nên xây lập luận mảnh lên trên.

```
CNN trained on  reaches  MLP matched needs  MLP wide needs
1000            0.4365       28,403 (28.4x)     10,958 (11.0x)
4000            0.5499          over 50,000        over 50,000
16000           0.6399          over 50,000        over 50,000
50000           0.7036          over 50,000        over 50,000
```

Số ảnh cần là nội suy log-tuyến tính giữa hai hàng kề nhau của đường cong MLP.

### 6.4 Độ ổn định dưới phép dịch, trên mô hình đã huấn luyện

```
shift  CNN     MLP matched  MLP wide
1      0.1145  0.2409       0.2158
2      0.1817  0.3790       0.3478
4      0.3078  0.5446       0.5106
8      0.5981  0.7343       0.7013
```

Cùng bốn hàng ấy viết theo phần trăm, vì chương in cả hai dạng: ở shift 1, CNN
đổi trên 11.45% số ảnh và MLP khớp tham số đổi trên 24.09%. Ở shift 8, CNN đổi
trên 59.81%.

Tỷ lệ ảnh test đổi nhãn dự đoán, trên các mô hình seed 0 của hàng 50000.

**Ba nguyên nhân rời nhau, và chương phải tách chúng ra.** Bản đầu của chương
viết rằng ở shift 8 đặc trưng của CNN đẳng biến tuyệt đối, và câu ấy sai:
`SmallCNN` dùng `padding=1` tức pad bằng không, còn con số không tuyệt đối ở
mục 2 đo với `padding_mode="circular"`. Mục 2.1 của chính note này đã đo rằng
pad bằng không phá đẳng biến trên khung viền, và `shift` ở đây là `torch.roll`,
tức nó chuyển nội dung qua đúng cái viền ấy. Nên ba nguyên nhân là: pad bằng
không, head đọc vị trí, và dịch vòng 8 pixel thật sự đổi ảnh. Bảng này không
tách được chúng và chương nói vậy.

### 6.5 Hai lần cắt, và mỗi lần tốn gì

**Lần một, cắt epoch.** Bản chạy đầu dùng epoch (30, 16, 8, 5) và mất 302.24s.
Cắt xuống (25, 14, 7, 4) cho 234.78s. Đo xem cắt tốn gì: ba trong bốn hàng CNN
dịch chuyển ít hơn spread của chính hàng ấy, còn hàng 50000 tụt 0.0185 so với
spread 0.0077, vì 4 epoch trên 50000 ảnh chưa hội tụ bằng 5. Mọi thứ tự và mọi
chiều giữ nguyên.

**Lần hai, bỏ hẳn hàng 50000.** Vẫn không lọt: 232.25s cho phép quét, 1332.17s
cho cả repo so với 1300. Quyết định 62 cấm nâng ngân sách và quyết định 71 cấm
mua ngân sách bằng cách cắt tiếp epoch - cắt epoch làm đói chính các hàng ít dữ
liệu và tự chế ra hiệu ứng mà bảng đang đo. Bỏ hàng dữ liệu lớn nhất là phép
cắt duy nhất không làm đói hàng nào: mọi hàng còn lại giữ nguyên số epoch nó đã
được đo. Còn 131.51s. Xem quyết định 74.

Cái nó lấy đi: bảng sample efficiency mất điểm cắt thật cho MLP khớp tham số và
chỉ còn một chặn dưới, \"over 16,000\". Đó là chỗ duy nhất trong chương mà việc
cắt lấy đi một kết quả chứ không chỉ lấy đi độ chính xác.

Ba seed thì **không** cắt, và không đổi được lấy ngân sách: cột khoảng cách ở
mục 6.3 chỉ đọc được khi đặt cạnh spread, và một bảng một seed không đỡ được
cách đọc ấy. Đây đúng là lập luận quyết định 62 đã ghi.

**Lần ba: trả lại hàng 50000.** Không phải bằng cách tìm thêm giây, mà bằng
cách sửa cái gate. `BUDGET_TOTAL` là một ngưỡng cứng duy nhất làm hai việc
không tương thích, và biên của nó đã hẹp hơn nhiễu của chính nó; nó thành
`TOTAL_TARGET` 1700s và `TOTAL_CEILING` 1850s, xem quyết định 75. Phép quét trở
lại bốn kích thước và mất 292.54s.

Cả repo chạy hai lần trên máy rảnh sau khi trả hàng ấy về: 1305.35s và 1358.24s,
cả hai `verify: ok`. Ngưỡng lấy từ số lớn hơn, vì một lần chạy thì ước lượng
thấp.

292.54s cao hơn 232.25s của bản bốn kích thước cũ, và chênh lệch không phải do
hàng 50000. Phép sửa rò rỉ ở mục 6.6 làm `standardize` chạy theo từng tập con
thay vì một lần cho cả tập, nên ở hàng 50000 nó tính lại thống kê cho mỗi seed
và mỗi kiến trúc. Đắt hơn, và đúng hơn.

Hệ quả cho ngân sách từng mục: 292.54s so với hạn mức 360s của mục ấy chỉ là
1.23 lần, trong khi mọi mục khác trong repo mang 1.5 lần trở lên. Nâng hạn mức
mục ấy lên 450, đúng bằng 1.5 lần mà con số 360 vốn được dựng từ đó. Đây là
thay đổi ngân sách **từng mục** duy nhất trong phiên; nó không liên quan tới
tổng.

Và chính mục ấy cho thêm một số đo về nhiễu, trên đúng cùng một đoạn mã: chạy
riêng thì 292.54s, chạy trong `verify.py` thì 251.10s. Chênh 41.44s, tức 14.2%,
nằm đúng trong dải 9.4-15.5% mà mục 6.5 này lấy làm hằng số `R` của phép dựng
ngưỡng. Nói cách khác, nhiễu của repo này không phải chuyện của riêng cái tổng;
nó có mặt ở từng mục, và đó là lý do ngân sách từng mục mang 1.5 lần chứ không
mang 1.1 lần.

Và điểm cắt thật quay lại: 28,403 ảnh, tức 28.4 lần.

### 6.6 Một chỗ rò rỉ phải sửa trước khi bảng có nghĩa

Bản đầu của `ch10_cifar.py` gọi `standardize` một lần trên toàn bộ 50000 ảnh
huấn luyện, rồi mới cắt lấy tập con. Nghĩa là hàng 1000 ảnh được chuẩn hóa bằng
thống kê rút từ 49000 ảnh nó không bao giờ thấy - đúng cái đầu bảng mà chương
đọc kỹ nhất.

Tệ hơn: docstring của `standardize` viết rằng nó chuẩn hóa theo thống kê của
chính tập huấn luyện và giải thích vì sao rò rỉ ấy quan trọng, trong khi chỗ
gọi nó làm ngược lại. Và bài tập tier hai số 4 bảo người đọc \"đổi sang dùng
thống kê toàn bộ\" để xem hỏng thế nào, tức bảo họ tạo ra một chỗ rò rỉ đã có
sẵn.

Sửa bằng cách chuyển `standardize` vào trong vòng lặp, tính từ chính tập con
của từng hàng. Mọi con số ở mục 6.3 và 6.4 là sau khi sửa. Nó cũng kéo theo một
chi tiết: mô hình giữ lại cho mục 6.4 phải mang theo tập test đã chuẩn hóa theo
đúng thống kê nó được huấn luyện, nếu không phép đo dịch sẽ đo chỗ lệch thang
đo thay vì đo phép dịch.

### 6.7 Chạy lại cho ra đúng số

Chạy `experiments/ch10_cifar.py` hai lần liên tiếp cho ra bảng giống nhau tới
từng chữ số. Huấn luyện có seed nên đây là tính chất mong đợi, nhưng nó được
kiểm chứ không được giả định.

## 7. Chỗ phiên này đo sai và phải đo lại

Ghi ra vì quyết định 60 và vì đây đúng loại lỗi mà một bảng sạch sẽ che được.

Bản đầu của `equivariance_error` không có tham số `downsample`. Nó so
`layer(shift(x, k))` với `shift(layer(x), k)`, tức shift đầu ra đúng bằng shift
đầu vào. Với một tầng giảm mẫu hai lần thì so như vậy là sai: shift đầu vào 2
phải cho shift đầu ra 1.

Hệ quả là bảng đầu tiên tôi chạy báo sai lệch lớn ở **mọi** shift, kể cả các
shift chẵn mà tầng ấy đúng tuyệt đối:

```
shift 0: 0.000e+00
shift 1: 2.417e+00
shift 2: 2.570e+00
shift 3: 2.486e+00
shift 4: 2.327e+00
```

Đọc bảng ấy thì kết luận là "subsampling phá equivariance ở mọi shift", mạnh
hơn hẳn và sai. Kết luận đúng là "đúng tuyệt đối ở bội của stride, và không có
gì để nói ở các shift còn lại", và nó vừa đúng vừa sắc hơn.

Không có gì trong build hay trong gate bắt được chỗ này: cả hai bảng đều là số
thật, chạy thật, in ra thật. Cái bắt được nó là đem số đo so với chuyện mình
đoán trước, thấy lệch, và đi tìm lý do thay vì in ra. `tests/test_ch10.py` có
một test pin lại hợp đồng mới, và `equivariance_error` bây giờ raise thay vì
trả về một con số vô nghĩa khi shift không chia hết cho stride.

### 7.2 Câu chuyện sample efficiency suýt bị kể ngược

Trước khi đo, giả thuyết vào phiên là câu quen thuộc: thiên kiến quy nạp đáng
giá nhất khi ít dữ liệu, nên khoảng cách CNN với MLP phải **hẹp lại** khi dữ
liệu nhiều lên.

Số đo nói ngược: khoảng cách **rộng ra**, 0.1202 lên 0.2558. Nếu cứ viết theo
giả thuyết thì chương đã in một câu mà chính bảng của nó bác bỏ.

Chỗ nhầm nằm ở việc đọc sai đại lượng. Khoảng cách tuyệt đối ở một lượng dữ
liệu cố định và số ảnh cần để đạt cùng độ chính xác là hai câu hỏi khác nhau,
và chỉ câu thứ hai nói về sample efficiency. Đo câu thứ hai thì MLP khớp tham số
cần 28,403 ảnh để đạt cái CNN đạt bằng 1000, tức 28.4 lần.

Lý do khoảng cách rộng ra cũng đọc được từ chính bảng: MLP khớp tham số bão hòa
sớm vì nó chỉ có 21 unit ẩn, tức nó bị chặn bởi sức chứa chứ không bởi dữ liệu.
Đó đúng là lý do bảng phải có hàng MLP wide, và hàng ấy cần 10,958 ảnh, tức
11.0 lần. Bội số nhỏ đi rõ rệt và không biến mất.

**Chú ý bội số này phụ thuộc hàng 50000.** Khi hàng ấy bị cắt, ô này chỉ ghi
được \"over 16,000\" - đường cong MLP dừng trước chỗ nó cắt qua. Nên con số
28.4 lần là thứ trực tiếp mất đi vì ngân sách và trực tiếp lấy lại được khi
ngân sách được sửa; đó là ví dụ cụ thể cho câu \"một gate hỏng được trả bằng
kết quả\" ở quyết định 75.

**Một chỗ nữa cùng loại, và nó là chuyện lịch epoch.** Một phép quét sơ bộ chạy
với 8 epoch cố định ở mọi kích thước cho MLP ở n=1000 chỉ 0.1729, và từ đó suy
ra rằng CNN với 1000 ảnh thắng MLP với 50000 ảnh. Câu ấy sai. 1000 ảnh với
batch 128 là 8 bước gradient một epoch, nên 8 epoch là 64 bước: MLP ở đầu ít dữ
liệu đang bị huấn luyện thiếu chứ không phải đang thua vì kiến trúc. Cho các
kích thước nhỏ nhiều epoch hơn thì MLP ở n=1000 lên 0.3163 và câu trên biến
mất.

Bài học chung, và nó không mới trong sách này: **một phép đối chứng dùng chung
một siêu tham số cho mọi hàng đang giả thiết rằng siêu tham số ấy không tương
tác với biến đang quét.** Ở đây nó tương tác. Quyết định 44 nói một phép cắt bỏ
phải có đối chứng khớp kích thước; chỗ này thêm rằng nó cũng phải có đối chứng
khớp lượng huấn luyện, và cách rẻ nhất để kiểm là nhìn cột train accuracy - MLP
ở n=1000 đạt 0.9207 trên tập huấn luyện, nên nó không thiếu bước nữa.
