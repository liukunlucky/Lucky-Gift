import { HomePage } from './HomePage';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0;

  aboutToAppear() {
    // 应用初始化
  }

  build() {
    Tabs({ index: this.currentTabIndex }) {
      // 首页Tab
      TabContent() {
        HomePage()
      }
      .tabBar(this.TabBuilder('首页', 0, $r('app.media.ic_home')))

      // 占位Tab - 待开发
      TabContent() {
        Text('功能开发中...')
          .fontSize(16)
          .textAlign(TextAlign.Center)
          .width('100%')
          .height('100%')
      }
      .tabBar(this.TabBuilder('功能', 1, $r('app.media.ic_settings')))
    }
    .width('100%')
    .height('100%')
    .barBackgroundColor($r('app.color.tab_bar_bg'))
    .barPosition(BarPosition.End)
    .onChange((index: number) => {
      this.currentTabIndex = index;
    })

  }

  @Builder
  TabBuilder(title: string, index: number, icon: Resource) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(this.currentTabIndex === index ? $r('app.color.brand_color') : $r('app.color.secondary_text_color'))
      
      Text(title)
        .fontSize(12)
        .fontColor(this.currentTabIndex === index ? $r('app.color.brand_color') : $r('app.color.secondary_text_color'))
        .margin({ top: 4 })
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
  }
}