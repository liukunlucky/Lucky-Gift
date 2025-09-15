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
    
    // 联系人统计
    this.calculateTopContacts(yearEvents);
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
        
        Text('送礼统计')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 年份选择
        Text(`${this.selectedYear}年`)
          .fontSize(14)
          .fontColor('#FF6B35')
          .onClick(() => {
            // 这里可以添加年份选择器
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
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
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Column() {
          // Tab切换
          Row() {
            ForEach(['overview', 'monthly', 'category', 'contacts'], (tab: string) => {
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
              } else if (this.selectedTab === 'contacts') {
                this.buildContactsContent()
              }
            }
            .width('100%')
            .padding({ bottom: 20 })
          }
          .layoutWeight(1)
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
      // 总览卡片
      Row() {
        Column() {
          Text(this.totalGifts.toString())
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
          Text(`¥${this.formatAmount(this.totalAmount)}`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#32CD32')
          
          Text('总花费')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        
        Column() {
          Text(`¥${this.formatAmount(this.averageAmount)}`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFA500')
          
          Text('平均花费')
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
      .margin({ top: 16, left: 16, right: 16 })
      
      // 月度趋势预览
      Column() {
        Row() {
          Text('月度趋势')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          
          Blank()
          
          Text('查看详情')
            .fontSize(12)
            .fontColor('#FF6B35')
            .onClick(() => {
              this.selectedTab = 'monthly';
            })
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
          
          Blank()
          
          Text('查看详情')
            .fontSize(12)
            .fontColor('#FF6B35')
            .onClick(() => {
              this.selectedTab = 'category';
            })
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
        Text('月度送礼统计')
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
        Text('送礼对象排行')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)
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
              
              Text(`${item.giftCount}次送礼`)
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
}