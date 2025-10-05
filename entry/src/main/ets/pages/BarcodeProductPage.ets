import router from '@ohos.router';
import { http } from '@kit.NetworkKit';
import { promptAction } from '@kit.ArkUI';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ScanHistoryDAO } from '../dao/ScanHistoryDAO';
import { NewDatabaseManager } from '../database/NewDatabaseManager';
import { common } from '@kit.AbilityKit';

// 商品信息接口 - 根据新API调整
interface ProductInfo {
  flag: string;
  remark: string;
  code: string;           // 条形码
  goodsName: string;      // 商品名称
  manuName: string;       // 厂商
  spec: string;           // 规格
  price: string;          // 参考价格
  trademark: string;      // 商标/品牌名称
  img: string;            // 图片地址
  ret_code: string;
  goodsType: string;      // 商品分类
  sptmImg: string;        // 条码图片
  ycg?: string;           // 原产地
  engName?: string;       // 英文名
  note?: string;          // 备注信息
}

// API响应接口 - 根据新API调整
interface ApiResponse {
  showapi_res_code: number;
  showapi_res_error: string;
  showapi_res_body: ProductInfo;
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
  @State showResult: boolean = false;
  @State fromIntro: boolean = false;
  @State fromHistory: boolean = false;
  
  private dbManager: NewDatabaseManager = new NewDatabaseManager();
  private scanHistoryDAO: ScanHistoryDAO = new ScanHistoryDAO(this.dbManager);

  async aboutToAppear() {
    // 初始化数据库
    const context = getContext(this) as common.UIAbilityContext;
    await this.dbManager.initDatabase(context);
    
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    if (params && params.barcode) {
      this.barcode = params.barcode as string;
      this.fromIntro = params.fromIntro as boolean || false;
      this.fromHistory = params.fromHistory as boolean || false;
      
      if (this.fromHistory) {
        // 从历史记录点击，直接从数据库加载数据
        await this.loadFromHistory();
      } else {
        // 正常扫码，请求API
        this.queryProduct();
      }
    }
  }

  // 从历史记录加载商品信息
  async loadFromHistory() {
    if (!this.barcode.trim()) {
      this.errorMessage = '条形码不能为空';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';
    this.productInfo = null;
    this.showResult = false;

    try {
      const historyItem = await this.scanHistoryDAO.getScanHistoryByBarcode(this.barcode);
      
      if (historyItem) {
        // 将历史记录转换为ProductInfo格式
        this.productInfo = {
          flag: historyItem.flag || '',
          remark: historyItem.remark || '',
          code: historyItem.barcode,
          goodsName: historyItem.goodsName,
          manuName: historyItem.manuName || '',
          spec: historyItem.spec || '',
          price: historyItem.price,
          trademark: historyItem.brand,
          img: historyItem.image,
          ret_code: historyItem.ret_code || '',
          goodsType: historyItem.goodsType || '',
          sptmImg: historyItem.sptmImg || '',
          ycg: historyItem.ycg,
          engName: historyItem.engName,
          note: historyItem.note
        };
        this.showResult = true;
      } else {
        this.errorMessage = '未找到该商品的历史记录';
      }
    } catch (error) {
      console.error('加载历史记录失败:', error);
      this.errorMessage = '加载历史记录失败，请重试';
    } finally {
      this.isLoading = false;
    }
  }

  // 查询商品信息
  async queryProduct() {
    if (!this.barcode.trim()) {
      this.errorMessage = '请输入条形码';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';
    this.productInfo = null;
    this.showResult = false;

    try {
      // 构建GET请求的URL
      const encodedBarcode = encodeURIComponent(this.barcode);
      const requestUrl = `https://ali-barcode.showapi.com/barcode?code=${encodedBarcode}`;

      // 创建HTTP请求
      const httpRequest = http.createHttp();
      
      // 发送GET请求
      const response = await httpRequest.request(requestUrl, {
        method: http.RequestMethod.GET,
        header: {
          'Authorization': 'APPCODE c38dd21bb22f4ec9a250174a68c0a6b3',
          'Content-Type': 'application/json'
        }
      });

      // 销毁请求
      httpRequest.destroy();

      // 处理HTTP响应
      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as ApiResponse;
        
        if (result.showapi_res_code === 0 && result.showapi_res_body) {
          this.productInfo = result.showapi_res_body;
          this.showResult = true;
          
          // 保存到扫描历史
          await this.saveScanHistory();
        } else {
          this.errorMessage = result.showapi_res_error || '查询失败';
        }
      } else {
        this.errorMessage = `网络请求失败: ${response.responseCode}`;
      }
    } catch (error) {
      console.error('查询商品信息失败:', error);
      this.errorMessage = '查询失败，请检查网络连接';
    } finally {
      this.isLoading = false;
    }
  }

  // 保存扫描历史
  async saveScanHistory() {
    if (!this.productInfo) return;
    
    try {
      const scanTime = new Date().toLocaleString('zh-CN');
      await this.scanHistoryDAO.addScanHistory({
        barcode: this.productInfo.code,
        goodsName: this.productInfo.goodsName,
        brand: this.productInfo.trademark,
        price: this.productInfo.price,
        image: this.productInfo.img,
        scanTime: scanTime,
        // 保存完整的商品信息
        flag: this.productInfo.flag,
        remark: this.productInfo.remark,
        manuName: this.productInfo.manuName,
        spec: this.productInfo.spec,
        goodsType: this.productInfo.goodsType,
        sptmImg: this.productInfo.sptmImg,
        ycg: this.productInfo.ycg,
        engName: this.productInfo.engName,
        note: this.productInfo.note,
        ret_code: this.productInfo.ret_code
      });
    } catch (error) {
      console.error('保存扫描历史失败:', error);
    }
  }

  // 添加到心愿清单
  addToWishList() {
    if (!this.productInfo) return;
    
    try {
      router.pushUrl({
        url: 'pages/AddWishPage',
        params: {
          prefilledData: {
            title: this.productInfo.goodsName,
            description: `品牌：${this.productInfo.trademark}\n规格：${this.productInfo.spec}\n厂商：${this.productInfo.manuName}`,
            price: this.productInfo.price,
            imageUrl: this.productInfo.img
          }
        }
      });
    } catch (error) {
      console.error('跳转到心愿页面失败:', error);
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
          if (this.productInfo && this.showResult && !this.isLoading) {
            Column({ space: 16 }) {
              Text('商品信息')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)

              // 商品图片
              if (this.productInfo.img) {
                Image(this.productInfo.img)
                  .width(120)
                  .height(120)
                  .objectFit(ImageFit.Contain)
                  .borderRadius(8)
                  .alignSelf(ItemAlign.Center)
                  .backgroundColor('#F8F8F8')
              }

              // 商品基本信息
              Column({ space: 12 }) {
                this.InfoRow('商品名称', this.productInfo.goodsName || '暂无')
                this.InfoRow('品牌/商标', this.productInfo.trademark || '暂无')
                this.InfoRow('价格', this.productInfo.price ? `¥${this.productInfo.price}` : '暂无')
                this.InfoRow('厂商', this.productInfo.manuName || '暂无')
                this.InfoRow('规格', this.productInfo.spec || '暂无')
                this.InfoRow('商品分类', this.productInfo.goodsType || '暂无')
                this.InfoRow('原产地', this.productInfo.ycg || '暂无')
                this.InfoRow('条形码', this.productInfo.code || '暂无')
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