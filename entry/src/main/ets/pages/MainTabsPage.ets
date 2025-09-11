import { BrowsePage } from './tabs/BrowsePage';
import { RecordPage } from './tabs/RecordPage';
import { ToolsPage } from './tabs/ToolsPage';
import { ProfilePage } from './tabs/ProfilePage';

@Entry
@Component
struct MainTabsPage {
  @State currentTabIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      // 浏览Tab
      TabContent() {
        BrowsePage()
      }
      .tabBar(this.buildTabBarItem(0, '浏览', $r('app.media.icon_search')))

      // 记录Tab
      TabContent() {
        RecordPage()
      }
      .tabBar(this.buildTabBarItem(1, '记录', $r('app.media.icon_record')))

      // 工具Tab
      TabContent() {
        ToolsPage()
      }
      .tabBar(this.buildTabBarItem(2, '工具', $r('app.media.icon_tools')))

      // 我的Tab
      TabContent() {
        ProfilePage()
      }
      .tabBar(this.buildTabBarItem(3, '我的', $r('app.media.icon_mine')))
    }
    .onChange((index: number) => {
      this.currentTabIndex = index;
    })
    .animationDuration(300)
    .backgroundColor('#F8F9FA')
    .barMode(BarMode.Fixed)
  }

  @Builder
  buildTabBarItem(index: number, title: string, icon: Resource) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(this.currentTabIndex === index ? '#007AFF' : '#007AFF')
        .margin({ bottom: 4 })

      Text(title)
        .fontSize(10)
        .fontColor(this.currentTabIndex === index ? '#FF6B35' : '#8E8E93')
        .margin({ bottom: 2 }) // 添加底部间距
        .fontWeight(this.currentTabIndex === index ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F8F9FA')
    .onClick(() => {
      this.currentTabIndex = index;
      this.tabsController.changeIndex(index);
    })
  }
}