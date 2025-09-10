@Entry
@Component
export struct HomePage {
  @State searchText: string = '';
  @State giftCategories: string[] = ['生日礼物', '节日礼物', '纪念日礼物', '感谢礼物', '道歉礼物'];
  @State selectedCategory: string = '全部';

  aboutToAppear() {
    // 初始化礼物推荐应用
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('送什么')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.background_color'))

      // 搜索框
      Row() {
        TextInput({ placeholder: '搜索礼物...' })
          .width('100%')
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('app.color.input_background_color'))
          .onChange((value: string) => {
            this.searchText = value;
          })
      }
      .width('90%')
      .margin({ top: 16, bottom: 16 })

      // 分类选择
      Scroll(new Scroller()) {
        Row() {
          ForEach(['全部', ...this.giftCategories], (category: string) => {
            Text(category)
              .fontSize(14)
              .fontColor(this.selectedCategory === category ? '#FFFFFF' : $r('app.color.primary_text_color'))
              .backgroundColor(this.selectedCategory === category ? $r('app.color.brand_color') : $r('app.color.background_color'))
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .borderRadius(16)
              .margin({ right: 8 })
              .onClick(() => {
                this.selectedCategory = category;
              })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .margin({ bottom: 20 })

      // 主要内容区域
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center }) {
        Image($r('app.media.startIcon'))
          .width(120)
          .height(120)
          .margin({ bottom: 20 })

        Text('欢迎使用送什么')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_text_color'))
          .margin({ bottom: 8 })

        Text('帮您找到最合适的礼物')
          .fontSize(16)
          .fontColor($r('app.color.secondary_text_color'))
          .margin({ bottom: 32 })

        Button('开始推荐')
          .width(200)
          .height(48)
          .borderRadius(24)
          .backgroundColor($r('app.color.brand_color'))
          .fontColor('#FFFFFF')
          .onClick(() => {
            // 待实现：跳转到礼物推荐页面
          })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color'))
  }
}