import router from '@ohos.router';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { ScanHistoryDAO, ScanHistoryItem } from '../dao/ScanHistoryDAO';
import { NewDatabaseManager } from '../database/NewDatabaseManager';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct BarcodeScanIntroPage {
  @State recentScans: ScanHistoryItem[] = [];
  @State isLoading: boolean = false;
  
  private dbManager: NewDatabaseManager = new NewDatabaseManager();
  private scanHistoryDAO: ScanHistoryDAO = new ScanHistoryDAO(this.dbManager);

  async aboutToAppear() {
    // 初始化数据库
    const context = getContext(this) as common.UIAbilityContext;
    await this.dbManager.initDatabase(context);
    
    // 加载最近扫描记录
    await this.loadRecentScans();
  }

  async onPageShow() {
    // 加载最近扫描记录
    await this.loadRecentScans();
  }

  // 加载最近扫描记录
  async loadRecentScans() {
    try {
      this.recentScans = await this.scanHistoryDAO.getRecentScans(5);
    } catch (error) {
      console.error('加载扫描历史失败:', error);
    }
  }

  // 开始扫码
  async startScan() {
    try {
      this.isLoading = true;
      
      // 检查扫码权限
      const options: scanBarcode.ScanOptions = {
        scanTypes: [scanCore.ScanType.ALL],
        enableMultiMode: false,
        enableAlbum: true
      };

      const result = await scanBarcode.startScanForResult(getContext(this), options);
      
      if (result && result.originalValue) {
        // 跳转到商品详情页面
        router.pushUrl({
          url: 'pages/BarcodeProductPage',
          params: {
            barcode: result.originalValue,
            fromIntro: true
          }
        });
      }
    } catch (error) {
      console.error('扫码失败:', error);
      promptAction.showToast({
        message: '扫码失败，请重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  // 查看扫描历史详情
  viewScanHistory(item: ScanHistoryItem) {
    router.pushUrl({
      url: 'pages/BarcodeProductPage',
      params: {
        barcode: item.barcode,
        fromHistory: true
      }
    });
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
        
        Text('商品扫码')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 占位符保持居中
        Row().width(40).height(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      Scroll() {
        Column({ space: 24 }) {
          // 使用介绍区域
          Column({ space: 16 }) {
            Text('如何使用商品扫码')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            // 条形码示意图
            Column({ space: 12 }) {
              Image($r('app.media.pic_barcode'))
                .width(200)
                .height(120)
                .objectFit(ImageFit.Contain)
                .borderRadius(8)
                .backgroundColor('#F8F8F8')

              Text('请将摄像头对准商品包装上的条形码')
                .fontSize(14)
                .fontColor('#666666')
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)

            // 使用说明
            Column({ space: 8 }) {
              this.InstructionItem('1', '找到商品包装上的条形码')
              this.InstructionItem('2', '点击下方"扫一扫"按钮')
              this.InstructionItem('3', '将摄像头对准条形码扫描')
              this.InstructionItem('4', '查看商品详细信息')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)

          // 扫一扫按钮
          Button() {
            Row({ space: 8 }) {
              if (this.isLoading) {
                LoadingProgress()
                  .width(20)
                  .height(20)
                  .color('#FFFFFF')
              } else {
                Image($r('app.media.icon_scan'))
                  .width(24)
                  .height(24)
                  .fillColor('#ffffff')
              }
              
              Text(this.isLoading ? '扫描中...' : '扫一扫')
                .fontSize(18)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Medium)
            }
          }
          .width('80%')
          .height(56)
          .backgroundColor('#FA8C16')
          .borderRadius(28)
          .enabled(!this.isLoading)
          .onClick(() => this.startScan())

          // 最近扫描记录
          if (this.recentScans.length > 0) {
            Column({ space: 16 }) {
              Row() {
                Text('最近扫描')
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                
                Blank()
                
                Text(`共${this.recentScans.length}条记录`)
                  .fontSize(14)
                  .fontColor('#999999')
              }
              .width('100%')

              Column({ space: 12 }) {
                ForEach(this.recentScans, (item: ScanHistoryItem, index: number) => {
                  this.ScanHistoryItem(item, index)
                })
              }
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            Blank().height(20)
          } else {
            Column() {
              Text('最近无扫描记录').fontSize(14)
                .fontColor('#999999')
            }.height(200).justifyContent(FlexAlign.Center).width('90%').backgroundColor('#FFFFFF').borderRadius(12)


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

  // 使用说明项
  @Builder InstructionItem(step: string, description: string) {
    Row({ space: 12 }) {
      Text(step)
        .width(24)
        .height(24)
        .fontSize(12)
        .fontColor('#FFFFFF')
        .backgroundColor('#FA8C16')
        .borderRadius(12)
        .textAlign(TextAlign.Center)
      
      Text(description)
        .fontSize(14)
        .fontColor('#333333')
        .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  // 扫描历史项
  @Builder ScanHistoryItem(item: ScanHistoryItem, index: number) {
    Row({ space: 12 }) {
      // 商品图片
      if (item.image) {
        Image(item.image)
          .width(50)
          .height(50)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
      } else {
        Row() {
          Text('📦')
            .fontSize(20)
        }
        .width(50)
        .height(50)
        .backgroundColor('#F0F0F0')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }

      // 商品信息
      Column({ space: 4 }) {
        Text(item.goodsName || '未知商品')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .alignSelf(ItemAlign.Start)
        
        Text(item.brand || '未知品牌')
          .fontSize(12)
          .fontColor('#666666')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .alignSelf(ItemAlign.Start)
        
        Row({ space: 8 }) {
          Text(`¥${item.price || '0.00'}`)
            .fontSize(12)
            .fontColor('#FF6B35')
            .fontWeight(FontWeight.Medium)
          
          Text(item.scanTime)
            .fontSize(10)
            .fontColor('#999999')
        }
        .alignSelf(ItemAlign.Start)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 箭头
      Text('›')
        .fontSize(16)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FAFAFA')
    .borderRadius(8)
    .onClick(() => this.viewScanHistory(item))
  }
}