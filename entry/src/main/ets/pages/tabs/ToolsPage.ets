import router from '@ohos.router';
import { BudgetCalculation, HolidayCountdown } from '../../model/NewDataModels';
import { ToolsDAO } from '../../database/ToolsDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';

// 轮播图内容接口
interface BannerItem {
  id: string;
  title: string;
  subtitle: string;
  description: string;
  backgroundColor: string;
  textColor: string;
  icon: string;
  actionText?: string;
  actionType?: string;
}

// 工具菜单接口
interface ToolMenu {
  id: string;
  title: string;
  description: string;
  icon: Resource;
  color: string;
}


// 礼物推荐接口
interface GiftRecommendation {
  id: string;
  title: string;
  category: string;
  priceRange: string;
  popularity: number;
  tags: string[];
}


@Component
export struct ToolsPage {
  @State bannerItems: BannerItem[] = [];
  @State giftRecommendations: GiftRecommendation[] = [];
  @State budgetCalculations: BudgetCalculation[] = [];
  @State upcomingHolidays: HolidayCountdown[] = [];
  @State isLoading: boolean = true;
  @State showBudgetCalculator: boolean = false;
  @State totalBudget: string = '';
  @State numberOfPeople: string = '';
  @State calculatedResult: number = 0;
  @State currentBannerIndex: number = 0;
  private dbManager = new NewDatabaseManager();
  private toolsDAO: ToolsDAO = new ToolsDAO(this.dbManager);
  // 工具菜单配置
  private toolMenus: ToolMenu[] = [
    {
      id: 'record',
      title: '快速记录',
      description: '记录送礼想法',
      icon: $r('app.media.icon_record'),
      color: '#4CAF50'
    },
    {
      id: 'reminder',
      title: '送礼提醒',
      description: '重要日期提醒',
      icon: $r('app.media.icon_rl'),
      color: '#2196F3'
    },
    {
      id: 'checklist',
      title: '礼物清单检查',
      description: '确保送礼万无一失',
      icon: $r('app.media.icon_check'),
      color: '#4CAF50'
    },
    {
      id: 'giftcard',
      title: '礼物卡制作器',
      description: '制作精美的礼物卡片',
      icon: $r('app.media.icon_hk'),
      color: '#E91E63'
    },
    {
      id: 'budget',
      title: '预算计算器',
      description: '合理分配送礼预算',
      icon: $r('app.media.icon_jsq'),
      color: '#FF9800'
    },
    {
      id: 'countdown',
      title: '节日倒计时',
      description: '不错过重要节日',
      icon: $r('app.media.icon_rl'),
      color: '#2196F3'
    }
  ];

  aboutToAppear() {
    this.loadData();
    // 加载轮播图数据
    this.bannerItems = this.getBannerItems();
    // 加载礼物推荐数据
    this.giftRecommendations = this.getGiftRecommendations();
    // 模拟加载完成
    setTimeout(() => {
      this.isLoading = false;
    }, 1000);
  }

  async loadData() {
    try {
      // 加载轮播图数据
      this.bannerItems = this.getBannerItems();
      // 加载礼物推荐数据
      this.giftRecommendations = this.getGiftRecommendations();
      // 加载预算计算数据
      this.budgetCalculations = await this.toolsDAO.getAllBudgetCalculations();
      // 加载节日倒计时数据
      this.upcomingHolidays = await this.toolsDAO.getUpcomingHolidays(30);
    } catch (error) {
      console.error('加载数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 获取轮播图数据
  getBannerItems(): BannerItem[] {
    return [
      {
        id: '1',
        title: '🎁 智能礼物推荐',
        subtitle: '让AI帮你选礼物',
        description: '基于收礼人的喜好和场合，为你推荐最合适的礼物',
        backgroundColor: '#FF6B35',
        textColor: '#FFFFFF',
        icon: '🤖',
        actionText: '立即体验',
        actionType: 'recommendation'
      },
      {
        id: '2',
        title: '💝 节日礼物指南',
        subtitle: '不同节日送什么',
        description: '情人节、生日、纪念日...每个节日都有专属推荐',
        backgroundColor: '#E91E63',
        textColor: '#FFFFFF',
        icon: '📅',
        actionText: '查看指南',
        actionType: 'guide'
      },
      {
        id: '3',
        title: '💰 预算优化助手',
        subtitle: '花最少的钱送最好的礼',
        description: '根据你的预算，找到性价比最高的礼物选择',
        backgroundColor: '#2196F3',
        textColor: '#FFFFFF',
        icon: '💡',
        actionText: '开始优化',
        actionType: 'budget'
      },
      {
        id: '4',
        title: '🎨 个性化定制',
        subtitle: '独一无二的心意',
        description: '定制专属礼物，让你的心意更加特别',
        backgroundColor: '#9C27B0',
        textColor: '#FFFFFF',
        icon: '✨',
        actionText: '开始定制',
        actionType: 'customize'
      }
    ];
  }

  // 获取礼物推荐数据
  getGiftRecommendations(): GiftRecommendation[] {
    return [
      {
        id: '1',
        title: '定制照片相册',
        category: '纪念品',
        priceRange: '50-200元',
        popularity: 95,
        tags: ['个性化', '纪念意义', '情侣']
      },
      {
        id: '2',
        title: '智能手表',
        category: '数码产品',
        priceRange: '500-2000元',
        popularity: 88,
        tags: ['实用', '科技', '健康']
      },
      {
        id: '3',
        title: '香薰蜡烛套装',
        category: '生活用品',
        priceRange: '80-300元',
        popularity: 92,
        tags: ['浪漫', '放松', '居家']
      },
      {
        id: '4',
        title: '手工巧克力',
        category: '美食',
        priceRange: '30-150元',
        popularity: 85,
        tags: ['甜蜜', '美味', '节日']
      }
    ];
  }

  // 计算预算
  calculateBudget() {
    const total = parseFloat(this.totalBudget);
    const people = parseInt(this.numberOfPeople);

    if (total > 0 && people > 0) {
      this.calculatedResult = total / people;
    } else {
      this.calculatedResult = 0;
    }
  }

  // 保存预算计算
  async saveBudgetCalculation() {
    if (this.calculatedResult > 0) {
      try {
        const calculation: BudgetCalculation = {
          id: "",
          name: `${this.numberOfPeople}人预算分配`,
          title: `${this.numberOfPeople}人预算分配`,
          totalBudget: parseFloat(this.totalBudget),
          numberOfPeople: parseInt(this.numberOfPeople),
          budgetPerPerson: this.calculatedResult,
          items: [],
          createdAt: ""
        };

        await this.toolsDAO.createBudgetCalculation(calculation);
        this.budgetCalculations = await this.toolsDAO.getAllBudgetCalculations();

        // 重置表单
        this.totalBudget = '';
        this.numberOfPeople = '';
        this.calculatedResult = 0;
        this.showBudgetCalculator = false;
      } catch (error) {
        console.error('保存预算计算失败:', error);
      }
    }
  }

  // 导航到工具页面
  navigateToTool(toolId: string) {
    switch (toolId) {
      case 'record':
        router.pushUrl({
          url: 'pages/tools/QuickRecordPage'
        });
        break;
      case 'reminder':
        router.pushUrl({
          url: 'pages/profile/GiftReminderPage'
        });
        break;
      case 'checklist':
        router.pushUrl({
          url: 'pages/tools/GiftChecklistPage'
        });
        break;
      case 'giftcard':
        router.pushUrl({
          url: 'pages/tools/GiftCardMakerPage'
        });
        break;
      case 'budget':
        router.pushUrl({
          url: 'pages/tools/BudgetCalculatorPage'
        });
        break;
      case 'countdown':
        router.pushUrl({
          url: 'pages/tools/HolidayCountdownPage'
        });
        break;
    }
  }

  navigateToGiftCardMaker() {
    router.pushUrl({
      url: 'pages/tools/GiftCardMakerPage'
    });
  }

  navigateToBudgetCalculator() {
    router.pushUrl({
      url: 'pages/tools/BudgetCalculatorPage'
    });
  }

  navigateToHolidayCountdown() {
    router.pushUrl({
      url: 'pages/tools/HolidayCountdownPage'
    });
  }

  // 格式化日期
  formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    return `${month}月${day}日`;
  }

  build() {
    Column() {
      // 顶部标题
      Row() {
        Text('工具百宝箱')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('让送礼更轻松')
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .padding({
        left: 20,
        right: 20,
        top: 16,
        bottom: 16
      })
      .backgroundColor(Color.White)

      // 可滚动内容区域
      Scroll() {
        Column() {
          if (this.isLoading) {
            // 加载状态
            Column() {
              LoadingProgress()
                .width(50)
                .height(50)
                .color('#FF6B35')

              Text('加载中...')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ top: 12 })
            }
            .width('100%')
            .height('60%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          } else {
            Column() {
              // 工具菜单
              Column() {
                Text('实用工具')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 20 })
                  .alignSelf(ItemAlign.Start)

                Grid() {
                  ForEach(this.toolMenus, (tool: ToolMenu) => {
                    GridItem() {
                      Column() {
                        Image(tool.icon)
                          .width(24)
                          .height(24)
                          .fillColor('#000000')
                        Blank().height(10)
                        Text(tool.title)
                          .fontSize(14)
                          .fontWeight(FontWeight.Medium)
                          .fontColor('#333333')
                          .margin({ bottom: 6 })
                        Text(tool.description)
                          .fontSize(11)
                          .fontColor('#666666')
                          .textAlign(TextAlign.Center)
                          .maxLines(2)
                      }
                      .width('100%')
                      .height(100)
                      .justifyContent(FlexAlign.Center)
                      .alignItems(HorizontalAlign.Center)
                      .backgroundColor(Color.White)
                      .borderRadius(12)
                      .border({ width: 1, color: '#F0F0F0' })
                      .onClick(() => {
                        this.navigateToTool(tool.id);
                      })
                    }
                  })
                }
                .columnsTemplate('1fr 1fr')
                .rowsGap(12)
                .columnsGap(12)
                .height(324)
              }
              .width('100%')
              .padding({
                left: 20,
                right: 20,
                top: 20,
                bottom: 20
              })
              .backgroundColor('#F8F9FA')
              .margin({ top: 12 })

              // 轮播图
              Column() {
                Swiper() {
                  ForEach(this.bannerItems, (banner: BannerItem) => {
                    Column() {
                      Row() {
                        Column() {
                          Text(banner.title)
                            .fontSize(18)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(banner.textColor)
                            .margin({ bottom: 4 })

                          Text(banner.subtitle)
                            .fontSize(14)
                            .fontColor(banner.textColor)
                            .opacity(0.9)
                            .margin({ bottom: 8 })

                          Text(banner.description)
                            .fontSize(12)
                            .fontColor(banner.textColor)
                            .opacity(0.8)
                            .maxLines(2)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .margin({ bottom: 12 })

                          if (banner.actionText) {
                            Text(banner.actionText)
                              .fontSize(12)
                              .height(32)
                              .backgroundColor(Color.White)
                              .fontColor(banner.backgroundColor)
                              .borderRadius(16)
                              .padding({
                                left: 16,
                                right: 16,
                                top: 6,
                                bottom: 6
                              })
                              .textAlign(TextAlign.Center)
                          }
                        }
                        .layoutWeight(1)
                        .alignItems(HorizontalAlign.Start)

                        Text(banner.icon)
                          .fontSize(48)
                          .margin({ left: 16 })
                      }
                      .width('100%')
                      .height('100%')
                      .padding(20)
                      .justifyContent(FlexAlign.SpaceBetween)
                      .alignItems(VerticalAlign.Center)
                    }
                    .width('100%')
                    .height(160)
                    .backgroundColor(banner.backgroundColor)
                    .borderRadius(12)
                    .onClick(() => {
                      this.handleBannerAction(banner.actionType || '');
                    })
                  })
                }
                .width('100%')
                .height(160)
                .autoPlay(true)
                .interval(4000)
                .indicator(true)
                .loop(true)
                .duration(300)
                .itemSpace(0)
                .indicatorStyle({
                  bottom: 12,
                  right: 12,
                  color: Color.White,
                  selectedColor: '#FFD700'
                })
                .onChange((index: number) => {
                  this.currentBannerIndex = index;
                })
              }
              .width('100%')
              .padding({top: 16, bottom: 16, left: 20, right: 20})
              .margin({ bottom: 8 })


              // 热门礼物推荐
              Column() {
                Row() {
                  Text('热门礼物推荐')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                }
                .width('100%')
                .margin({ bottom: 16 })

                ForEach(this.giftRecommendations, (gift: GiftRecommendation) => {
                  Row() {
                    Column() {
                      Text(gift.title)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                        .margin({ bottom: 4 })

                      Row() {
                        Text(gift.category)
                          .fontSize(12)
                          .fontColor('#666666')

                        Text('·')
                          .fontSize(12)
                          .fontColor('#CCCCCC')
                          .margin({ left: 8, right: 8 })

                        Text(gift.priceRange)
                          .fontSize(12)
                          .fontColor('#FF6B35')
                      }
                      .margin({ bottom: 8 })

                      Row() {
                        ForEach(gift.tags.slice(0, 3), (tag: string) => {
                          Text(tag)
                            .fontSize(10)
                            .fontColor('#666666')
                            .backgroundColor('#F0F0F0')
                            .borderRadius(8)
                            .padding({
                              left: 6,
                              right: 6,
                              top: 2,
                              bottom: 2
                            })
                            .margin({ right: 4 })
                        })
                      }
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)

                    Column() {
                      Text(`${gift.popularity}%`)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#FF6B35')

                      Text('热度')
                        .fontSize(10)
                        .fontColor('#666666')
                    }
                    .alignItems(HorizontalAlign.Center)
                  }
                  .width('100%')
                  .padding({ top: 12, bottom: 12 })
                  .border({ width: { bottom: 1 }, color: '#F0F0F0' })
                  .onClick(() => {
                    this.navigateToGiftDetail(gift.id);
                  })
                })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .margin({ bottom: 8 })

            }
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  // 处理轮播图动作
  private handleBannerAction(actionType: string): void {
    switch (actionType) {
      case 'recommendation':
        router.pushUrl({
          url: 'pages/tools/SmartRecommendationPage'
        });
        break;
      case 'guide':
        router.pushUrl({
          url: 'pages/tools/HolidayGuidePage'
        });
        break;
      case 'budget':
        router.pushUrl({
          url: 'pages/tools/BudgetCalculatorPage'
        });
        break;
      case 'customize':
        console.info('个性化定制');
        break;
      default:
        break;
    }
  }

  // 导航到推荐页面
  private navigateToRecommendations(): void {
    console.info('导航到推荐页面');
  }

  // 导航到礼物详情
  private navigateToGiftDetail(giftId: string): void {
    console.info('导航到礼物详情:', giftId);
  }
}