import router from '@ohos.router';
import { http } from '@kit.NetworkKit';

interface ProductInfo {
  goodsName: string;
  barcode: string;
  price: string;
  brand: string;
  supplier: string;
  standard: string;
}

interface ApiResponse {
  code: number;
  msg: string;
  data: ProductInfo | null;
}

interface BarcodeParams {
  barcode?: string;
}

@Entry
@Component
struct BarcodeProductPage {
  @State barcode: string = '';
  @State productInfo: ProductInfo | null = null;
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State showScanner: boolean = false;

  // 固定的API参数
  private readonly APP_ID = 'gjktlnepktymmtim';
  private readonly APP_SECRET = 'uIEAUFROexbtw9CgVQKI7PDkIbc5xYBp';
  private readonly API_URL = 'https://www.mxnzp.com/api/barcode/goods/details';

  aboutToAppear() {
    const params = router.getParams() as BarcodeParams;
    if (params?.barcode) {
      this.barcode = params.barcode;
      this.queryProduct();
    }
  }

  // 查询商品信息
  async queryProduct() {
    if (!this.barcode.trim()) {
      this.errorMessage = '请输入或扫描条形码';
      return;
    }

    try {
      this.isLoading = true;
      this.errorMessage = '';
      this.productInfo = null;

      const httpRequest = http.createHttp();
      
      // 构建 GET 请求的 URL 参数
      const requestUrl = `${this.API_URL}?app_id=${this.APP_ID}&app_secret=${this.APP_SECRET}&barcode=${encodeURIComponent(this.barcode.trim())}`;
      
      const response = await httpRequest.request(requestUrl, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        }
      });

      httpRequest.destroy();

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as ApiResponse;
        console.log('lucky scan http result is ' + JSON.stringify(result))
        if (result.code === 1 && result.data) {
          this.productInfo = result.data;
        } else {
          this.errorMessage = result.msg || '未找到商品信息';
        }
      } else {
        this.errorMessage = '网络请求失败，请稍后重试';
      }
    } catch (error) {
      console.error('查询商品信息失败:', JSON.stringify(error));
      this.errorMessage = '查询失败，请检查网络连接';
    } finally {
      this.isLoading = false;
    }
  }


  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Image($r('app.media.icon_back'))
            .width(24)
            .height(24)
            .fillColor('#333333')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })
        
        Text('商品识别')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Blank().width(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      // 主要内容
      Scroll() {
        Column({ space: 16 }) {
          // 加载状态
          if (this.isLoading) {
            Column({ space: 12 }) {
              LoadingProgress()
                .width(40)
                .height(40)
                .color('#007DFF')
              
              Text('正在查询商品信息...')
                .fontSize(14)
                .fontColor('#666666')
            }
            .width('100%')
            .padding(32)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
          }

          // 错误信息
          if (this.errorMessage && !this.isLoading) {
            Column({ space: 12 }) {
              Text('⚠️')
                .fontSize(32)
              
              Text(this.errorMessage)
                .fontSize(14)
                .fontColor('#FF4444')
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .padding(32)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
          }

          // 商品信息展示
          if (this.productInfo && !this.isLoading) {
            Column({ space: 16 }) {
              Text('商品信息')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)

              // 商品基本信息
              Column({ space: 12 }) {
                this.InfoRow('商品名称', this.productInfo.goodsName)
                this.InfoRow('品牌', this.productInfo.brand)
                this.InfoRow('价格', `¥${this.productInfo.price}`)
                this.InfoRow('供应商', this.productInfo.supplier)
                this.InfoRow('规格', this.productInfo.standard)
                this.InfoRow('条形码', this.productInfo.barcode)
              }

            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
          }
        }
        .padding(16)
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 信息行组件
  @Builder InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .width(80)
      
      Text(value || '暂无')
        .fontSize(14)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .height(32)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}