import router from '@ohos.router';
import { GiftEvent, Contact } from '../../model/NewDataModels';
import { GiftEventDAO } from '../../database/GiftEventDAO';
import { ContactDAO } from '../../database/ContactDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';

@Component
export struct RecordPage {
  @State giftEvents: GiftEvent[] = [];
  @State filteredEvents: GiftEvent[] = [];
  @State selectedYear: number = new Date().getFullYear();
  @State selectedContact: string = '';
  @State isLoading: boolean = true;
  @State showFilterDialog: boolean = false;
  
  private dbManager = new NewDatabaseManager();
  private giftEventDAO: GiftEventDAO = new GiftEventDAO(this.dbManager);
  private contactDAO: ContactDAO = new ContactDAO(this.dbManager);
  private availableYears: number[] = [];
  private contacts: Contact[] = [];

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    try {
      this.isLoading = true;
      
      // 加载礼物事件
      this.giftEvents = await this.giftEventDAO.getAllGiftEvents();
      
      // 如果没有数据，显示示例数据
      if (this.giftEvents.length === 0) {
        this.giftEvents = this.getMockGiftEvents();
      }
      
      // 加载联系人
      this.contacts = await this.contactDAO.getAllContacts();
      
      // 生成可用年份列表
      this.generateAvailableYears();
      
      // 应用筛选
      this.applyFilters();
    } catch (error) {
      console.error('加载数据失败:', error);
      this.giftEvents = this.getMockGiftEvents();
      this.generateAvailableYears();
      this.applyFilters();
    } finally {
      this.isLoading = false;
    }
  }

  // 获取示例数据
  getMockGiftEvents(): GiftEvent[] {
    return [
      {
        id: '1',
        contactId: 'mom',
        contactName: '妈妈',
        occasion: '生日',
        giftIdea: '手工编织围巾',
        actualGift: '羊绒围巾 + 手写贺卡',
        budget: 300,
        actualCost: 280,
        date: '2024-03-15',
        story: '妈妈收到围巾时眼中含泪，说这是她收到过最温暖的礼物。她立刻就戴上了，说颜色正好配她的外套。',
        reaction: '非常感动，当场就哭了',
        mood: 'joyful',
        images: ['/common/images/scarf_gift.jpg'],
        tags: ['温暖', '手工', '实用'],
        reminderSet: true,
        reminderDate: '2025-03-15',
        createdAt: '2024-03-15T10:30:00Z',
        updatedAt: '2024-03-15T10:30:00Z'
      },
      {
        id: '2',
        contactId: 'boyfriend',
        contactName: '男朋友',
        occasion: '纪念日',
        giftIdea: '定制相册',
        actualGift: '我们的回忆相册 + 情侣手表',
        budget: 500,
        actualCost: 480,
        date: '2024-02-14',
        story: '翻看相册时我们一起回忆了很多美好时光，他说要把相册放在床头，每天都能看到我们的回忆。手表也很合适，我们约定要一起戴。',
        reaction: '很惊喜，抱了我很久',
        mood: 'romantic',
        images: ['/common/images/album_gift.jpg'],
        tags: ['浪漫', '回忆', '定制'],
        reminderSet: true,
        reminderDate: '2025-02-14',
        createdAt: '2024-02-14T20:00:00Z',
        updatedAt: '2024-02-14T20:00:00Z'
      },
      {
        id: '3',
        contactId: 'bestfriend',
        contactName: '闺蜜小雨',
        occasion: '毕业',
        giftIdea: '护肤套装',
        actualGift: '高端护肤套装 + 毕业祝福卡',
        budget: 800,
        actualCost: 750,
        date: '2024-06-20',
        story: '她一直想试这个牌子的护肤品但舍不得买。收到礼物时她说我太了解她了，我们约定要一起变美变优秀。',
        reaction: '开心到跳起来',
        mood: 'excited',
        images: ['/common/images/skincare_gift.jpg'],
        tags: ['美容', '友谊', '毕业'],
        reminderSet: false,
        createdAt: '2024-06-20T15:00:00Z',
        updatedAt: '2024-06-20T15:00:00Z'
      }
    ];
  }

  // 生成可用年份
  generateAvailableYears() {
    const years = new Set<number>();
    this.giftEvents.forEach(event => {
      const year = new Date(event.date).getFullYear();
      years.add(year);
    });
    this.availableYears = Array.from(years).sort((a, b) => b - a);
    
    if (this.availableYears.length === 0) {
      this.availableYears = [new Date().getFullYear()];
    }
  }

  // 应用筛选
  applyFilters() {
    let result = this.giftEvents;
    
    // 按年份筛选
    if (this.selectedYear) {
      result = result.filter(event => {
        const eventYear = new Date(event.date).getFullYear();
        return eventYear === this.selectedYear;
      });
    }
    
    // 按联系人筛选
    if (this.selectedContact) {
      result = result.filter(event => event.contactId === this.selectedContact);
    }
    
    // 按日期排序（最新的在前）
    result.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
    
    this.filteredEvents = result;
  }

  // 导航到创建记录页面
  navigateToCreateRecord() {
    router.pushUrl({
      url: 'pages/tabs/CreateGiftEventPage'
    });
  }

  // 导航到记录详情页面
  navigateToEventDetail(event: GiftEvent) {
    router.pushUrl({
      url: 'pages/tabs/CreateGiftEventPage',
      params: {
        eventId: event.id
      }
    });
  }

  // 格式化日期
  formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    return `${month}月${day}日`;
  }

  // 获取心情图标
  getMoodIcon(mood: string | undefined): Resource {
    switch (mood) {
      case 'joyful': return $r('app.media.icon_happy')
      case 'romantic': return $r('app.media.icon_lm')
      case 'excited': return $r('app.media.icon_xf')
      case 'grateful': return $r('app.media.icon_gj')
      case 'surprised': return $r('app.media.icon_jx')
      case 'touched': return $r('app.media.icon_gd')
      default: return $r('app.media.icon_happy')
    }
  }

  // 获取预算状态颜色
  getBudgetStatusColor(budget: number, actualCost: number): string {
    if (actualCost <= budget) {
      return '#4CAF50'; // 绿色 - 在预算内
    } else if (actualCost <= budget * 1.2) {
      return '#FF9800'; // 橙色 - 略超预算
    } else {
      return '#F44336'; // 红色 - 严重超预算
    }
  }

  build() {
    Column() {
      // 顶部工具栏
      Row() {
        Text('情感时间轴')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
        
        // 筛选按钮
        Row() {
           Image($r('app.media.icon_search'))
             .width(16)
             .height(16)
             .fillColor('#666666')
             .margin({ right: 4 })
           
           Text('筛选')
            .fontSize(14)
            .fontColor('#333333')
        }
        .height(32)
        .backgroundColor('#F0F0F0')
        .borderRadius(16)
        .margin({ right: 8 })
        .padding({ left: 12, right: 12 })
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.showFilterDialog = true;
        })
        
        // 添加按钮
        Button('+')
          .fontSize(20)
          .width(40)
          .height(40)
          .backgroundColor('#FF6B35')
          .fontColor(Color.White)
          .borderRadius(20)
          .onClick(() => {
            this.navigateToCreateRecord();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

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
        if (this.filteredEvents.length === 0) {
          // 空状态
          Column() {
            Image($r('app.media.icon_record'))
              .width(64)
              .height(64)
              .fillColor('#CCCCCC')
              .margin({ bottom: 20 })
            
            Text('还没有记录哦')
              .fontSize(18)
              .fontColor('#666666')
              .margin({ bottom: 12 })
            
            Text('点击右上角的 + 号开始记录你的送礼故事吧')
              .fontSize(14)
              .fontColor('#999999')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 32 })
              .padding({ left: 16, right: 16 })
            
            Button('开始记录')
              .backgroundColor('#FF6B35')
              .borderRadius(20)
              .onClick(() => {
                this.navigateToCreateRecord();
              })
          }
          .width('100%')
          .height('60%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .padding(32)
        } else {
          // 时间轴列表
          Scroll() {
            Column() {
              ForEach(this.filteredEvents, (event: GiftEvent, index: number) => {
                this.buildTimelineItem(event, index)
              })
              
              // 底部间距
              Column()
                .height(20)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 8 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
    .bindSheet($$this.showFilterDialog, this.buildFilterDialog(), {
      height: 400,
      dragBar: true
    })
  }

  @Builder
  buildTimelineItem(event: GiftEvent, index: number) {
    Row() {
      // 时间轴线条
      Column() {
        if (index === 0) {
          Column()
            .width(2)
            .height(20)
            .backgroundColor('#F0F0F0')
        } else {
          Column()
            .width(2)
            .height(20)
            .backgroundColor('#FF6B35')
        }
        
        // 时间轴节点
        Column()
          .width(12)
          .height(12)
          .backgroundColor('#FF6B35')
          .borderRadius(6)
          .border({ width: 3, color: Color.White })
        
        Column()
          .width(2)
          .height(20)
          .backgroundColor(index === this.filteredEvents.length - 1 ? '#F0F0F0' : '#FF6B35')
      }
      .width(20)
      .alignItems(HorizontalAlign.Center)
      
      // 事件卡片
      Column() {
        // 卡片头部
        Row() {
          Column() {
            Text(event.contactName)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
            
            Text(`${event.occasion} · ${this.formatDate(event.date)}`)
              .fontSize(12)
              .fontColor('#666666')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          
          Blank()
          Image(this.getMoodIcon(event.mood))
            .width(20)
            .height(20)
            .fillColor('#CCCCCC')
        }
        .width('100%')
        .margin({ bottom: 12 })
        
        // 礼物信息
        Column() {
          Text(event.actualGift || event.giftIdea)
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
          
          if (event.story) {
            Text(event.story)
              .fontSize(13)
              .fontColor('#666666')
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .lineHeight(18)
              .margin({ bottom: 12 })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        
        // 标签和预算
        Row() {
          // 标签
          if (event.tags && event.tags.length > 0) {
            ForEach(event.tags.slice(0, 2), (tag: string) => {
              Text(`#${tag}`)
                .fontSize(10)
                .fontColor('#FF6B35')
                .backgroundColor('#FFF0ED')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ right: 6 })
            })
          }
          
          Blank()
          
          // 预算信息
          Text(`¥${event.actualCost || event.budget}`)
            .fontSize(12)
            .fontColor(this.getBudgetStatusColor(event.budget, event.actualCost || event.budget))
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        
        // 提醒标识
        if (event.reminderSet) {
          Row() {
            Text('🔔')
              .fontSize(12)
            
            Text('已设置提醒')
              .fontSize(11)
              .fontColor('#666666')
              .margin({ left: 4 })
          }
          .margin({ top: 8 })
        }
      }
      .layoutWeight(1)
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ left: 12, bottom: 16 })
      .onClick(() => {
        this.navigateToEventDetail(event);
      })
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  buildFilterDialog() {
    Column() {
      Text('筛选条件')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 24 })
      
      // 年份筛选
      Column() {
        Text('年份')
          .fontSize(14)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })
        
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          Button('全部')
            .fontSize(12)
            .height(32)
            .backgroundColor(this.selectedYear === 0 ? '#FF6B35' : '#F0F0F0')
            .fontColor(this.selectedYear === 0 ? Color.White : '#333333')
            .borderRadius(16)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.selectedYear = 0;
              this.applyFilters();
            })
          
          ForEach(this.availableYears, (year: number) => {
            Button(year.toString())
              .fontSize(12)
              .height(32)
              .backgroundColor(this.selectedYear === year ? '#FF6B35' : '#F0F0F0')
              .fontColor(this.selectedYear === year ? Color.White : '#333333')
              .borderRadius(16)
              .margin({ right: 8, bottom: 8 })
              .onClick(() => {
                this.selectedYear = year;
                this.applyFilters();
              })
          })
        }
      }
      .width('100%')
      .margin({ bottom: 24 })
      
      // 联系人筛选
      Column() {
        Text('联系人')
          .fontSize(14)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })
        
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          Button('全部')
            .fontSize(12)
            .height(32)
            .backgroundColor(this.selectedContact === '' ? '#FF6B35' : '#F0F0F0')
            .fontColor(this.selectedContact === '' ? Color.White : '#333333')
            .borderRadius(16)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.selectedContact = '';
              this.applyFilters();
            })
          
          // 从事件中提取联系人
          ForEach(Array.from(new Set(this.giftEvents.map(e => e.contactName))), (contactName: string) => {
            Button(contactName)
              .fontSize(12)
              .height(32)
              .backgroundColor(this.selectedContact === contactName ? '#FF6B35' : '#F0F0F0')
              .fontColor(this.selectedContact === contactName ? Color.White : '#333333')
              .borderRadius(16)
              .margin({ right: 8, bottom: 8 })
              .onClick(() => {
                this.selectedContact = this.giftEvents.find(e => e.contactName === contactName)?.contactId || '';
                this.applyFilters();
              })
          })
        }
      }
      .width('100%')
      .margin({ bottom: 24 })
      
      // 操作按钮
      Row() {
        Button('重置')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .borderRadius(22)
          .margin({ right: 8 })
          .onClick(() => {
            this.selectedYear = new Date().getFullYear();
            this.selectedContact = '';
            this.applyFilters();
          })
        
        Button('确定')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#FF6B35')
          .fontColor(Color.White)
          .borderRadius(22)
          .margin({ left: 8 })
          .onClick(() => {
            this.showFilterDialog = false;
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
  }
}