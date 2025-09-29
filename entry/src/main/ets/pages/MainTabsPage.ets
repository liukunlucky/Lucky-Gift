import { HomePage } from './tabs/HomePage';
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
    Stack() {
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController, index: this.currentTabIndex }) {
        // 首页Tab
        TabContent() {
          HomePage({ tabsController: this.tabsController })
        }
        .tabBar(this.buildTabBarItem(0, '首页', $r('app.media.icon_home')))

        // 记录Tab
        TabContent() {
          RecordPage({ refreshKey: this.recordPageRefreshKey })
        }
        .tabBar(this.buildTabBarItem(1, '记录', $r('app.media.icon_record')))

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
        if (index === 0) {
          AppStorage.setOrCreate('refreshHomePage', Date.now());
        }
        // 当切换到记录页面时，触发数据刷新
        if (index === 1) {
          this.recordPageRefreshKey++;
        }
        if (index == 3) {
          AppStorage.setOrCreate('refreshStoryPage', Date.now());
        }
        if (index == 4) {
          AppStorage.setOrCreate('refreshProfilePage', Date.now());
        }
      })
      .animationDuration(300)
      .scrollable(false)
      .backgroundColor('#F8F9FA')
      .barMode(BarMode.Fixed)

      // 自定义底部导航栏
      this.buildCustomTabBar()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildTabBarItem(index: number, title: string, icon: Resource) {
    // 对于中间的tab（记录Tab），返回透明的占位符
    if (index === 2) {
      Column()
        .width('100%')
        .height(56)
        .backgroundColor('transparent')
    } else {
      Column() {
        Image(icon)
          .width(24)
          .height(24)
          .fillColor(this.currentTabIndex === index ? '#F34F40' : '#7F8C8D')
          .margin({ bottom: 4 })

        Text(title)
          .fontSize(10)
          .fontColor(this.currentTabIndex === index ? '#F34F40' : '#7F8C8D')
          .margin({ bottom: 2 })
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

  @Builder
  buildCustomTabBar() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.End }) {
        // 左侧两个tab
        this.buildNormalTabItem(0, '首页', $r('app.media.icon_home'))
        this.buildNormalTabItem(1, '记录', $r('app.media.icon_record'))
        
        // 中间凸起的tab
        this.buildCenterTabItem()
        
        // 右侧两个tab
        this.buildNormalTabItem(3, '故事', $r('app.media.icon_story'))
        this.buildNormalTabItem(4, '我的', $r('app.media.icon_mine'))
      }
      .width('100%')
      .height(80)
      .backgroundColor('#F8F9FA')
      .padding({ left: 8, right: 8, bottom: 8 })
    }
    .position({ x: 0, y: '100%' })
    .translate({ y: -80 })
    .zIndex(999)
  }

  @Builder
  buildNormalTabItem(index: number, title: string, icon: Resource) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(this.currentTabIndex === index ? '#F34F40' : '#7F8C8D')
        .margin({ bottom: 4 })

      Text(title)
        .fontSize(10)
        .fontColor(this.currentTabIndex === index ? '#F34F40' : '#7F8C8D')
        .fontWeight(this.currentTabIndex === index ? FontWeight.Medium : FontWeight.Normal)
    }
    .width(60)
    .height(56)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.currentTabIndex = index;
      this.tabsController.changeIndex(index);
    })
  }

  @Builder
  buildCenterTabItem() {
    Stack() {
      // 图标和文字
      Column() {
        Image($r('app.media.ic_add'))
          .width(48)
          .height(48)
          .fillColor('#FF6B35')
          .margin({ bottom: 2 })

        Text('添加记录')
          .fontSize(9)
          .fontColor('#7F8C8D')
          .fontWeight(FontWeight.Medium)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width(64)
    .height(64)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/tabs/CreateGiftEventPage'
      }).catch((error: Error) => {
        console.error('Failed to navigate to CreateGiftEventPage:', error);
      });
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