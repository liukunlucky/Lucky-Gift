import router from '@ohos.router';
import { GiftEvent, Contact } from '../../model/NewDataModels';
import { GiftEventDAO } from '../../database/GiftEventDAO';
import { ContactDAO } from '../../database/ContactDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';
import { MockData } from '../../data/MockData';

@Component
export struct RecordPage {
  @Prop @Watch('onRefreshKeyChanged') refreshKey: number = 0;
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

  async aboutToAppear() {
    // 确保数据库已初始化
    try {
      await this.dbManager.initDatabase(getContext(this));
      console.log('记录页面：数据库初始化成功');
    } catch (error) {
      console.error('记录页面：数据库初始化失败:', error);
    }
    
    this.loadData();
  }

  onRefreshKeyChanged() {
    console.log('记录页面：检测到刷新信号，重新加载数据...');
    this.loadData();
  }

  async loadData() {
    try {
      this.isLoading = true;
      console.log('记录页面：开始加载数据...');
      
      // 加载礼物事件
      this.giftEvents = await this.giftEventDAO.getAllGiftEvents();
      console.log('记录页面：加载到的事件数量:', this.giftEvents.length);
      
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
    return MockData.getMockGiftEvents();
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
        eventId: event.id,
        isEdit: true
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

  private getIconByMood(mood: string | undefined): Resource {
    if (mood==='开心') {
      return $r('app.media.icon_happy');
    }
    if (mood==='兴奋') {
      return $r('app.media.icon_xf');
    }
    if (mood==='感动') {
      return $r('app.media.icon_gd');
    }
    if (mood==='紧张') {
      return $r('app.media.icon_jz');
    }
    if (mood==='期待') {
      return $r('app.media.icon_qd');
    }
    if (mood==='满足') {
      return $r('app.media.icon_mz');
    }
    if (mood==='温暖') {
      return $r('app.media.icon_wn');
    }
    return $r('app.media.icon_other');
  }

  private getMoodColor(mood: string | undefined): string {
    if (mood==='开心') {
      return '#FFD60A'; // 黄色
    }
    if (mood==='兴奋') {
      return '#FF3B30'; // 红色
    }
    if (mood==='感动') {
      return '#FF9500'; // 橙色
    }
    if (mood==='紧张') {
      return '#5856D6'; // 紫色
    }
    if (mood==='期待') {
      return '#007AFF'; // 蓝色
    }
    if (mood==='满足') {
      return '#34C759'; // 绿色
    }
    if (mood==='温暖') {
      return '#FF2D92'; // 粉色
    }
    return '#FFD60A'; // 默认黄色
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
        Text('时间轴')
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
        .visibility(this.giftEvents.length > 0 ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => {
          this.showFilterDialog = true;
        })
        
        // 添加按钮
        Image($r('app.media.ic_add'))
          .width(36)
          .height(36)
          .fillColor('#FF6B35')
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
            .margin({ top: 100 })
          
          Text('加载中...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
      } else {
        if (this.filteredEvents.length === 0) {
          // 空状态
          Column() {
            Image($r('app.media.icon_record'))
              .width(64)
              .height(64)
              .fillColor('#CCCCCC')
              .margin({ bottom: 20, top: 100 })
            
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
          .layoutWeight(1)
          .justifyContent(FlexAlign.Start)
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
      
      // 重新设计的事件卡片 - 清晰展示所有信息
      Column() {
        // 卡片标题 - 礼物名称
        Text(event.actualGift || event.giftIdea)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ bottom: 12 })
        
        // 详细信息列表
        Column({ space: 8 }) {
          // 收礼人信息
          Row() {
            Text('收礼人：')
              .fontSize(13)
              .fontColor('#666666')

            Text(event.contactName)
              .fontSize(13)
              .fontColor('#1A1A1A')
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          
          // 送礼时间
          Row() {
            Text('送礼时间：')
              .fontSize(13)
              .fontColor('#666666')

            Text(this.formatDate(event.date))
              .fontSize(13)
              .fontColor('#1A1A1A')
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          
          // 对方心情
          Row() {
            Text('对方心情：')
              .fontSize(13)
              .fontColor('#666666')

            Row() {
              Image(this.getIconByMood(event.mood))
                .width(16)
                .height(16)
                .fillColor(this.getMoodColor(event.mood))
              
              Text(event.mood || '未知')
                .fontSize(13)
                .fontColor('#1A1A1A')
                .margin({ left: 6 })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          
          // 花费金额
          Row() {
            Text('花费金额：')
              .fontSize(13)
              .fontColor('#666666')

            Text(`${event.actualCost || event.budget}元`)
              .fontSize(13)
              .fontColor(this.getBudgetStatusColor(event.budget, event.actualCost || event.budget))
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          
          // 送礼场合
          Row() {
            Text('送礼场合：')
              .fontSize(13)
              .fontColor('#666666')

            Text(event.occasion)
              .fontSize(13)
              .fontColor('#FF6B35')
              .backgroundColor('#FFF0ED')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .borderRadius(6)
              .border({ width: 1, color: '#FFE0D6' })
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .margin({ bottom: 12 })
        
        // 图片展示（如果有）
        if (event.images && event.images.length > 0) {
          Image(event.images[0])
            .width('100%')
            .height(100)
            .objectFit(ImageFit.Cover)
            .borderRadius(8)
            .margin({ bottom: 12 })
        }
        
        // 故事描述（如果有）
        if (event.story) {
          Column() {
            Text('故事描述：')
              .fontSize(12)
              .fontColor('#666666')
              .width('100%')
              .textAlign(TextAlign.Start)
              .margin({ bottom: 4 })
            
            Text(event.story)
              .fontSize(12)
              .fontColor('#666666')
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .lineHeight(16)
              .width('100%')
              .textAlign(TextAlign.Start)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 12 })
        }
        
        // 卡片底部 - 标签和状态
        Row() {
          // 左侧：标签
          Row() {
            if (event.tags && event.tags.length > 0) {
              ForEach(event.tags.slice(0, 3), (tag: string, tagIndex: number) => {
                Text(`#${tag}`)
                  .fontSize(9)
                  .fontColor('#8E8E93')
                  .backgroundColor('#F2F2F7')
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .borderRadius(4)
                  .margin({ right: 4 })
              })
              
              if (event.tags.length > 3) {
                Text(`+${event.tags.length - 3}`)
                  .fontSize(9)
                  .fontColor('#8E8E93')
                  .backgroundColor('#F2F2F7')
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .borderRadius(4)
              }
            }
          }
          .layoutWeight(1)
          
          // 右侧：状态指示器
          Row() {
            // 提醒状态
            if (event.reminderSet) {
              Row() {
                Image($r('app.media.icon_ld'))
                  .width(24)
                  .height(24)
                Text('已设置提醒')
                  .fontSize(13)
                  .fontColor('#34C759')
                  .margin({ left: 2 })
              }
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
              .margin({ left: 4 })
            }
            
            // 完成状态指示器
            if (event.actualGift) {
              Text('✓')
                .fontSize(10)
                .fontColor(Color.White)
                .backgroundColor('#34C759')
                .width(16)
                .height(16)
                .borderRadius(8)
                .textAlign(TextAlign.Center)
                .margin({ left: 4 })
            }
          }.onClick(() => {
            this.navigateToGiftRemind(event);
          })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .margin({ left: 12, bottom: 16 })
      .shadow({
        radius: 8,
        color: '#1A000000',
        offsetX: 0,
        offsetY: 2
      })
      .linearGradient({
        angle: 135,
        colors: [[this.getMoodColor(event.mood) + '20', 0.0], ['#F8F9FA', 1.0]]
      })
      .onClick(() => {
        this.navigateToEventDetail(event);
      })
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  navigateToGiftRemind(_event: GiftEvent) {
    router.pushUrl({
      url: 'pages/profile/GiftReminderPage'
    });
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