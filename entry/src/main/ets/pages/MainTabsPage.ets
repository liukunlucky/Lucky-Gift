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
    Column() {
      // 主内容区域
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
        // 浏览Tab
        TabContent() {
          BrowsePage()
        }
        .tabBar(this.buildTabBarItem(0, '浏览', '🔍', '🔍'))

        // 记录Tab
        TabContent() {
          RecordPage()
        }
        .tabBar(this.buildTabBarItem(1, '记录', '📝', '📝'))

        // 工具Tab
        TabContent() {
          ToolsPage()
        }
        .tabBar(this.buildTabBarItem(2, '工具', '🛠️', '🛠️'))

        // 我的Tab
        TabContent() {
          ProfilePage()
        }
        .tabBar(this.buildTabBarItem(3, '我的', '👤', '👤'))
      }
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })
      .animationDuration(300)
      .backgroundColor('#F8F9FA')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  @Builder
  buildTabBarItem(index: number, title: string, normalIcon: string, selectedIcon: string) {
    Column() {
      Text(this.currentTabIndex === index ? selectedIcon : normalIcon)
        .fontSize(24)
        .margin({ bottom: 4 })

      Text(title)
        .fontSize(10)
        .fontColor(this.currentTabIndex === index ? '#FF6B35' : '#8E8E93')
        .fontWeight(this.currentTabIndex === index ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
    .onClick(() => {
      this.currentTabIndex = index;
      this.tabsController.changeIndex(index);
    })
  }
}