import { HomePage } from './tabs/HomePage';
import { BrowsePage } from './tabs/BrowsePage';
import { RecordPage } from './tabs/RecordPage';
import { GiftStoryPage } from './tabs/GiftStoryPage';
import { ProfilePage } from './tabs/ProfilePage';
import router from '@ohos.router';
import app from '@system.app';
import { promptAction } from '@kit.ArkUI';

interface RouteParams {
  targetTab?: number;
}

@Entry
@Component
struct MainTabsPage {
  @State currentTabIndex: number = 0;
  @State recordPageRefreshKey: number = 0;
  private tabsController: TabsController = new TabsController();
  private lastExitTime: number = -1;

  aboutToAppear() {
    // 检查是否有指定的目标tab
    const params = router.getParams() as RouteParams;
    if (params && params.targetTab !== undefined) {
      this.currentTabIndex = params.targetTab;
      // 如果目标是记录页面，触发刷新
      if (params.targetTab === 2) {
        this.recordPageRefreshKey++;
      }
    }
  }

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController, index: this.currentTabIndex }) {
      // 首页Tab
      TabContent() {
        HomePage({ tabsController: this.tabsController })
      }
      .tabBar(this.buildTabBarItem(0, '首页', $r('app.media.icon_home')))

      // 灵感Tab
      TabContent() {
        BrowsePage()
      }
      .tabBar(this.buildTabBarItem(1, '灵感', $r('app.media.icon_insp')))

      // 记录Tab
      TabContent() {
        RecordPage({ refreshKey: this.recordPageRefreshKey })
      }
      .tabBar(this.buildTabBarItem(2, '记录', $r('app.media.icon_record')))

      // 故事Tab
      TabContent() {
        GiftStoryPage()
      }
      .tabBar(this.buildTabBarItem(3, '故事', $r('app.media.icon_story')))

      // 我的Tab
      TabContent() {
        ProfilePage()
      }
      .tabBar(this.buildTabBarItem(4, '我的', $r('app.media.icon_mine')))
    }
    .onChange((index: number) => {
      this.currentTabIndex = index;
      // 当切换到记录页面时，触发数据刷新
      if (index === 2) {
        this.recordPageRefreshKey++;
      }
      if (index == 4) {
        AppStorage.setOrCreate('refreshProfilePage', Date.now());
      }
    })
    .animationDuration(300)
    .scrollable(false)
    .backgroundColor('#F8F9FA')
    .barMode(BarMode.Fixed)
  }

  @Builder
  buildTabBarItem(index: number, title: string, icon: Resource) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(this.currentTabIndex === index ? '#F34F40' : '#7F8C8D')
        .margin({ bottom: 4 })

      Text(title)
        .fontSize(10)
        .fontColor(this.currentTabIndex === index ? '#F34F40' : '#7F8C8D')
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

  onBackPress(): boolean | void {
    if (-1 == this.lastExitTime) {
      this.lastExitTime = new Date().getTime();
      promptAction.showToast({
        message: "再按一次退出",
        alignment: Alignment.Center
      })
      return true;
    } else {
      let currentTime = new Date().getTime();
      if(currentTime - this.lastExitTime > 2000) {
        promptAction.showToast({
          message: "再按一次退出",
          alignment: Alignment.Center
        })
        this.lastExitTime = currentTime;
        return true;
      } else {
        app.terminate();
      }
    }
    return false;
  }
}