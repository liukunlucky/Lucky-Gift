import router from '@ohos.router';
import { MyWish, WishCategory, WishPriority, WishStatus } from '../model/NewDataModels';
import { NewDatabaseManager } from '../database/NewDatabaseManager';
import { MyWishDAO } from '../database/MyWishDAO';
import { common } from '@kit.AbilityKit';

interface WishDetailParams {
  wish?: MyWish;
  wishId?: string;
}

interface WishEditParams {
  isEdit?: boolean;
  wishId?: string;
  wish?: MyWish;
}

@Entry
@Component
struct WishDetailPage {
  @State wish: MyWish | null = null;
  @State isLoading: boolean = false;

  private dbManager: NewDatabaseManager = new NewDatabaseManager();
  private wishDAO: MyWishDAO = new MyWishDAO(this.dbManager);

  async aboutToAppear() {
    // 初始化数据库
    const context = getContext(this) as common.UIAbilityContext;
    await this.dbManager.initDatabase(context);
    
    const params = router.getParams() as WishDetailParams;

    if (params) {
      if (params.wish) {
        this.wish = params.wish;
      } else if (params.wishId) {
        await this.loadWishFromDatabase(params.wishId);
      }
    }
  }

  async loadWishFromDatabase(wishId: string) {
    try {
      this.isLoading = true;
      const wish = await this.wishDAO.getWishById(wishId);
      if (wish) {
        this.wish = wish;
      }
    } catch (error) {
      console.error('加载心愿数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  editWish() {
    if (this.wish) {
      const editParams: WishEditParams = {
        isEdit: true,
        wishId: this.wish.id,
        wish: this.wish
      };
      router.pushUrl({
        url: 'pages/WishEditPage',
        params: editParams
      });
    }
  }

  async updateWishStatus(status: WishStatus) {
    if (!this.wish) return;

    try {
      this.isLoading = true;
      const updateData: Partial<MyWish> = { status, updatedAt: new Date().toISOString() };
      await this.wishDAO.updateWish(this.wish.id!, updateData);
      if (this.wish) {
        this.wish.status = status;
        this.wish.updatedAt = new Date().toISOString();
      }
    } catch (error) {
      console.error('更新心愿状态失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

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
        return '其他';
    }
  }

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
        return '中';
    }
  }

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
        return '进行中';
    }
  }

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

  formatDate(dateStr?: string): string {
    if (!dateStr) return '未设置';
    try {
      const date = new Date(dateStr);
      if (isNaN(date.getTime())) return '无效日期';
      return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
    } catch (error) {
      return '无效日期';
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
        
        Text('心愿详情')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button() {
          Text('编辑')
            .fontSize(16)
            .fontColor('#007DFF')
        }
        .width(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.editWish())
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      if (this.isLoading) {
        // 加载状态
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#666666')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.wish) {
        // 心愿详情内容
        Scroll() {
          Column({ space: 16 }) {
            // 标题和状态
            Column({ space: 12 }) {
              Text(this.wish.title)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .textAlign(TextAlign.Start)
                .width('100%')

              Row() {
                Text(this.getStatusName(this.wish.status))
                  .fontSize(12)
                  .fontColor(this.getStatusColor(this.wish.status))
                  .backgroundColor(this.getStatusColor(this.wish.status) + '20')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(12)

                Text(this.getPriorityName(this.wish.priority))
                  .fontSize(12)
                  .fontColor(this.getPriorityColor(this.wish.priority))
                  .backgroundColor(this.getPriorityColor(this.wish.priority) + '20')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(12)
                  .margin({ left: 8 })
              }
              .alignItems(VerticalAlign.Center)
              .alignSelf(ItemAlign.Start)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)

            // 基本信息
            Column({ space: 12 }) {
              Text('基本信息')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)

              this.InfoRow('分类', this.getCategoryName(this.wish.category))
              this.InfoRow('目标日期', this.formatDate(this.wish.targetDate))
              if (this.wish.estimatedCost && this.wish.estimatedCost > 0) {
                this.InfoRow('预估费用', `¥${this.wish.estimatedCost}`)
              }
              this.InfoRow('创建时间', this.formatDate(this.wish.createdAt))
              this.InfoRow('更新时间', this.formatDate(this.wish.updatedAt))
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .alignItems(HorizontalAlign.Start)

            // 描述
            if (this.wish.description && this.wish.description.trim().length > 0) {
              Column({ space: 12 }) {
                Text('详细描述')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .alignSelf(ItemAlign.Start)

                Text(this.wish.description)
                  .fontSize(14)
                  .fontColor('#666666')
                  .lineHeight(20)
                  .textAlign(TextAlign.Start)
                  .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .alignItems(HorizontalAlign.Start)
            }

            // 标签
            if (this.wish.tags && this.wish.tags.length > 0) {
              Column({ space: 12 }) {
                Text('标签')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .alignSelf(ItemAlign.Start)

                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.wish.tags, (tag: string) => {
                    Text(tag)
                      .fontSize(12)
                      .fontColor('#007DFF')
                      .backgroundColor('#E6F7FF')
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .borderRadius(12)
                      .margin({ right: 8, bottom: 8 })
                  })
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .alignItems(HorizontalAlign.Start)
            }

            // 备注
            if (this.wish.notes && this.wish.notes.trim().length > 0) {
              Column({ space: 12 }) {
                Text('备注')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .alignSelf(ItemAlign.Start)

                Text(this.wish.notes)
                  .fontSize(14)
                  .fontColor('#666666')
                  .lineHeight(20)
                  .textAlign(TextAlign.Start)
                  .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .alignItems(HorizontalAlign.Start)
            }

            // 状态操作
            Column({ space: 12 }) {
              Text('状态操作')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)

              Row({ space: 8 }) {
                Button('进行中')
                  .fontSize(14)
                  .fontColor(this.wish.status === WishStatus.ACTIVE ? '#FFFFFF' : '#1890FF')
                  .backgroundColor(this.wish.status === WishStatus.ACTIVE ? '#1890FF' : '#F5F5F5')
                  .layoutWeight(1)
                  .onClick(() => this.updateWishStatus(WishStatus.ACTIVE))

                Button('已推迟')
                  .fontSize(14)
                  .fontColor(this.wish.status === WishStatus.POSTPONED ? '#FFFFFF' : '#FA8C16')
                  .backgroundColor(this.wish.status === WishStatus.POSTPONED ? '#FA8C16' : '#F5F5F5')
                  .layoutWeight(1)
                  .onClick(() => this.updateWishStatus(WishStatus.POSTPONED))
              }

              Row({ space: 8 }) {
                Button('已实现')
                  .fontSize(14)
                  .fontColor(this.wish.status === WishStatus.ACHIEVED ? '#FFFFFF' : '#52C41A')
                  .backgroundColor(this.wish.status === WishStatus.ACHIEVED ? '#52C41A' : '#F5F5F5')
                  .layoutWeight(1)
                  .onClick(() => this.updateWishStatus(WishStatus.ACHIEVED))

                Button('已取消')
                  .fontSize(14)
                  .fontColor(this.wish.status === WishStatus.CANCELLED ? '#FFFFFF' : '#8C8C8C')
                  .backgroundColor(this.wish.status === WishStatus.CANCELLED ? '#8C8C8C' : '#F5F5F5')
                  .layoutWeight(1)
                  .onClick(() => this.updateWishStatus(WishStatus.CANCELLED))
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .alignItems(HorizontalAlign.Start)
          }
          .padding(16)
        }
        .layoutWeight(1)
        .backgroundColor('#F5F5F5')
      } else {
        // 无数据状态
        Column() {
          Text('心愿不存在')
            .fontSize(16)
            .fontColor('#666666')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .width(80)

      Text(value)
        .fontSize(14)
        .fontColor('#333333')
        .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }
}