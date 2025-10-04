import { router } from '@kit.ArkUI';
import { MyWish, WishCategory, WishPriority, WishStatus } from '../model/NewDataModels';
import { MyWishDAO } from '../database/MyWishDAO';
import { NewDatabaseManager } from '../database/NewDatabaseManager';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct MyWishPage {
  @State wishes: MyWish[] = [];
  @State filteredWishes: MyWish[] = [];
  @State selectedCategory: WishCategory | 'all' = 'all';
  @State selectedStatus: WishStatus | 'all' = 'all';
  @State searchKeyword: string = '';
  @State isLoading: boolean = false;

  private dbManager: NewDatabaseManager = new NewDatabaseManager();
  private wishDAO: MyWishDAO = new MyWishDAO(this.dbManager);

  async aboutToAppear() {
    // 初始化数据库
    const context = getContext(this) as common.UIAbilityContext;
    await this.dbManager.initDatabase(context);
    
    // 加载心愿数据
    await this.loadWishes();
  }

  async onPageShow() {
    await this.loadWishes();
  }

  // 加载心愿列表
  async loadWishes() {
    this.isLoading = true;
    try {
      this.wishes = await this.wishDAO.getAllWishes();
      this.filterWishes();
    } catch (error) {
      console.error('加载心愿失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 过滤心愿
  filterWishes() {
    let filtered = this.wishes;

    // 按分类过滤
    if (this.selectedCategory !== 'all') {
      filtered = filtered.filter(wish => wish.category === this.selectedCategory);
    }

    // 按状态过滤
    if (this.selectedStatus !== 'all') {
      filtered = filtered.filter(wish => wish.status === this.selectedStatus);
    }

    // 按关键词搜索
    if (this.searchKeyword.trim()) {
      const keyword = this.searchKeyword.toLowerCase();
      filtered = filtered.filter(wish =>
        wish.title.toLowerCase().includes(keyword) ||
        wish.description.toLowerCase().includes(keyword) ||
        wish.tags.some(tag => tag.toLowerCase().includes(keyword))
      );
    }

    this.filteredWishes = filtered;
  }



  // 更新心愿状态
  async updateWishStatus(wish: MyWish, newStatus: WishStatus) {
    try {
      const updateData: Partial<MyWish> = { status: newStatus };
      if (newStatus === WishStatus.ACHIEVED) {
        updateData.achievedDate = new Date().toISOString().split('T')[0];
        updateData.progress = 100;
      }
      await this.wishDAO.updateWish(wish.id!, updateData);
      await this.loadWishes();
    } catch (error) {
      console.error('更新心愿状态失败:', error);
    }
  }



  // 获取分类显示名称
  getCategoryName(category: WishCategory): string {
    switch (category) {
      case WishCategory.GIFT:
        return '礼物心愿';
      case WishCategory.EXPERIENCE:
        return '体验心愿';
      case WishCategory.TRAVEL:
        return '旅行心愿';
      case WishCategory.LEARNING:
        return '学习心愿';
      case WishCategory.HEALTH:
        return '健康心愿';
      case WishCategory.CAREER:
        return '事业心愿';
      case WishCategory.RELATIONSHIP:
        return '关系心愿';
      case WishCategory.HOBBY:
        return '爱好心愿';
      case WishCategory.OTHER:
        return '其他';
      default:
        return '未知';
    }
  }

  // 获取分类索引
  getCategoryIndex(category: WishCategory): number {
    const categories = [
      WishCategory.GIFT,
      WishCategory.EXPERIENCE,
      WishCategory.TRAVEL,
      WishCategory.LEARNING,
      WishCategory.HEALTH,
      WishCategory.CAREER,
      WishCategory.RELATIONSHIP,
      WishCategory.HOBBY,
      WishCategory.OTHER
    ];
    return categories.indexOf(category);
  }

  // 获取优先级显示名称
  getPriorityName(priority: WishPriority): string {
    switch (priority) {
      case WishPriority.LOW:
        return '低';
      case WishPriority.MEDIUM:
        return '中';
      case WishPriority.HIGH:
        return '高';
      case WishPriority.URGENT:
        return '紧急';
      default:
        return '未知';
    }
  }

  // 获取状态显示名称
  getStatusName(status: WishStatus): string {
    switch (status) {
      case WishStatus.ACTIVE:
        return '进行中';
      case WishStatus.ACHIEVED:
        return '已实现';
      case WishStatus.CANCELLED:
        return '已取消';
      case WishStatus.POSTPONED:
        return '已推迟';
      default:
        return '未知';
    }
  }

  // 获取优先级颜色
  getPriorityColor(priority: WishPriority): string {
    switch (priority) {
      case WishPriority.LOW:
        return '#52C41A';
      case WishPriority.MEDIUM:
        return '#1890FF';
      case WishPriority.HIGH:
        return '#FA8C16';
      case WishPriority.URGENT:
        return '#F5222D';
      default:
        return '#1890FF';
    }
  }

  // 获取状态颜色
  getStatusColor(status: WishStatus): string {
    switch (status) {
      case WishStatus.ACTIVE:
        return '#1890FF';
      case WishStatus.ACHIEVED:
        return '#52C41A';
      case WishStatus.CANCELLED:
        return '#8C8C8C';
      case WishStatus.POSTPONED:
        return '#FA8C16';
      default:
        return '#1890FF';
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
          router.back();
        })

        Text('我的心愿')
          .fontSize(20)
          .fontWeight(600)
          .fontColor('#182431')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

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
          router.pushUrl({
            url: 'pages/WishEditPage',
            params: {
              isEdit: false
            }
          });
        })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 搜索和筛选栏
      Column() {
        // 搜索框
        TextInput({ placeholder: '搜索心愿...', text: this.searchKeyword })
          .width('100%')
          .height(40)
          .placeholderColor('#CCCCCCCC')
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.searchKeyword = value;
            this.filterWishes();
          })

        // 筛选按钮
        Row() {
          // 分类筛选
          Button(this.selectedCategory === 'all' ? '全部分类' : this.getCategoryName(this.selectedCategory as WishCategory))
            .fontSize(14)
            .fontColor(this.selectedCategory === 'all' ? '#666666' : '#007DFF')
            .backgroundColor(this.selectedCategory === 'all' ? '#F5F5F5' : '#E6F7FF')
            .borderRadius(16)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .onClick(() => {
              // 这里可以添加分类选择弹窗
            })

          // 状态筛选
          Button(this.selectedStatus === 'all' ? '全部状态' : this.getStatusName(this.selectedStatus as WishStatus))
            .fontSize(14)
            .fontColor(this.selectedStatus === 'all' ? '#666666' : '#007DFF')
            .backgroundColor(this.selectedStatus === 'all' ? '#F5F5F5' : '#E6F7FF')
            .borderRadius(16)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .onClick(() => {
              // 这里可以添加状态选择弹窗
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .margin({ top: 12 })
        .visibility(Visibility.None)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      Blank().height(16)
      // 心愿列表
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#007DFF')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 8 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else if (this.filteredWishes.length === 0) {
        Column() {
          Image($r('sys.media.ohos_ic_public_add'))
            .width(80)
            .height(80)
            .fillColor('#CCCCCC')
          Text('暂无心愿')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ top: 16 })
          Text('点击右上角 + 号添加你的第一个心愿')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 8 })
        }
        .width('100%')
        .height(300)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.filteredWishes, (wish: MyWish) => {
            ListItem() {
              this.WishCard(wish)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, bottom: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 心愿卡片组件
  @Builder WishCard(wish: MyWish) {
    Column() {
      // 卡片头部
      Row() {
        Column() {
          Text(wish.title)
            .fontSize(16)
            .fontWeight(600)
            .fontColor('#182431')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(wish.description)
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 优先级标签
        Text(this.getPriorityName(wish.priority))
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor(this.getPriorityColor(wish.priority))
          .borderRadius(10)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      // 进度条
      if (wish.status === WishStatus.ACTIVE) {
        Column() {
          Row() {
            Text(`进度: ${wish.progress}%`)
              .fontSize(12)
              .fontColor('#666666')
            Blank()
            if (wish.targetDate) {
              Text(`目标: ${wish.targetDate}`)
                .fontSize(12)
                .fontColor('#666666')
            }
          }
          .width('100%')
          .margin({ top: 12 })

          Progress({ value: wish.progress, total: 100, type: ProgressType.Linear })
            .width('100%')
            .height(4)
            .color('#007DFF')
            .backgroundColor('#F0F0F0')
            .margin({ top: 4 })
        }
      }

      // 卡片底部
      Row() {
        // 状态标签
        Text(this.getStatusName(wish.status))
          .fontSize(12)
          .fontColor(this.getStatusColor(wish.status))
          .backgroundColor(this.getStatusColor(wish.status) + '20')
          .borderRadius(10)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })

        // 分类标签
        Text(this.getCategoryName(wish.category))
          .fontSize(12)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .borderRadius(10)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })

        Blank()

        // 操作按钮
        Row() {
          if (wish.status === WishStatus.ACTIVE) {
            Button('完成')
              .fontSize(12)
              .fontColor('#52C41A')
              .backgroundColor('#F6FFED')
              .borderRadius(12)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .onClick(() => {
                this.updateWishStatus(wish, WishStatus.ACHIEVED);
              })
          }

          Button('编辑')
            .fontSize(12)
            .fontColor('#007DFF')
            .backgroundColor('#E6F7FF')
            .borderRadius(12)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .margin({ left: 8 })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/WishEditPage',
                params: {
                  isEdit: true,
                  wishId: wish.id,
                  wish: wish
                }
              });
            })
        }
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/WishDetailPage',
        params: {
          wish: wish,
          wishId: wish.id
        }
      });
    })
  }


}