import bundleManager from '@ohos.bundle.bundleManager';
import { BusinessError } from '@ohos.base';
import { setDarkColorMode, setLightColorMode, setAutoColorMode } from '../viewmodel/ColorModeChangeFunctions';
import { common } from '@kit.AbilityKit';
import { faceDetector } from '@kit.CoreVisionKit';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct SettingPage {
  @State isDarkMode: boolean = false;
  @State showAboutSheet: boolean = false;
  @State showFeedbackSheet: boolean = false;
  @State feedbackText: string = '';
  @State versionName: string = '';
  private context = getContext(this) as common.UIAbilityContext;
  @StorageProp('enableDarkMode') enableDarkMode: boolean = false;
  @StorageProp('isFollowSystemSetting') isFollowSystemSetting: boolean = true;
  @StorageProp('statusBarHeight') statusBarHeight: number = 36;
  async aboutToAppear() {
    // 获取当前深色模式状态
    this.isDarkMode = this.enableDarkMode;
    
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      this.versionName = bundleInfo.versionName;
    }).catch((error: BusinessError) => {
      console.error("get bundleInfo failed,error is " + error)
    })
    // 应用加载的深色模式设置
    if (this.enableDarkMode && !this.isFollowSystemSetting) {
      setDarkColorMode(this.context);
    } else if (!this.enableDarkMode && !this.isFollowSystemSetting) {
      setLightColorMode(this.context);
    }

    AppStorage.setOrCreate('enableDarkMode', this.enableDarkMode);
    AppStorage.setOrCreate('isFollowSystemSetting', this.isFollowSystemSetting);
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.surface_color'))
      .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })

      // 设置内容
      Column() {
        // 深色模式设置
        Row() {
          Column() {
            Text('深色模式')
              .fontSize(16)
              .fontColor($r('app.color.primary_text_color'))
              .fontWeight(FontWeight.Medium)
            Text('切换应用主题外观')
              .fontSize(14)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Toggle({ type: ToggleType.Switch, isOn: this.isDarkMode })
            .selectedColor($r('app.color.brand_color'))
            .switchPointColor('#FFFFFF')
            .onChange(async (isOn: boolean) => {
              // 关闭所有弹窗，防止模式切换时状态异常
              this.showAboutSheet = false;
              this.showFeedbackSheet = false;
              
              this.isDarkMode = isOn;
              this.enableDarkMode = isOn;
              if (isOn) {
                this.isFollowSystemSetting = false;
                setDarkColorMode(this.context);
              } else if (!this.isFollowSystemSetting) {
                setLightColorMode(this.context);
              }
              AppStorage.setOrCreate('enableDarkMode', this.enableDarkMode);
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .backgroundColor($r('app.color.card_background_color'))
        .borderRadius(12)
        .margin({ top: 16 })
        .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })

        // 给个好评
        Row() {
          Column() {
            Text('给个好评')
              .fontSize(16)
              .fontColor($r('app.color.primary_text_color'))
              .fontWeight(FontWeight.Medium)
            Text('喜欢这个应用？给我们一个好评吧')
              .fontSize(14)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Image($r('app.media.ic_arrow_right'))
            .width(20)
            .height(20)
            .fillColor($r('app.color.tertiary_text_color'))
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .backgroundColor($r('app.color.card_background_color'))
        .borderRadius(12)
        .margin({ top: 12 })
        .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })
        .onClick(() => {
          promptAction.showToast({
            message: '开发中，尽请期待～',
            duration: 2000
          });
        })

        // 问题反馈
        Row() {
          Column() {
            Text('问题反馈')
              .fontSize(16)
              .fontColor($r('app.color.primary_text_color'))
              .fontWeight(FontWeight.Medium)
            Text('遇到问题？告诉我们吧')
              .fontSize(14)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Image($r('app.media.ic_arrow_right'))
            .width(20)
            .height(20)
            .fillColor($r('app.color.tertiary_text_color'))
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .backgroundColor($r('app.color.card_background_color'))
        .borderRadius(12)
        .margin({ top: 12 })
        .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })
        .onClick(() => {
          this.showFeedbackSheet = true;
        })
        .bindSheet($$this.showFeedbackSheet, this.FeedbackSheet(), {
          height: 350,
          dragBar: true,
          showClose: false,
          backgroundColor: $r('app.color.surface_color'),
          onDisappear: () => {
            // 移除状态重置，避免与深色模式切换冲突
          }
    })

        // 检查更新
        Row() {
          Column() {
            Text('检查更新')
              .fontSize(16)
              .fontColor($r('app.color.primary_text_color'))
              .fontWeight(FontWeight.Medium)
            Text('检查应用是否有新版本')
              .fontSize(14)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Image($r('app.media.ic_arrow_right'))
            .width(20)
            .height(20)
            .fillColor($r('app.color.tertiary_text_color'))
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .backgroundColor($r('app.color.card_background_color'))
        .borderRadius(12)
        .margin({ top: 12 })
        .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })
        .onClick(() => {
          AlertDialog.show({
            title: '检查更新',
            message: '当前已是最新版本',
            primaryButton: {
              value: '确定',
              action: () => {}
            }
          });
        })

        // 关于应用
        Row() {
          Column() {
            Text('关于应用')
              .fontSize(16)
              .fontColor($r('app.color.primary_text_color'))
              .fontWeight(FontWeight.Medium)
            Text('查看应用信息和版本')
              .fontSize(14)
              .fontColor($r('app.color.secondary_text_color'))
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Image($r('app.media.ic_arrow_right'))
            .width(20)
            .height(20)
            .fillColor($r('app.color.tertiary_text_color'))
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .backgroundColor($r('app.color.card_background_color'))
        .borderRadius(12)
        .margin({ top: 12 })
        .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })
        .onClick(() => {
          this.showAboutSheet = true;
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color'))
    .bindSheet($$this.showAboutSheet, this.AboutSheet(), {
      height: 400,
      dragBar: true,
      showClose: false,
      backgroundColor: $r('app.color.surface_color'),
      onDisappear: () => {
        // 移除状态重置，避免与深色模式切换冲突
      }
    })


  }

  @Builder
  AboutSheet() {
    Column() {
      // Sheet标题
      Text('关于数码回忆')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .margin({ top: 20, bottom: 20 })

      // 应用图标
      Image($r('app.media.layered_image'))
        .width(80)
        .height(80)
        .borderRadius(16)
        .margin({ bottom: 16 })

      // 应用信息
      Column() {
        Text('数码回忆')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
          .margin({ bottom: 8 })

        Text($r('app.string.version', '版本号', this.versionName))
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
          .margin({ bottom: 8 })

        Text('一款专为数码相机爱好者打造的应用')
          .fontSize(14)
          .fontColor($r('app.color.primary_text_color'))
          .textAlign(TextAlign.Center)
          .margin({ bottom: 16 })

        Text('记录每一台相机的故事，珍藏数码时代的美好回忆')
          .fontSize(12)
          .fontColor($r('app.color.secondary_text_color'))
          .textAlign(TextAlign.Center)
          .lineHeight(18)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Blank()

      // 版权信息
      Text('© 2025 数码回忆团队')
        .fontSize(12)
        .fontColor($r('app.color.tertiary_text_color'))
        .margin({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  FeedbackSheet() {
    Column() {
      // Sheet标题
      Text('问题反馈')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .margin({ top: 20, bottom: 20 })

      // 输入提示
      Text('请描述您遇到的问题或建议')
        .fontSize(14)
        .fontColor($r('app.color.secondary_text_color'))
        .margin({ bottom: 16 })
        .alignSelf(ItemAlign.Start)

      // 输入框
      TextArea({
        placeholder: '请输入您的问题或建议...',
        text: this.feedbackText
      })
        .width('100%')
        .height(120)
        .fontSize(14)
        .fontColor($r('app.color.primary_text_color'))
        .backgroundColor($r('app.color.input_background_color'))
        .borderRadius(8)
        .padding(12)
        .maxLength(100)
        .onChange((value: string) => {
          this.feedbackText = value;
        })
        .margin({ bottom: 8 })

      // 字数统计
      Text(`${this.feedbackText.length}/100`)
        .fontSize(12)
        .fontColor($r('app.color.tertiary_text_color'))
        .alignSelf(ItemAlign.End)
        .margin({ bottom: 24 })

      // 提交按钮
      Button('提交反馈')
        .width('100%')
        .height(44)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor($r('app.color.brand_color'))
        .borderRadius(8)
        .enabled(this.feedbackText.trim().length > 0)
        .opacity(this.feedbackText.trim().length > 0 ? 1 : 0.5)
        .onClick(() => {
          if (this.feedbackText.trim().length > 0) {
            promptAction.showToast({
              message: '已提交',
              duration: 2000
            });
            this.feedbackText = '';
            this.showFeedbackSheet = false;
          }
        })

      Blank()
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}