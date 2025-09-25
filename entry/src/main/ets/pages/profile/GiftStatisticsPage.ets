import router from '@ohos.router';
import { Contact, GiftEvent } from '../../model/NewDataModels';
import { ContactDAO } from '../../database/ContactDAO';
import { GiftEventDAO } from '../../database/GiftEventDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';
import { common } from '@kit.AbilityKit';

interface MonthlyData {
  month: string;
  count: number;
  amount: number;
}

interface CategoryData {
  category: string;
  count: number;
  amount: number;
  percentage: number;
}

interface TopContact {
  contact: Contact;
  giftCount: number;
  totalAmount: number;
}

interface ContactData {
  count: number;
  amount: number;
}

interface MonthlyDataItem {
  count: number;
  amount: number;
}

interface CategoryDataItem {
  category: string;
  count: number;
  amount: number;
  percentage: number;
}

interface TopContactItem {
  contact: Contact;
  giftCount: number;
  totalAmount: number;
}

interface CategoryMapData {
  count: number;
  amount: number;
}

@Entry
@Component
struct GiftStatisticsPage {
  @State giftEvents: GiftEvent[] = [];
  @State contacts: Contact[] = [];
  @State isLoading: boolean = true;
  @State selectedYear: number = new Date().getFullYear();
  @State selectedTab: string = 'overview'; // overview, monthly, category, contacts
  
  // 统计数据
  @State totalGifts: number = 0;
  @State totalAmount: number = 0;
  @State averageAmount: number = 0;
  @State monthlyData: MonthlyData[] = [];
  @State categoryData: CategoryData[] = [];
  @State topContacts: TopContact[] = [];
  
  // 分类统计数据
  @State giveEvents: number = 0;
  @State receiveEvents: number = 0;
  @State giveSpent: number = 0;
  @State receiveSpent: number = 0;
  @State availableYears: number[] = [];
  @State isUsingDemoData: boolean = false; // 标识是否使用示例数据
  
  private dbManager = new NewDatabaseManager();
  private contactDAO = new ContactDAO(this.dbManager);
  private giftEventDAO = new GiftEventDAO(this.dbManager);
  
  async aboutToAppear() {
    try {
      // 初始化数据库
      const context = getContext(this) as common.UIAbilityContext;
      await this.dbManager.initDatabase(context);
      
      // 加载数据
      await this.loadData();
    } catch (error) {
      console.error('页面初始化失败:', error);
      this.isLoading = false;
    }
  }
  
  async loadData() {
    try {
      this.isLoading = true;
      
      // 加载数据
      this.contacts = await this.contactDAO.getAllContacts();
      this.giftEvents = await this.giftEventDAO.getAllGiftEvents();
      
      // 加载分类统计数据
      const typeStats = await this.giftEventDAO.getGiftEventTypeStats();
      this.giveEvents = typeStats.giveEvents;
      this.receiveEvents = typeStats.receiveEvents;
      this.giveSpent = typeStats.giveSpent;
      this.receiveSpent = typeStats.receiveSpent;
      
      // 初始化可用年份
      this.initAvailableYears();
      
      // 检查是否需要使用示例数据
      if (this.giftEvents.length === 0) {
        this.generateDemoData();
        this.isUsingDemoData = true;
      }
      
      // 计算统计数据
      this.calculateStatistics();
      
    } catch (error) {
      console.error('加载统计数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  calculateStatistics() {
    // 筛选当前年份的数据
    const yearEvents = this.giftEvents.filter(event => {
      const eventYear = new Date(event.date).getFullYear();
      return eventYear === this.selectedYear;
    });
    
    // 基础统计
    this.totalGifts = yearEvents.length;
    this.totalAmount = yearEvents.reduce((sum, event) => sum + (event.actualCost || event.budget || 0), 0);
    this.averageAmount = this.totalGifts > 0 ? this.totalAmount / this.totalGifts : 0;
    
    // 月度统计
    this.calculateMonthlyData(yearEvents);
    
    // 分类统计
    this.calculateCategoryData(yearEvents);
    
    // 联系人统计 - 使用所有时间的数据
    this.calculateTopContacts(this.giftEvents);
  }
  
  calculateMonthlyData(events: GiftEvent[]) {
    const monthlyMap = new Map<number, MonthlyDataItem>();
    
    // 初始化12个月
    for (let i = 1; i <= 12; i++) {
      const monthlyItem: MonthlyDataItem = { count: 0, amount: 0 };
      monthlyMap.set(i, monthlyItem);
    }
    
    // 统计每月数据
    events.forEach(event => {
      const month = new Date(event.date).getMonth() + 1;
      const data = monthlyMap.get(month)!;
      data.count++;
      data.amount += event.actualCost || event.budget || 0;
    });
    
    // 转换为数组
    this.monthlyData = Array.from(monthlyMap.entries()).map((entry) => {
      const month = entry[0];
      const data = entry[1];
      const monthlyData: MonthlyData = {
        month: `${month}月`,
        count: data.count,
        amount: data.amount
      };
      return monthlyData;
    });
  }
  
  calculateCategoryData(events: GiftEvent[]) {
    const categoryMap = new Map<string, CategoryMapData>();
    
    events.forEach(event => {
      const category = event.occasion || '其他';
      if (!categoryMap.has(category)) {
        const categoryData: CategoryMapData = { count: 0, amount: 0 };
        categoryMap.set(category, categoryData);
      }
      const data = categoryMap.get(category)!;
      data.count++;
      data.amount += event.actualCost || event.budget || 0;
    });
    
    // 转换为数组并计算百分比
    this.categoryData = Array.from(categoryMap.entries())
      .map((entry) => {
        const category = entry[0];
        const data = entry[1];
        const categoryItem: CategoryDataItem = {
          category,
          count: data.count,
          amount: data.amount,
          percentage: this.totalAmount > 0 ? (data.amount / this.totalAmount) * 100 : 0
        };
        return categoryItem;
      })
      .sort((a, b) => b.amount - a.amount);
  }
  
  calculateTopContacts(events: GiftEvent[]) {
    const contactMap = new Map<string, ContactData>();
    
    events.forEach(event => {
      if (!contactMap.has(event.contactId)) {
        const contactData: ContactData = { count: 0, amount: 0 };
        contactMap.set(event.contactId, contactData);
      }
      const data = contactMap.get(event.contactId)!;
      data.count++;
      data.amount += event.actualCost || event.budget || 0;
    });
    
    // 转换为数组
    this.topContacts = Array.from(contactMap.entries())
      .map((entry) => {
        const contactId = entry[0];
        const data = entry[1];
        const contact = this.contacts.find(c => c.id === contactId);
        const topContactItem: TopContactItem = {
          contact: contact!,
          giftCount: data.count,
          totalAmount: data.amount
        };
        return topContactItem;
      })
      .filter(item => item.contact)
      .sort((a, b) => b.totalAmount - a.totalAmount)
      .slice(0, 10);
  }
  
  formatAmount(amount: number): string {
    if (amount >= 10000) {
      return (amount / 10000).toFixed(1) + '万';
    } else if (amount >= 1000) {
      return (amount / 1000).toFixed(1) + 'k';
    }
    return amount.toString();
  }
  
  getCategoryColor(index: number): string {
    const colors = ['#FF6B35', '#FFA500', '#32CD32', '#87CEEB', '#DDA0DD', '#F0E68C', '#FFB6C1', '#98FB98'];
    return colors[index % colors.length];
  }
  
  getMaxMonthlyAmount(): number {
    return Math.max(...this.monthlyData.map(d => d.amount), 1);
  }

  goBack() {
    router.back();
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
          this.goBack()
        })
        
        Text('礼物统计')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 占位空间，保持布局平衡
        Row()
          .width(40)
          .height(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      
      // 示例数据提示条
      if (this.isUsingDemoData) {
        Row() {
          Image($r('app.media.ic_info'))
            .width(16)
            .height(16)
            .fillColor('#FF6B35')
            .margin({ right: 8 })
          
          Text('当前显示的是演示数据，开始记录您的送礼故事吧！')
            .fontSize(12)
            .fontColor('#FF6B35')
            .layoutWeight(1)
          
          Text('了解')
            .fontSize(12)
            .fontColor('#FF6B35')
            .fontWeight(FontWeight.Medium)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#FFF8F5')
            .borderRadius(4)
            .onClick(() => {
              // 可以跳转到帮助页面或关闭提示
              this.isUsingDemoData = false;
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor('#FFF8F5')
        .border({ width: { bottom: 1 }, color: '#FFE4D6' })
      }
       
       // 加载状态
       if (this.isLoading) {
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
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Column() {
          // Tab切换
          Row() {
            ForEach(['overview', 'monthly', 'category'], (tab: string) => {
              Text(this.getTabName(tab))
                .fontSize(14)
                .fontColor(this.selectedTab === tab ? Color.White : '#666666')
                .backgroundColor(this.selectedTab === tab ? '#FF6B35' : '#F0F0F0')
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .borderRadius(16)
                .margin({ right: 8 })
                .onClick(() => {
                  this.selectedTab = tab;
                })
            }, (tab: string) => tab)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })
          
          // 内容区域
          Scroll() {
            Column() {
              if (this.selectedTab === 'overview') {
                this.buildOverviewContent()
              } else if (this.selectedTab === 'monthly') {
                this.buildMonthlyContent()
              } else if (this.selectedTab === 'category') {
                this.buildCategoryContent()
              }
            }
            .width('100%')
            .padding({ bottom: 20 })
          }
          .scrollBar(BarState.Off)
          .margin({ top: 8 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
  
  @Builder
  buildOverviewContent() {
    Column() {
      // 年份选择器
      Row() {
        Text('统计年份')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        
        Blank()
        
        Select(this.availableYears.map(year => {
          const option: SelectOption = { value: year.toString() };
          return option;
        }))
          .selected(this.availableYears.findIndex(year => year === this.selectedYear))
          .value(`${this.selectedYear}年`)
          .font({ size: 16, weight: FontWeight.Medium })
          .fontColor('#FF6B35')
          .selectedOptionFont({ size: 16, weight: FontWeight.Medium })
          .optionFont({ size: 16, weight: FontWeight.Normal })
          .backgroundColor('#FFF8F5')
          .borderRadius(8)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .onSelect((index: number) => {
            if (index >= 0 && index < this.availableYears.length) {
              this.selectedYear = this.availableYears[index];
              this.calculateStatistics();
            }
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
      
      // 总览卡片
      Row() {
        Column() {
          Text(this.giveEvents.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B35')
          
          Text('送礼次数')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        
        Column() {
          Text(this.receiveEvents.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#32CD32')
          
          Text('收礼次数')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        
        Column() {
          Text(`¥${this.formatAmount(this.giveSpent)}`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFA500')
          
          Text('总花费金额')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 8, left: 16, right: 16 })
      
      // 月度趋势预览
      Column() {
        Row() {
          Text('月度趋势')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

        }
        .width('100%')
        .margin({ bottom: 16 })
        
        // 简化的月度图表
        Row() {
          ForEach(this.monthlyData.slice(0, 6), (data: MonthlyData, index: number) => {
            Column() {
              Column()
                .width(20)
                .height(Math.max(data.amount / this.getMaxMonthlyAmount() * 60, 2))
                .backgroundColor('#FF6B35')
                .borderRadius(2)
              
              Text(data.month.replace('月', ''))
                .fontSize(10)
                .fontColor('#666666')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          })
        }
        .width('100%')
        .height(80)
        .alignItems(VerticalAlign.Bottom)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 8, left: 16, right: 16 })
      
      // 分类预览
      Column() {
        Row() {
          Text('分类统计')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .width('100%')
        .margin({ bottom: 16 })
        
        ForEach(this.categoryData.slice(0, 3), (data: CategoryData, index: number) => {
          Row() {
            Circle({ width: 8, height: 8 })
              .fill(this.getCategoryColor(index))
              .margin({ right: 8 })
            
            Text(data.category)
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)
            
            Text(`¥${this.formatAmount(data.amount)}`)
              .fontSize(14)
              .fontColor('#666666')
            
            Text(`${data.percentage.toFixed(1)}%`)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ left: 8 })
          }
          .width('100%')
          .margin({ bottom: 8 })
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 8, left: 16, right: 16 })
    }
  }
  
  @Builder
  buildMonthlyContent() {
    Column() {
      // 月度图表
      Column() {
        Text('月度礼物统计')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 16 })
        
        // 图表区域
        Column() {
          Row() {
            ForEach(this.monthlyData, (data: MonthlyData) => {
              Column() {
                Column()
                  .width(20)
                  .height(Math.max(data.amount / this.getMaxMonthlyAmount() * 120, 2))
                  .backgroundColor('#FF6B35')
                  .borderRadius(2)
                
                Text(data.month.replace('月', ''))
                  .fontSize(10)
                  .fontColor('#666666')
                  .margin({ top: 4 })
                
                Text(`¥${this.formatAmount(data.amount)}`)
                  .fontSize(8)
                  .fontColor('#999999')
                  .margin({ top: 2 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
            })
          }
          .width('100%')
          .height(150)
          .alignItems(VerticalAlign.Bottom)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#F8F9FA')
        .borderRadius(8)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 16, left: 16, right: 16 })
      
      // 月度详细数据
      Column() {
        Text('详细数据')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 16 })
        
        ForEach(this.monthlyData.filter(d => d.count > 0), (data: MonthlyData) => {
          Row() {
            Text(data.month)
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)
            
            Text(`${data.count}次`)
              .fontSize(14)
              .fontColor('#666666')
              .margin({ right: 16 })
            
            Text(`¥${this.formatAmount(data.amount)}`)
              .fontSize(14)
              .fontColor('#FF6B35')
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
          .borderRadius(8)
          .backgroundColor('#F8F9FA')
          .margin({ bottom: 4 })
          .padding({ left: 12, right: 12 })
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 8, left: 16, right: 16 })
    }
  }
  
  @Builder
  buildCategoryContent() {
    Column() {
      // 分类饼图（简化版）
      Column() {
        Text('分类占比')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 16 })
        
        ForEach(this.categoryData, (data: CategoryData, index: number) => {
          Column() {
            Row() {
              Circle({ width: 12, height: 12 })
                .fill(this.getCategoryColor(index))
                .margin({ right: 12 })
              
              Text(data.category)
                .fontSize(14)
                .fontColor('#333333')
                .layoutWeight(1)
              
              Text(`${data.count}次`)
                .fontSize(12)
                .fontColor('#666666')
                .margin({ right: 8 })
              
              Text(`¥${this.formatAmount(data.amount)}`)
                .fontSize(14)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
                .margin({ right: 8 })
              
              Text(`${data.percentage.toFixed(1)}%`)
                .fontSize(12)
                .fontColor('#FF6B35')
                .width(40)
                .textAlign(TextAlign.End)
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })
            
            // 进度条
            Progress({ value: data.percentage, total: 100, type: ProgressType.Linear })
              .width('100%')
              .height(4)
              .color(this.getCategoryColor(index))
              .backgroundColor('#F0F0F0')
              .margin({ top: 4 })
          }
          .width('100%')
          .margin({ bottom: 12 })
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 16, left: 16, right: 16 })
    }
  }
  
  @Builder
  buildContactsContent() {
    Column() {
      Column() {
        Row() {
          Text('礼物对象排行')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          
          Blank()
          
          Text('全部时间')
            .fontSize(12)
            .fontColor('#999999')
            .backgroundColor('#F5F5F5')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(10)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ bottom: 16 })
        
        ForEach(this.topContacts, (item: TopContact, index: number) => {
          Row() {
            // 排名
            Text(`${index + 1}`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(index < 3 ? '#FF6B35' : '#666666')
              .width(24)
              .textAlign(TextAlign.Center)
              .margin({ right: 12 })
            
            // 头像
            if (item.contact.avatar) {
              Text(item.contact.avatar)
                .fontSize(16)
                .width(40)
                .height(40)
                .borderRadius(20)
                .backgroundColor('#F0F0F0')
                .textAlign(TextAlign.Center)
            } else {
              Image($r('app.media.icon_mine'))
                .width(32)
                .height(32)
                .fillColor('#CCCCCC')
                .borderRadius(20)
                .backgroundColor('#F0F0F0')
            }
            
            // 联系人信息
            Column() {
              Text(item.contact.name)
                .fontSize(14)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
                .alignSelf(ItemAlign.Start)
              
              Text(`${item.giftCount}次礼物`)
                .fontSize(12)
                .fontColor('#666666')
                .alignSelf(ItemAlign.Start)
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })
            
            // 金额
            Text(`¥${this.formatAmount(item.totalAmount)}`)
              .fontSize(14)
              .fontColor('#FF6B35')
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(index < 3 ? '#FFF8F5' : Color.White)
          .borderRadius(8)
          .margin({ bottom: 8 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/profile/ContactFormPage',
              params: { contact: item.contact, isEdit: true }
            });
          })
        })
        
        if (this.topContacts.length === 0) {
          Column() {
            Image($r('app.media.ic_empty'))
              .width(60)
              .height(60)
              .fillColor('#CCCCCC')
            
            Text('暂无数据')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 12 })
          }
          .width('100%')
          .height(120)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 16, left: 16, right: 16 })
    }
  }
  
  getTabName(tab: string): string {
    switch (tab) {
      case 'overview': return '总览';
      case 'monthly': return '月度';
      case 'category': return '分类';
      case 'contacts': return '对象';
      default: return '总览';
    }
  }
  
  // 初始化可用年份
  initAvailableYears() {
    const currentYear = new Date().getFullYear();
    const years: number[] = [];
    
    // 获取数据中的年份范围
    const eventYears = this.giftEvents.map(event => new Date(event.date).getFullYear());
    const minYear = eventYears.length > 0 ? Math.min(...eventYears) : currentYear;
    const maxYear = Math.max(currentYear, eventYears.length > 0 ? Math.max(...eventYears) : currentYear);
    
    // 生成年份列表
    for (let year = maxYear; year >= minYear; year--) {
      years.push(year);
    }
    
    this.availableYears = years;
  }
  
  // 生成丰富的示例数据
  generateDemoData() {
    // 创建示例联系人
    const demoContacts: Contact[] = [
      { id: '1', name: '张小明', relationship: '朋友', avatar: '👨', birthday: '1990-05-15', importantDates: [], preferences: [], notes: '大学同学，喜欢运动', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
      { id: '2', name: '李美丽', relationship: '同事', avatar: '👩', birthday: '1988-08-20', importantDates: [], preferences: [], notes: '部门同事，爱好摄影', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
      { id: '3', name: '王大力', relationship: '家人', avatar: '👨‍💼', birthday: '1985-12-10', importantDates: [], preferences: [], notes: '表哥，在外地工作', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
      { id: '4', name: '陈小花', relationship: '朋友', avatar: '👧', birthday: '1992-03-25', importantDates: [], preferences: [], notes: '闺蜜，喜欢化妆品', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
      { id: '5', name: '刘老师', relationship: '老师', avatar: '👨‍🏫', birthday: '1975-07-08', importantDates: [], preferences: [], notes: '高中班主任', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
      { id: '6', name: '赵小雨', relationship: '家人', avatar: '👶', birthday: '2010-11-30', importantDates: [], preferences: [], notes: '小侄女，喜欢玩具', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() }
    ];
    
    // 创建示例礼物事件
    const currentYear = new Date().getFullYear();
    const demoGiftEvents: GiftEvent[] = [
      // 1月份
      { id: '1', contactId: '1', contactName: '张小明', recordType: 'give', giftIdea: '运动手表', actualGift: '运动手表', occasion: '生日', date: `${currentYear}-01-15`, budget: 800, actualCost: 750, images: [], story: '生日礼物，很实用', tags: [], reminderSet: false },
      { id: '2', contactId: '2', contactName: '李美丽', recordType: 'give', giftIdea: '相机镜头', actualGift: '相机镜头', occasion: '升职', date: `${currentYear}-01-28`, budget: 1200, actualCost: 1150, images: [], story: '升职庆祝', tags: [], reminderSet: false },
      
      // 2月份 - 春节
      { id: '3', contactId: '3', contactName: '王大力', recordType: 'give', giftIdea: '茶叶礼盒', actualGift: '茶叶礼盒', occasion: '春节', date: `${currentYear}-02-10`, budget: 300, actualCost: 280, images: [], story: '春节拜年', tags: [], reminderSet: false },
      { id: '4', contactId: '6', contactName: '赵小雨', recordType: 'give', giftIdea: '玩具机器人', actualGift: '玩具机器人', occasion: '春节', date: `${currentYear}-02-12`, budget: 200, actualCost: 180, images: [], story: '给小侄女的压岁钱', tags: [], reminderSet: false },
      { id: '5', contactId: '5', contactName: '刘老师', recordType: 'give', giftIdea: '保健品', actualGift: '保健品', occasion: '春节', date: `${currentYear}-02-14`, budget: 500, actualCost: 480, images: [], story: '给老师拜年', tags: [], reminderSet: false },
      
      // 3月份
      { id: '6', contactId: '4', contactName: '陈小花', recordType: 'give', giftIdea: '口红套装', actualGift: '口红套装', occasion: '妇女节', date: `${currentYear}-03-08`, budget: 400, actualCost: 380, images: [], story: '妇女节礼物', tags: [], reminderSet: false },
      { id: '7', contactId: '2', contactName: '李美丽', recordType: 'give', giftIdea: '鲜花', actualGift: '鲜花', occasion: '妇女节', date: `${currentYear}-03-08`, budget: 100, actualCost: 88, images: [], story: '同事间的小心意', tags: [], reminderSet: false },
      
      // 4月份
      { id: '8', contactId: '1', contactName: '张小明', recordType: 'give', giftIdea: '篮球鞋', actualGift: '篮球鞋', occasion: '友谊', date: `${currentYear}-04-20`, budget: 600, actualCost: 550, images: [], story: '一起打球用', tags: [], reminderSet: false },
      
      // 5月份
      { id: '9', contactId: '3', contactName: '王大力', recordType: 'give', giftIdea: '按摩椅垫', actualGift: '按摩椅垫', occasion: '母亲节', date: `${currentYear}-05-12`, budget: 800, actualCost: 750, images: [], story: '母亲节给婶婶', tags: [], reminderSet: false },
      { id: '10', contactId: '5', contactName: '刘老师', recordType: 'give', giftIdea: '书籍', actualGift: '书籍', occasion: '感谢', date: `${currentYear}-05-20`, budget: 150, actualCost: 120, images: [], story: '感谢老师的帮助', tags: [], reminderSet: false },
      
      // 6月份
      { id: '11', contactId: '6', contactName: '赵小雨', recordType: 'give', giftIdea: '儿童手表', actualGift: '儿童手表', occasion: '儿童节', date: `${currentYear}-06-01`, budget: 300, actualCost: 280, images: [], story: '儿童节礼物', tags: [], reminderSet: false },
      { id: '12', contactId: '4', contactName: '陈小花', recordType: 'give', giftIdea: '包包', actualGift: '包包', occasion: '友谊', date: `${currentYear}-06-15`, budget: 800, actualCost: 720, images: [], story: '闺蜜生日', tags: [], reminderSet: false },
      
      // 7月份
      { id: '13', contactId: '2', contactName: '李美丽', recordType: 'give', giftIdea: '旅行箱', actualGift: '旅行箱', occasion: '出差', date: `${currentYear}-07-10`, budget: 500, actualCost: 450, images: [], story: '出差用品', tags: [], reminderSet: false },
      
      // 8月份
      { id: '14', contactId: '1', contactName: '张小明', recordType: 'give', giftIdea: '健身器材', actualGift: '健身器材', occasion: '生日', date: `${currentYear}-08-05`, budget: 1000, actualCost: 950, images: [], story: '健身爱好者', tags: [], reminderSet: false },
      
      // 9月份
      { id: '15', contactId: '5', contactName: '刘老师', recordType: 'give', giftIdea: '钢笔', actualGift: '钢笔', occasion: '教师节', date: `${currentYear}-09-10`, budget: 200, actualCost: 180, images: [], story: '教师节感谢', tags: [], reminderSet: false },
      
      // 10月份
      { id: '16', contactId: '3', contactName: '王大力', recordType: 'give', giftIdea: '保温杯', actualGift: '保温杯', occasion: '关怀', date: `${currentYear}-10-15`, budget: 150, actualCost: 130, images: [], story: '天气转凉的关怀', tags: [], reminderSet: false },
      
      // 11月份
      { id: '17', contactId: '4', contactName: '陈小花', recordType: 'give', giftIdea: '护肤品套装', actualGift: '护肤品套装', occasion: '双十一', date: `${currentYear}-11-11`, budget: 600, actualCost: 480, images: [], story: '双十一优惠', tags: [], reminderSet: false },
      
      // 12月份
      { id: '18', contactId: '2', contactName: '李美丽', recordType: 'give', giftIdea: '围巾', actualGift: '围巾', occasion: '圣诞节', date: `${currentYear}-12-25`, budget: 200, actualCost: 180, images: [], story: '圣诞节礼物', tags: [], reminderSet: false },
      { id: '19', contactId: '6', contactName: '赵小雨', recordType: 'give', giftIdea: '故事书', actualGift: '故事书', occasion: '圣诞节', date: `${currentYear}-12-25`, budget: 80, actualCost: 70, images: [], story: '圣诞节给小朋友', tags: [], reminderSet: false },
      
      // 收到的礼物
      { id: '20', contactId: '1', contactName: '张小明', recordType: 'receive', giftIdea: '咖啡豆', actualGift: '咖啡豆', occasion: '感谢', date: `${currentYear}-03-15`, budget: 0, actualCost: 0, images: [], story: '朋友送的咖啡豆', tags: [], reminderSet: false },
      { id: '21', contactId: '4', contactName: '陈小花', recordType: 'receive', giftIdea: '手工饼干', actualGift: '手工饼干', occasion: '友谊', date: `${currentYear}-06-20`, budget: 0, actualCost: 0, images: [], story: '闺蜜亲手做的', tags: [], reminderSet: false },
      { id: '22', contactId: '3', contactName: '王大力', recordType: 'receive', giftIdea: '特产', actualGift: '特产', occasion: '出差', date: `${currentYear}-09-05`, budget: 0, actualCost: 0, images: [], story: '表哥出差带回来的', tags: [], reminderSet: false }
    ];
    
    // 设置示例数据
    this.contacts = demoContacts;
    this.giftEvents = demoGiftEvents;
    
    // 更新统计数据
    const giveEvents = demoGiftEvents.filter(event => event.recordType === 'give');
    const receiveEvents = demoGiftEvents.filter(event => event.recordType === 'receive');
    
    this.giveEvents = giveEvents.length;
    this.receiveEvents = receiveEvents.length;
    this.giveSpent = giveEvents.reduce((sum, event) => sum + (event.actualCost || 0), 0);
    this.receiveSpent = 0; // 收到的礼物不计算花费
  }

}