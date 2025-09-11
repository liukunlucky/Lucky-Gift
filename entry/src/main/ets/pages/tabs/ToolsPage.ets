import router from '@ohos.router';
import { BudgetCalculation, HolidayCountdown } from '../../model/NewDataModels';
import { ToolsDAO } from '../../database/ToolsDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';

// 清单项目接口
interface ChecklistItem {
  id: string;
  title: string;
  description?: string;
  isCompleted?: boolean;
  isChecked?: boolean;
  category: string;
  priority?: 'high' | 'medium' | 'low';
  createdAt: string;
  orderIndex?: number;
  isDefault?: boolean;
}

// 工具菜单接口
interface ToolMenu {
  id: string;
  title: string;
  description: string;
  icon: Resource;
  color: string;
}

@Component
export struct ToolsPage {
  @State checklistItems: ChecklistItem[] = [];
  @State budgetCalculations: BudgetCalculation[] = [];
  @State upcomingHolidays: HolidayCountdown[] = [];
  @State isLoading: boolean = true;
  @State showBudgetCalculator: boolean = false;
  @State showChecklistDetail: boolean = false;
  @State totalBudget: string = '';
  @State numberOfPeople: string = '';
  @State calculatedResult: number = 0;
  @State completedCount: number = 0;
  @State totalCount: number = 0;
  
  private dbManager = new NewDatabaseManager();
  private toolsDAO: ToolsDAO = new ToolsDAO(this.dbManager);
  
  // 工具菜单配置
  private toolMenus: ToolMenu[] = [
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
  }

  async loadData() {
    try {
      this.isLoading = true;
      
      // 加载检查清单（使用默认数据）
      this.checklistItems = this.getDefaultChecklistItems();
      
      // 加载预算计算记录
      this.budgetCalculations = await this.toolsDAO.getAllBudgetCalculations();
      
      // 加载即将到来的节日
      this.upcomingHolidays = await this.toolsDAO.getUpcomingHolidays(30);
      
      // 更新计数
      this.updateCounts();
    } catch (error) {
      console.error('加载工具数据失败:', error);
      this.checklistItems = this.getDefaultChecklistItems();
      this.upcomingHolidays = [];
      this.updateCounts();
    } finally {
      this.isLoading = false;
    }
  }

  // 获取默认检查清单
  getDefaultChecklistItems(): ChecklistItem[] {
    return [
      {
        id: '1',
        category: '准备阶段',
        title: '了解收礼人的喜好',
        description: '询问朋友或观察TA的兴趣爱好',
        orderIndex: 1,
        isDefault: true,
        createdAt: new Date().toISOString()
      },
      {
        id: '2',
        category: '准备阶段',
        title: '确定预算范围',
        description: '根据关系亲密度和经济能力设定预算',
        orderIndex: 2,
        isDefault: true,
        createdAt: new Date().toISOString()
      },
      {
        id: '3',
        category: '选择阶段',
        title: '选择合适的礼物',
        description: '结合喜好、预算和场合选择礼物',
        orderIndex: 3,
        isDefault: true,
        createdAt: new Date().toISOString()
      },
      {
        id: '4',
        category: '选择阶段',
        title: '考虑礼物的实用性',
        description: '确保礼物对收礼人有实际价值',
        orderIndex: 4,
        isDefault: true,
        createdAt: new Date().toISOString()
      },
      {
        id: '5',
        category: '购买阶段',
        title: '比较价格和质量',
        description: '在多个渠道对比，选择性价比最高的',
        orderIndex: 5,
        isDefault: true,
        createdAt: new Date().toISOString()
      },
      {
        id: '6',
        category: '包装阶段',
        title: '精心包装礼物',
        description: '选择合适的包装纸和装饰',
        orderIndex: 6,
        isDefault: true,
        createdAt: new Date().toISOString()
      },
      {
        id: '7',
        category: '包装阶段',
        title: '准备贺卡或祝福语',
        description: '写下真诚的祝福和心意',
        orderIndex: 7,
        isDefault: true,
        createdAt: new Date().toISOString()
      },
      {
        id: '8',
        category: '送礼阶段',
        title: '选择合适的送礼时机',
        description: '在合适的时间和场合送出礼物',
        orderIndex: 8,
        isDefault: true,
        createdAt: new Date().toISOString()
      }
    ];
  }

  // 更新计数
  updateCounts() {
    this.completedCount = this.checklistItems.filter(item => item.isChecked).length;
    this.totalCount = this.checklistItems.length;
  }

  // 切换检查清单项状态
  toggleChecklistItem(item: ChecklistItem) {
    // 更新本地状态
    const index = this.checklistItems.findIndex(i => i.id === item.id);
    if (index !== -1) {
      this.checklistItems[index].isChecked = !item.isChecked;
      this.updateCounts();
    }
  }

  // 重置检查清单
  resetChecklist() {
    this.checklistItems.forEach(item => {
      item.isChecked = false;
    });
    this.updateCounts();
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
      case 'checklist':
        this.showChecklistDetail = true;
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
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(Color.White)

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
        Scroll() {
          Column() {
            // 工具菜单
            Column() {
              Text('实用工具')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 16 })
                .alignSelf(ItemAlign.Start)
              
              Grid() {
                ForEach(this.toolMenus, (tool: ToolMenu) => {
                  GridItem() {
                    Column() {
                      Image(tool.icon)
                        .width(24)
                        .height(24)
                        .fillColor('#CCCCCC')
                      
                      Text(tool.title)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                        .margin({ bottom: 4 })
                      
                      Text(tool.description)
                        .fontSize(11)
                        .fontColor('#666666')
                        .textAlign(TextAlign.Center)
                        .maxLines(2)
                    }
                    .width('100%')
                    .height(120)
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
              .height(250)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#F8F9FA')
            .margin({ bottom: 8 })

            // 快速检查清单
            Column() {
              Row() {
                Text('送礼检查清单')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                
                Blank()
                
                Button('重置')
                  .fontSize(12)
                  .height(28)
                  .backgroundColor('#F0F0F0')
                  .fontColor('#666666')
                  .borderRadius(14)
                  .onClick(() => {
                    this.resetChecklist();
                  })
              }
              .width('100%')
              .margin({ bottom: 16 })
              
              // 进度条
              Row() {
                Progress({ 
                  value: this.completedCount, 
                  total: this.totalCount, 
                  type: ProgressType.Linear 
                })
                  .layoutWeight(1)
                  .color('#FF6B35')
                  .backgroundColor('#F0F0F0')
                  .height(6)
                
                Text(`${this.completedCount}/${this.totalCount}`)
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ left: 12 })
              }
              .width('100%')
              .margin({ bottom: 16 })
              
              // 检查清单项
              ForEach(this.checklistItems.slice(0, 5), (item: ChecklistItem) => {
                Row() {
                  Checkbox({ name: item.id, group: 'checklist' })
                    .select(item.isChecked)
                    .selectedColor('#FF6B35')
                    .onChange((value: boolean) => {
                      this.toggleChecklistItem(item);
                    })
                  
                  Column() {
                    Text(item.title)
                      .fontSize(14)
                      .fontColor(item.isChecked ? '#999999' : '#333333')
                      .decoration({ type: item.isChecked ? TextDecorationType.LineThrough : TextDecorationType.None })
                    
                    if (item.description) {
                      Text(item.description)
                        .fontSize(12)
                        .fontColor('#666666')
                        .margin({ top: 2 })
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 12 })
                }
                .width('100%')
                .padding({ top: 8, bottom: 8 })
                .alignItems(VerticalAlign.Top)
              })
              
              if (this.checklistItems.length > 5) {
                Button(`查看全部 ${this.checklistItems.length} 项`)
                  .fontSize(12)
                  .height(32)
                  .backgroundColor('#F0F0F0')
                  .fontColor('#666666')
                  .borderRadius(16)
                  .margin({ top: 8 })
                  .onClick(() => {
                    this.showChecklistDetail = true;
                  })
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .margin({ bottom: 8 })

            // 即将到来的节日
            if (this.upcomingHolidays.length > 0) {
              Column() {
                Text('即将到来的节日')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 16 })
                  .alignSelf(ItemAlign.Start)
                
                ForEach(this.upcomingHolidays.slice(0, 3), (holiday: HolidayCountdown) => {
                  Row() {
                    Column() {
                      Text(holiday.name)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                      
                      Text(this.formatDate(holiday.date))
                        .fontSize(12)
                        .fontColor('#666666')
                        .margin({ top: 2 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    
                    Blank()
                    
                    Column() {
                      Text(`${holiday.daysUntil || 0}`)
                        .fontSize(18)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#FF6B35')
                      
                      Text('天')
                        .fontSize(12)
                        .fontColor('#666666')
                    }
                    .alignItems(HorizontalAlign.Center)
                  }
                  .width('100%')
                  .padding({ top: 12, bottom: 12 })
                  .border({ width: { bottom: 1 }, color: '#F0F0F0' })
                })
                
                Button('查看更多节日')
                  .fontSize(12)
                  .height(32)
                  .backgroundColor('#F0F0F0')
                  .fontColor('#666666')
                  .borderRadius(16)
                  .margin({ top: 12 })
                  .onClick(() => {
                    this.navigateToTool('countdown');
                  })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .margin({ bottom: 8 })
            }

            // 最近的预算计算
            if (this.budgetCalculations.length > 0) {
              Column() {
                Text('最近的预算计算')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 16 })
                  .alignSelf(ItemAlign.Start)
                
                ForEach(this.budgetCalculations.slice(0, 3), (calculation: BudgetCalculation) => {
                  Row() {
                    Column() {
                      Text(calculation.title || '预算计算')
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                      
                      Text(`总预算 ¥${calculation.totalBudget} · ${calculation.numberOfPeople}人`)
                        .fontSize(12)
                        .fontColor('#666666')
                        .margin({ top: 2 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    
                    Blank()
                    
                    Text(`¥${calculation.budgetPerPerson?.toFixed(0)}/人`)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#FF6B35')
                  }
                  .width('100%')
                  .padding({ top: 12, bottom: 12 })
                  .border({ width: { bottom: 1 }, color: '#F0F0F0' })
                })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .margin({ bottom: 20 })
            }
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
    .bindSheet($$this.showBudgetCalculator, this.buildBudgetCalculatorDialog(), {
      height: 400,
      dragBar: true
    })
    .bindSheet($$this.showChecklistDetail, this.buildChecklistDetailDialog(), {
      height: 600,
      dragBar: true
    })
  }

  @Builder
  buildBudgetCalculatorDialog() {
    Column() {
      Text('预算计算器')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 24 })
      
      // 总预算输入
      Column() {
        Text('总预算（元）')
          .fontSize(14)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })
        
        TextInput({ placeholder: '请输入总预算金额' })
          .type(InputType.Number)
          .height(44)
          .borderRadius(8)
          .backgroundColor('#F8F9FA')
          .onChange((value: string) => {
            this.totalBudget = value;
            this.calculateBudget();
          })
      }
      .width('100%')
      .margin({ bottom: 16 })
      
      // 人数输入
      Column() {
        Text('人数')
          .fontSize(14)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })
        
        TextInput({ placeholder: '请输入人数' })
          .type(InputType.Number)
          .height(44)
          .borderRadius(8)
          .backgroundColor('#F8F9FA')
          .onChange((value: string) => {
            this.numberOfPeople = value;
            this.calculateBudget();
          })
      }
      .width('100%')
      .margin({ bottom: 24 })
      
      // 计算结果
      if (this.calculatedResult > 0) {
        Column() {
          Text('每人预算')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })
          
          Text(`¥${this.calculatedResult.toFixed(2)}`)
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B35')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFF0ED')
        .borderRadius(8)
        .margin({ bottom: 24 })
      }
      
      // 操作按钮
      Row() {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .borderRadius(22)
          .margin({ right: 8 })
          .onClick(() => {
            this.showBudgetCalculator = false;
            this.totalBudget = '';
            this.numberOfPeople = '';
            this.calculatedResult = 0;
          })
        
        Button('保存')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#FF6B35')
          .fontColor(Color.White)
          .borderRadius(22)
          .margin({ left: 8 })
          .enabled(this.calculatedResult > 0)
          .onClick(() => {
            this.saveBudgetCalculation();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
  }

  @Builder
  buildChecklistDetailDialog() {
    Column() {
      Text('送礼检查清单')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 16 })
      
      // 进度显示
      Row() {
        Progress({ 
          value: this.completedCount, 
          total: this.totalCount, 
          type: ProgressType.Linear 
        })
          .layoutWeight(1)
          .color('#FF6B35')
          .backgroundColor('#F0F0F0')
          .height(6)
        
        Text(`${this.completedCount}/${this.totalCount}`)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ left: 12 })
      }
      .width('100%')
      .margin({ bottom: 20 })
      
      // 完整检查清单
      Scroll() {
        Column() {
          ForEach(this.checklistItems, (item: ChecklistItem) => {
            Row() {
              Checkbox({ name: item.id, group: 'checklist' })
                .select(item.isChecked)
                .selectedColor('#FF6B35')
                .onChange((value: boolean) => {
                  this.toggleChecklistItem(item);
                })
              
              Column() {
                Text(item.title)
                  .fontSize(14)
                  .fontColor(item.isChecked ? '#999999' : '#333333')
                  .decoration({ type: item.isChecked ? TextDecorationType.LineThrough : TextDecorationType.None })
                
                if (item.description) {
                  Text(item.description)
                    .fontSize(12)
                    .fontColor('#666666')
                    .margin({ top: 2 })
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            .alignItems(VerticalAlign.Top)
            .onClick(() => {
              this.toggleChecklistItem(item);
            })
          })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      
      // 操作按钮
      Row() {
        Button('重置清单')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .borderRadius(22)
          .margin({ right: 8 })
          .onClick(() => {
            this.resetChecklist();
          })
        
        Button('完成')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#FF6B35')
          .fontColor(Color.White)
          .borderRadius(22)
          .margin({ left: 8 })
          .onClick(() => {
            this.showChecklistDetail = false;
          })
      }
      .width('100%')
      .margin({ top: 16 })
    }
    .width('100%')
    .padding(24)
  }
}