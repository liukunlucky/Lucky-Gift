import { promptAction, router } from '@kit.ArkUI';
import { scanBarcode } from '@kit.ScanKit';
import pasteboard from '@ohos.pasteboard';

const SCAN_TYPE: Record<number, string> = {
  0: 'FORMAT_UNKNOWN',
  1: 'AZTEC_CODE',
  2: 'CODABAR_CODE',
  3: 'CODE39_CODE',
  4: 'CODE93_CODE',
  5: 'CODE128_CODE',
  6: 'DATAMATRIX_CODE',
  7: 'EAN8_CODE',
  8: 'EAN13_CODE',
  9: 'ITF14_CODE',
  10: 'PDF417_CODE',
  11: 'QR_CODE',
  12: 'UPC_A_CODE',
  13: 'UPC_E_CODE',
  14: 'MULTIFUNCTIONAL_CODE',
  100: 'ONE_D_CODE',
  101: 'TWO_D_CODE'
};

@Extend(Text)
function labelText() {
  .fontSize(20)
  .textAlign(TextAlign.Start)
  .fontColor($r('sys.color.black'))
}

@Extend(Text)
function valueText() {
  .margin({
    top: 4,
  })
  .fontSize(16)
  .textAlign(TextAlign.Start)
  .fontColor($r('sys.color.mask_secondary'))
}

export function getScanTypeKey(type: number): string {
  return SCAN_TYPE[type] || ''
}


@Entry
@Component
struct ResultPage {
  @State result: scanBarcode.ScanResult = router.getParams() as scanBarcode.ScanResult;

  build() {
    Column() {
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

        Text('扫码结果')
          .fontSize(20)
          .fontWeight(600)
          .fontColor('#182431')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      Column() {
        Text('码制格式')
          .labelText()

        Row() {
          Text(getScanTypeKey(this.result.scanType))
            .valueText().layoutWeight(1).textAlign(TextAlign.Start)
          Button('点击复制', { type: ButtonType.Capsule, stateEffect: true })
            .width(90)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF6B35')
            .onClick(() => {
              this.copyToClipboard(getScanTypeKey(this.result.scanType))
            })
        }.width('100%')


        Blank().height(50)
        Text('扫码结果').labelText()
        Row() {
          Text(this.result.originalValue)
            .valueText().layoutWeight(1).textAlign(TextAlign.Start)
          Button('点击复制', { type: ButtonType.Capsule, stateEffect: true })
            .width(90)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF6B35')
            .onClick(() => {
              this.copyToClipboard(getScanTypeKey(this.result.scanType))
            })
        }.width('100%')

        if (this.result.scanCodeRect) {
          Text('条码区域')
            .margin({
              top: 18,
            })
            .labelText()
          Text('left: ' + (this.result.scanCodeRect?.left || 0) + '  top: ' + (this.result.scanCodeRect?.top || 0) +
            '  right: ' + (this.result.scanCodeRect?.right || 0) + '  bottom: ' +
            (this.result.scanCodeRect?.bottom || 0))
            .valueText()
        }
      }
      .borderRadius(12)
      .alignItems(HorizontalAlign.Start)
      .padding(24)

      Blank().height(100)
      Button('去搜索商品', { type: ButtonType.Capsule, stateEffect: true })
        .width('90%')
        .fontColor('#FFFFFF')
        .backgroundColor('#FF6B35')
        .onClick(() => {
          // 跳转到商品搜索页面，传递扫描到的条形码
          router.pushUrl({
            url: 'pages/BarcodeProductPage',
            params: {
              barcode: this.result.originalValue
            }
          });
        })
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('white')
  }

  copyToClipboard(content: string) {
    try {

      // 创建剪贴板数据
      const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, content);

      // 获取系统剪贴板
      const systemPasteboard = pasteboard.getSystemPasteboard();

      // 将数据写入剪贴板
      systemPasteboard.setData(pasteData).then(() => {
        // 显示成功提示
        promptAction.showToast({
          message: '已复制到剪贴板',
          duration: 2000
        });
        console.info('Code copied to clipboard successfully');
      }).catch((error: Error) => {
        // 显示错误提示
        promptAction.showToast({
          message: '复制失败，请重试',
          duration: 2000
        });
        console.error('Failed to copy code to clipboard:', error);
      });
    } catch (error) {
      // 显示错误提示
      promptAction.showToast({
        message: '复制失败，请重试',
        duration: 2000
      });
      console.error('Error in copyCode:', error);
    }
  }
}