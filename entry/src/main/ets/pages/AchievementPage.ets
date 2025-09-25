import router from '@ohos.router';
import { Achievement, UserAchievementProgress, AchievementMilestone, UserAchievementDetail } from '../model/NewDataModels';
import { AchievementDAO } from '../dao/AchievementDAO';
import { NewDatabaseManager } from '../database/NewDatabaseManager';

@Entry
@Component
struct AchievementPage {
  @State userAchievements: UserAchievementDetail[] = [];
  @State milestones: AchievementMilestone[] = [];
  @State isLoading: boolean = true;

  private dbManager = new NewDatabaseManager();
  private achievementDAO: AchievementDAO | null = null;
  private userId: string = 'default_user'; // 默认用户ID，实际应用中应从用户系统获取

  aboutToAppear() {
    this.initDatabase();
  }

  private async initDatabase() {
    try {
      if (!this.dbManager.isInitialized()) {
        await this.dbManager.initDatabase(getContext(this));
      }
      const rdbStore = this.dbManager.getRdbStore();
      if (rdbStore) {
        this.achievementDAO = new AchievementDAO(this.userId, this.dbManager);
        await this.achievementDAO.initDatabase(getContext(this));
        await this.loadUserAchievements();
      }
    } catch (error) {
      console.error('初始化数据库失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  private async loadUserAchievements() {
    if (!this.achievementDAO) {
      console.error('AchievementDAO未初始化');
      return;
    }

    try {
      console.info('开始加载用户成就数据...');
      this.userAchievements = await this.achievementDAO.getUserAchievementDetails(this.userId);
      console.info(`成功加载${this.userAchievements.length}个成就数据`);
    } catch (error) {
      console.error('加载用户成就数据失败:', error);
      // 即使加载失败，也要确保显示空的成就列表而不是错误状态
      this.userAchievements = [];
    }
  }

  private async getAchievementMilestones(achievementId: string): Promise<AchievementMilestone[]> {
    if (!this.achievementDAO) return [];
    return await this.achievementDAO.getAchievementMilestones(achievementId);
  }

  // 移除tab过滤方法，直接返回所有成就

  private formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日`;
  }

  private onBack() {
    router.back();
  }

  build() {
    Column() {
      // 顶部导航栏
      this.buildNavigationBar()

      if (this.isLoading) {
        // 加载状态
        this.buildLoadingState()
      } else {
        // 成就列表
        this.buildAchievementGrid()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildNavigationBar() {
    Row() {
      Button() {
        Image($r('app.media.icon_back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
      }
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.onBack();
      })

      Text('成就系统')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 占位，保持标题居中
      Row()
        .width(40)
        .height(40)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 0.5 }, color: '#E5E5E5' })
  }

  @Builder
  buildLoadingState() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#007AFF')

      Text('加载中...')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 12 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  // 移除tab相关的Builder方法

  @Builder
  buildAchievementGrid() {
    Grid() {
      ForEach(this.userAchievements, (userAchievement: UserAchievementDetail) => {
        GridItem() {
          this.buildAchievementCard(userAchievement)
        }
      }, (userAchievement: UserAchievementDetail) => userAchievement.template.id || '')
    }
    .columnsTemplate('1fr 1fr') // 一行显示2个
    .rowsGap(12)
    .columnsGap(12)
    .width('100%')
    .layoutWeight(1)
    .padding(16)
  }

  @Builder
  buildEmptyState() {
    Column() {
      Image($r('app.media.ic_achievement_empty'))
        .width(80)
        .height(80)
        .fillColor('#CCCCCC')

      Text('暂无成就数据')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 16 })

      Text('继续使用应用来解锁更多成就吧！')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildAchievementCard(userAchievement: UserAchievementDetail) {
    Stack() {
      Column({ space: 12 }) {
        // 成就图标
        Column() {
          Text(userAchievement.template.icon || '🏆')
            .fontSize(28)
            .opacity(userAchievement.progress.isUnlocked ? 1.0 : 0.6)
        }
        .width(50)
        .height(50)
        .backgroundColor(userAchievement.progress.isUnlocked ? '#E6F3FF' : '#F8F8F8')
        .borderRadius(25)
        .justifyContent(FlexAlign.Center)
        .border({
          width: userAchievement.progress.isUnlocked ? 2 : 1,
          color: userAchievement.progress.isUnlocked ? '#007AFF' : '#E0E0E0'
        })

        // 成就信息
        Column({ space: 6 }) {
          Text(userAchievement.template.name)
            .fontSize(14)
            .fontWeight(userAchievement.progress.isUnlocked ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(userAchievement.progress.isUnlocked ? '#333333' : '#888888')
            .textAlign(TextAlign.Center)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 固定高度的描述文本区域
          Text(userAchievement.template.description)
            .fontSize(12)
            .fontColor(userAchievement.progress.isUnlocked ? '#666666' : '#999999')
            .textAlign(TextAlign.Center)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .height(32) // 固定高度，确保两行文本的空间
            .lineHeight(16) // 设置行高

          // 进度信息
          if (userAchievement.template.targetValue) {
            Text(`${userAchievement.progress.currentProgress}/${userAchievement.template.targetValue}`)
              .fontSize(11)
              .fontColor(userAchievement.progress.isUnlocked ? '#007AFF' : '#BBBBBB')
              .fontWeight(userAchievement.progress.isUnlocked ? FontWeight.Medium : FontWeight.Normal)
              .textAlign(TextAlign.Center)
              .height(16) // 固定高度
          } else {
            // 占位空间，保持布局一致
            Text('')
              .height(16)
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)

        // 进度条区域 - 固定高度
        Column() {
          if (userAchievement.template.targetValue) {
            Progress({ value: userAchievement.progressPercentage, total: 100, type: ProgressType.Linear })
              .width('100%')
              .height(3)
              .color(userAchievement.progress.isUnlocked ? '#00C851' : '#007AFF')
              .backgroundColor('#E5E5E5')
          } else {
            // 占位空间，保持布局一致
            Row()
              .width('100%')
              .height(3)
          }
        }
        .width('100%')
        .height(8) // 固定进度条区域高度
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height(180) // 设置固定卡片高度
      .padding(12)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween) // 均匀分布内容

      // 右上角解锁状态标识
      Row() {
        Image($r('app.media.icon_complete'))
          .width(39)
          .fillColor(Color.Red)
          .height(39)
          .zIndex(10)
      }
      .width(50)
      .height(50)
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .position({ x: '100%', y: 0 })
      .translate({ x: -50, y: 0 })
      .visibility(userAchievement.progress.isUnlocked?Visibility.Visible:Visibility.Hidden)
    }
    .width('100%')
    .height(180) // 确保Stack容器也有固定高度
    .backgroundColor(userAchievement.progress.isUnlocked ? '#FFFFFF' : '#FAFAFA')
    .borderRadius(12)
    .shadow({
      radius: userAchievement.progress.isUnlocked ? 8 : 4,
      color: userAchievement.progress.isUnlocked ? '#1A000000' : '#0D000000',
      offsetX: 0,
      offsetY: userAchievement.progress.isUnlocked ? 4 : 2
    })
    // 添加边框增强视觉效果
    .border({
      width: userAchievement.progress.isUnlocked ? 2 : 1,
      color: userAchievement.progress.isUnlocked ? '#E6F3FF' : '#F0F0F0'
    })
    .opacity(userAchievement.progress.isUnlocked ? 1.0 : 0.85)
  }
}