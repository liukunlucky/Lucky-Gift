import router from '@ohos.router';
import { BusinessError } from '@ohos.base';
import image from '@ohos.multimedia.image';
import componentSnapshot from '@ohos.arkui.componentSnapshot';
import promptAction from '@ohos.promptAction';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';

interface CardTemplate {
  id: string;
  name: string;
  preview: string;
  backgroundColor: string;
  textColor: string;
  accentColor: string;
  style: 'classic' | 'modern' | 'cute' | 'elegant';
}

interface CardData {
  template: CardTemplate;
  customMessage: string;
  senderName: string;
  receiverName: string;
}

@Entry
@Component
struct GiftCardPreviewPage {
  @State cardData: CardData | null = null;
  @State isSaving: boolean = false;
  @State isShowingShareSheet: boolean = false;


  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, object>;
    if (params && params.cardData) {
      this.cardData = params.cardData as CardData;
    }
  }

  async saveCard() {
    if (!this.cardData) {
      this.isShowingShareSheet = false;
      return;
    }

    try {
      this.isSaving = true;
      
      await this.generateAndSaveCard();
      
      // 显示成功提示
      this.showSuccessMessage();
      
    } catch (error) {
      console.error('保存卡片失败:', error);
      this.showErrorMessage(error as Error);
    } finally {
      this.isSaving = false;
      this.isShowingShareSheet = false;
    }
  }

  async generateAndSaveCard() {
    try {
      // 1. 使用componentSnapshot截取卡片预览
      const pixelMap = await componentSnapshot.get('giftCardPreview');
      
      if (!pixelMap) {
        throw new Error('截图失败');
      }
      
      // 2. 获取应用上下文
      const context = getContext(this) as common.UIAbilityContext;
      
      // 3. 创建PhotoAccessHelper实例
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      
      // 4. 将PixelMap转换为ArrayBuffer
      const imagePackerApi = image.createImagePacker();
      const packOpts: image.PackingOption = {
        format: 'image/jpeg',
        quality: 90
      };
      
      const arrayBuffer = await imagePackerApi.packing(pixelMap, packOpts);
      
      // 5. 生成文件名
      const timestamp = new Date().getTime();
      const fileName = `gift_card_${timestamp}.jpg`;
      
      // 6. 创建相册资源
      const uri = await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');
      
      // 7. 打开文件并写入图片数据
      const file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      await fs.write(file.fd, arrayBuffer);
      await fs.close(file.fd);

      console.log('礼物卡已成功保存到相册');
      
    } catch (error) {
      console.error('生成卡片失败:', error);
      const businessError = error as BusinessError;
      if (businessError.code === 201) {
        throw new Error('需要相册访问权限才能保存图片');
      } else if (businessError.code === 14000011) {
        throw new Error('截图失败，请重试');
      } else {
        throw new Error('保存到相册失败，请检查存储空间');
      }
    }
  }

  showSuccessMessage() {
    promptAction.showToast({
      message: '卡片已保存到相册',
      duration: 2000
    });
  }

  showErrorMessage(error: Error) {
    let message = '保存失败';
    if (error.message.includes('权限')) {
      message = '需要相册访问权限才能保存图片';
    } else if (error.message.includes('截图')) {
      message = '截图失败，请重试';
    } else if (error.message.includes('存储')) {
      message = '保存失败，请检查存储空间';
    }
    
    promptAction.showToast({
      message: message,
      duration: 3000
    });
  }

  // 分享功能
  private shareMemory() {
    this.isShowingShareSheet = true;
  }

  // 微信分享（暂未实现）
  private shareToWechat() {
    promptAction.showToast({
      message: '开发中，尽请期待～',
      duration: 2000
    });
    this.isShowingShareSheet = false;
  }

  // 返回编辑页面
  backToEdit() {
    router.back();
  }

  // 返回主页
  backToHome() {
    router.clear();
    router.pushUrl({
      url: 'pages/Index'
    }).catch((error: Error) => {
      console.error('导航失败:', error);
    });
  }

  @Builder
  CardPreview() {
    if (this.cardData) {
      Column() {
      // 卡片内容
      Column() {
        // 标题区域
        Text('🎁 礼物贺卡')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.cardData.template.textColor)
          .margin({ bottom: 20 })

        // 收件人
        if (this.cardData.receiverName) {
          Text(`亲爱的 ${this.cardData.receiverName}：`)
            .fontSize(18)
            .fontColor(this.cardData.template.textColor)
            .margin({ bottom: 16 })
            .alignSelf(ItemAlign.Start)
        }

        // 自定义消息
        if (this.cardData.customMessage) {
          Text(this.cardData.customMessage)
            .fontSize(16)
            .fontColor(this.cardData.template.textColor)
            .lineHeight(24)
            .margin({ bottom: 20 })
            .textAlign(TextAlign.Start)
        }

        // 发件人
        if (this.cardData.senderName) {
          Text(`来自：${this.cardData.senderName}`)
            .fontSize(16)
            .fontColor(this.cardData.template.accentColor)
            .margin({ top: 20 })
            .alignSelf(ItemAlign.End)
        }

        // 装饰元素
        Row() {
          Text('🌟')
            .fontSize(20)
          Text('💝')
            .fontSize(20)
            .margin({ left: 8, right: 8 })
          Text('🌟')
            .fontSize(20)
        }
        .margin({ top: 16 })
      }
      .width('100%')
      .padding(32)
      .backgroundColor(this.cardData.template.backgroundColor)
      .borderRadius(16)
      .shadow({
        radius: 8,
        color: '#1A000000',
        offsetX: 0,
        offsetY: 4
      })
      }
      .width('90%')
      .margin({ top: 20, bottom: 20 })
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
          this.backToEdit()
        })

        Text('贺卡预览')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        // 分享按钮
        Column({ space: 4 }) {
          Button({ type: ButtonType.Circle }) {
            Image($r('app.media.icon_share'))
              .width(20)
              .height(20)
              .fillColor('#FFFFFF')
          }
          .width(40)
          .height(40)
          .backgroundColor($r('app.color.brand_color'))
          .onClick(() => {
            this.shareMemory();
          })
        }
        .alignItems(HorizontalAlign.Center)

      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 预览内容
      Scroll() {
        Column() {
          // 卡片预览
          Column() {
            this.CardPreview()
          }
          .id('giftCardPreview')
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 32, bottom: 32 })

        }
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .bindSheet($$this.isShowingShareSheet, this.ShareSheet(), {
      height: 200,
      showClose: false,
      onWillDismiss: ((dismissSheetAction: DismissSheetAction) => {
        this.isShowingShareSheet = false;
        dismissSheetAction.dismiss();
      }),
    })
  }

  // 分享弹窗
  @Builder
  ShareSheet() {
    Column() {
      Text('分享贺卡')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .margin({ top: 20, bottom: 30 })

      Row({ space: 40 }) {
        // 微信分享
        Column({ space: 8 }) {
          Button({ type: ButtonType.Circle }) {
            Image($r('app.media.icon_wechat'))
              .width(32)
              .height(32)
              .fillColor('#FFFFFF')
          }
          .width(60)
          .height(60)
          .backgroundColor('#07C160')
          .onClick(() => {
            this.shareToWechat();
          })

          Text('微信分享')
            .fontSize(14)
            .fontColor($r('app.color.primary_text_color'))
        }
        .alignItems(HorizontalAlign.Center)

        // 保存图片 - 使用SaveButton安全控件
        Column({ space: 8 }) {
          SaveButton({
            icon: SaveIconStyle.FULL_FILLED,
            buttonType: ButtonType.Circle
          })
            .width(60)
            .height(60)
            .onClick((_event, result: SaveButtonOnClickResult) => {
              if (result == SaveButtonOnClickResult.SUCCESS) {
                this.saveCard();
              }
            })

          Text('保存图片')
            .fontSize(14)
            .fontColor($r('app.color.primary_text_color'))
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ left: 20, right: 20, bottom: 30 })
    }
    .width('100%')
  }
}