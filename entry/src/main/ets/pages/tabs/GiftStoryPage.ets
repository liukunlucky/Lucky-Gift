import router from '@ohos.router';
import { GiftStory, GiftEvent } from '../../model/NewDataModels';
import { GiftStoryDAO } from '../../dao/GiftStoryDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';

@Component
export struct GiftStoryPage {
  @State giftStories: GiftStory[] = [];
  @State isLoading: boolean = true;
  @State searchKeyword: string = '';
  @State showCreateDialog: boolean = false;
  @State selectedStory: GiftStory | null = null;
  @State showDetailDialog: boolean = false;
  @State refreshKey: number = 0;
  @StorageProp('refreshStoryPage') @Watch('onRefreshStory') refreshStory: number = -1;
 

  private dbManager = new NewDatabaseManager();
  private giftStoryDAO: GiftStoryDAO | null = null;

  aboutToAppear() {
    this.initDatabase();
  }

  onRefreshStory() {
    if (this.refreshStory >= 0) {
      this.loadGiftStories();
      AppStorage.setOrCreate('refreshStory', -1);
    }
  }

  private async initDatabase() {
    try {
      if (!this.dbManager.isInitialized()) {
        await this.dbManager.initDatabase(getContext(this));
      }
      const rdbStore = this.dbManager.getRdbStore();
      if (rdbStore) {
        this.giftStoryDAO = new GiftStoryDAO(rdbStore);
        await this.loadGiftStories();
      }
    } catch (error) {
      console.error('初始化数据库失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  private async loadGiftStories() {
    if (!this.giftStoryDAO) return;

    try {
      if (this.searchKeyword.trim()) {
        this.giftStories = await this.giftStoryDAO.searchGiftStories(this.searchKeyword);
      } else {
        this.giftStories = await this.giftStoryDAO.getAllGiftStories();
      }
    } catch (error) {
      console.error('加载礼物故事失败:', error);
    }
  }

  private async onSearch() {
    await this.loadGiftStories();
  }

  private onCreateStory() {
    router.pushUrl({
      url: 'pages/CreateGiftStoryPage'
    }).catch((error: Error) => {
      console.error('跳转到创建故事页面失败:', error);
    });
  }

  private onStoryClick(story: GiftStory) {
    this.onEditStory(story);
  }

  private onDeleteStory(story: GiftStory) {
    AlertDialog.show({
      title: '确认删除',
      message: `确定要删除故事"${story.title}"吗？\n删除后无法恢复。`,
      primaryButton: {
        value: '取消',
        action: () => {
          console.info('取消删除');
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#FF4444',
        action: () => {
          this.confirmDeleteStory(story);
        }
      }
    });
  }

  private async confirmDeleteStory(story: GiftStory) {
    try {
      if (this.giftStoryDAO && story.id) {
        await this.giftStoryDAO.deleteGiftStory(story.id);
        await this.loadGiftStories();
      }
    } catch (error) {
      console.error('删除故事失败:', error);
    }
  }

  private onEditStory(story: GiftStory) {
    router.pushUrl({
      url: 'pages/CreateGiftStoryPage',
      params: { story: story }
    }).catch((error: Error) => {
      console.error('跳转到编辑故事页面失败:', error);
    });
  }

  build() {
    Stack() {
      Column() {
      // 顶部导航栏
      Row() {
        Blank().width(40)
        .backgroundColor(Color.Transparent)

        Text('礼物故事')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .textAlign(TextAlign.Center)
          .layoutWeight(1)

        Button() {
          Image($r('app.media.ic_add'))
            .width(36)
            .height(36)
            .fillColor('#FF6B35')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.onCreateStory();
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(Color.White)
      // 顶部搜索栏
      this.buildSearchBar()

      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.giftStories.length === 0) {
        // 空状态
        this.buildEmptyState()
      } else {
        // 故事列表
        this.buildStoryList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    }
  }

  @Builder
  buildSearchBar() {
    Row() {
      TextInput({ placeholder: '搜索故事标题、内容或收礼人...' })
        .layoutWeight(1)
        .height(40)
        .placeholderColor('#CCCCCC')
        .borderRadius(20)
        .backgroundColor('#F0F0F0')
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.searchKeyword = value;
          this.onSearch();
        })
    }
    .backgroundColor(Color.White)
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
  }

  @Builder
  buildEmptyState() {
    Column() {
      Image($r('app.media.icon_empty'))
        .width(173)
        .height(128)

      Text('还没有礼物故事')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 16 })

      Text('记录每一份礼物背后的温暖故事')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildStoryList() {
    Column() {
      // 故事列表
      List({ space: 12 }) {
        ForEach(this.giftStories, (story: GiftStory) => {
          ListItem() {
            this.buildStoryCard(story)
          }
        }, (story: GiftStory) => story.id || '')
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16, bottom: 16 })
    }.padding({top: 12})
    .width('100%')
    .height('100%')
  }

  @Builder
  buildStoryCard(story: GiftStory) {
    Column({ space: 12 }) {
      // 标题和操作按钮
      Row() {
        Column({ space: 4 }) {
          Text(story.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`送给 ${story.contactName}`)
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Row({ space: 8 }) {
          Button('删除')
            .fontSize(12)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('#FFE6E6')
            .fontColor('#FF4444')
            .borderRadius(12)
            .onClick(() => {
              this.onDeleteStory(story);
            })
        }
      }
      .width('100%')

      Row(){
        Text(story.content)
          .fontSize(14)
          .fontColor('#666666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(20)
      }.width('100%').justifyContent(FlexAlign.Start).visibility(story.content?Visibility.Visible:Visibility.None)

      // 图片预览
      Row({ space: 8 }) {
        ForEach(story.images.slice(0, 3), (imagePath: string, index: number) => {
          Image(imagePath)
            .width(60)
            .height(60)
            .borderRadius(8)
            .objectFit(ImageFit.Cover)
            .backgroundColor('#F0F0F0')
        }, (imagePath: string, index: number) => `${story.id}_${index}`)

        if (story.images.length > 3) {
          Column() {
            Text(`+${story.images.length - 3}`)
              .fontSize(12)
              .fontColor('#666666')
          }
          .width(60)
          .height(60)
          .backgroundColor('#F0F0F0')
          .borderRadius(8)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%').visibility(story.images && story.images.length > 0?Visibility.Visible:Visibility.None)

      // 标签
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(story.tags, (tag: string) => {
          Text(tag)
            .fontSize(12)
            .fontColor('#007AFF')
            .backgroundColor('#E6F3FF')
            .padding({ left: '8vp', right: '8vp', top: '4vp', bottom: '4vp' })
            .borderRadius(10)
        }, (tag: string) => tag)
      }
      .width('100%').visibility(story.tags && story.tags.length > 0?Visibility.Visible:Visibility.None)
      // 时间
      Row() {
        Text(this.formatDate(story?.createdAt??""))
          .fontSize(12)
          .fontColor('#999999')
      }.width('100%').justifyContent(FlexAlign.Start).visibility(story.createdAt? Visibility.Visible:Visibility.None)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .onClick(() => {
      this.onEditStory(story);
    })
  }



  private formatDate(dateString: string): string {
    const date = new Date(dateString);
    const now = new Date();
    const diffTime = now.getTime() - date.getTime();
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

    if (diffDays === 0) {
      return '今天';
    } else if (diffDays === 1) {
      return '昨天';
    } else if (diffDays < 7) {
      return `${diffDays}天前`;
    } else {
      return date.toLocaleDateString('zh-CN');
    }
  }
}