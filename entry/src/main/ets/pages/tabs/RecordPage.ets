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
  @State isShowingMockData: boolean = false;
  
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
        this.isShowingMockData = true;
        console.log('记录页面：显示示例数据');
      } else {
        this.isShowingMockData = false;
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
      this.isShowingMockData = true;
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

  // 格式化时间轴显示的日期（年月日）
  formatTimelineDate(dateStr: string): string {
    const date = new Date(dateStr);
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    return `${year}年\n${month}月${day}日`;
  }

  // 格式化时间轴显示的时间（时分）
  formatTimelineTime(dateStr: string): string {
    const date = new Date(dateStr);
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  // 检查是否为同一天
  isSameDay(date1: string, date2: string): boolean {
    const d1 = new Date(date1);
    const d2 = new Date(date2);
    return d1.getFullYear() === d2.getFullYear() &&
           d1.getMonth() === d2.getMonth() &&
           d1.getDate() === d2.getDate();
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

  // 获取记录类型背景颜色
  private getRecordTypeColor(recordType: string | undefined): string {
    if (recordType === 'give') {
      return '#F8F9FA'; // 橙色 - 送礼
    } else if (recordType === 'receive') {
      return '#F8F9FA'; // 绿色 - 收礼
    }
    return '#F8F9FA'; // 默认橙色
  }

  // 获取联系人标签文本
  private getContactLabel(recordType: string | undefined): string {
    if (recordType === 'give') {
      return '收礼人：';
    } else if (recordType === 'receive') {
      return '送礼人：';
    }
    return '收礼人：'; // 默认
  }

  // 获取时间标签文本
  private getTimeLabel(recordType: string | undefined): string {
    if (recordType === 'give') {
      return '送礼时间：';
    } else if (recordType === 'receive') {
      return '收礼时间：';
    }
    return '送礼时间：'; // 默认
  }

  // 获取场合标签文本
  private getOccasionLabel(recordType: string | undefined): string {
    if (recordType === 'give') {
      return '送礼场合：';
    } else if (recordType === 'receive') {
      return '收礼场合：';
    }
    return '送礼场合：'; // 默认
  }

  // 获取心情标签文本
  private getMoodLabel(recordType: string | undefined): string {
    if (recordType === 'give') {
      return '对方反应：';
    } else if (recordType === 'receive') {
      return '我的心情：';
    }
    return '对方心情：'; // 默认
  }

  // 获取心情字段值
  private getMoodValue(event: GiftEvent): string | undefined {
    if (event.recordType === 'give') {
      return event.reaction; // 送礼时显示对方反应
    } else if (event.recordType === 'receive') {
      return event.mood; // 收礼时显示我的心情
    }
    return event.mood; // 默认
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
        Blank().width(40)
        Text('礼物记录')
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
            Image($r('app.media.icon_empty'))
              .width(173)
              .height(128)
              .margin({ bottom: 20, top: 100 })
            
            Text('还没有记录哦')
              .fontSize(18)
              .fontColor('#666666')
              .margin({ bottom: 12 })
            
            Text('开始记录你的送礼故事吧')
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
              // 示例数据提醒
              if (this.isShowingMockData) {
                Row() {
                  Image($r('app.media.icon_gift'))
                    .width(16)
                    .height(16)
                    .fillColor('#FF6B35')
                    .margin({ right: 8 })

                  Text('当前显示的是示例数据，开始记录你的真实送礼故事吧！')
                    .fontSize(11)
                    .fontColor('#FF6B35')
                    .layoutWeight(1)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                }
                .width('100%')
                .padding(12)
                .backgroundColor('#FFF5F3')
                .borderRadius(8)
                .border({ width: 1, color: '#FFE0D6' })
                .margin({ bottom: 12 })
              }
              
              ForEach(this.filteredEvents, (event: GiftEvent, index: number) => {
                this.buildTimelineItem(event, index)
              })
              
              // 底部间距
              Column()
                .height(20)
            }
            .width('100%')
            .padding({ left: 12, right: 12, top: 8 })
          }
          .scrollBar(BarState.Off)
          .padding({ left: 12, right: 12, top: 16, bottom: 76 })
          .edgeEffect(EdgeEffect.Spring)
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
    .bindSheet($$this.showFilterDialog, this.buildFilterDialog(), {
      height: 400,
      dragBar: true,
      preferType:SheetType.CENTER
    })
  }

  @Builder
  buildTimelineItem(event: GiftEvent, index: number) {
    Row() {
      // 时间轴区域 - 包含时间信息
      Column() {
        // 时间显示区域
        Column() {
          // 检查是否需要显示日期（第一个或与前一个不是同一天）
          if (index === 0 || !this.isSameDay(event.date, this.filteredEvents[index - 1].date)) {
            Column() {
              Text(this.formatTimelineDate(event.date))
                .fontSize(9)
                .fontColor('#666666')
                .fontWeight(FontWeight.Normal)
                .textAlign(TextAlign.Center)
                .lineHeight(12)
            }
            .backgroundColor('#F5F5F5')
            .borderRadius(6)
            .padding({ left: 4, right: 4, top: 3, bottom: 3 })
            .margin({ bottom: 8 })
          }
        }
        .width(50)
        .alignItems(HorizontalAlign.Center)
        
        // 时间轴线条和节点
         Column() {
           // 上方连接线
           if (index === 0) {
             Column()
               .width(3)
               .height(20)
               .linearGradient({
                 angle: 180,
                 colors: [['#F0F0F0', 0.0], ['#E0E0E0', 1.0]]
               })
               .borderRadius(1.5)
           } else {
             Column()
               .width(3)
               .height(20)
               .linearGradient({
                 angle: 180,
                 colors: [['#FF6B35', 0.0], ['#FF8A65', 1.0]]
               })
               .borderRadius(1.5)
           }
           
           // 时间轴节点
           Column()
             .width(16)
             .height(16)
             .linearGradient({
               angle: 135,
               colors: [['#FF6B35', 0.0], ['#FF8A65', 1.0]]
             })
             .borderRadius(8)
             .border({ width: 3, color: Color.White })
             .shadow({
               radius: 6,
               color: '#40FF6B35',
               offsetX: 0,
               offsetY: 2
             })
           
           // 下方连接线
           Column()
             .width(3)
             .height(20)
             .linearGradient({
               angle: 180,
               colors: index === this.filteredEvents.length - 1 ? 
                 [['#E0E0E0', 0.0], ['#F0F0F0', 1.0]] :
                 [['#FF8A65', 0.0], ['#FF6B35', 1.0]]
             })
             .borderRadius(1.5)
         }
        .alignItems(HorizontalAlign.Center)
      }
      .width(60)
      .alignItems(HorizontalAlign.Center)
      
      // 重新设计的事件卡片 - 清晰展示所有信息
      Stack() {
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
          // 联系人信息
          Row() {
            Text(this.getContactLabel(event.recordType))
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
          
          // 时间信息
          Row() {
            Text(this.getTimeLabel(event.recordType))
              .fontSize(13)
              .fontColor('#666666')

            Text(this.formatDate(event.date))
              .fontSize(13)
              .fontColor('#1A1A1A')
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          
          // 心情显示
          Row() {
            Text(this.getMoodLabel(event.recordType))
              .fontSize(13)
              .fontColor('#666666')

            Row() {
              Image(this.getIconByMood(this.getMoodValue(event)))
                .width(16)
                .height(16)
                .fillColor(this.getMoodColor(this.getMoodValue(event)))
              
              Text(this.getMoodValue(event) || '未知')
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
          
          // 场合信息
          Row() {
            Text(this.getOccasionLabel(event.recordType))
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
                  .width(16)
                  .height(16)
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
        
        // 右上角角标
        this.buildRecordTypeBadge(event.recordType)
      }
      .layoutWeight(1)
      .borderWidth(1)
      .borderColor('#15000000')
      .backgroundColor(Color.White)
          .borderRadius(18)
          .margin({ left: 8, bottom: 18 })
          .shadow({
            radius: 12,
            color: '#15000000',
            offsetX: 0,
            offsetY: 4
          })
      .linearGradient({
          angle: 135,
          colors: [[this.getRecordTypeColor(event.recordType), 0.0], ['#F8F9FA', 1.0]]
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

  // 构建记录类型角标
  @Builder
  buildRecordTypeBadge(recordType: string | undefined) {
    Column() {
      Text(recordType === 'give' ? '送礼' : '收礼')
        .fontSize(14)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
    }
    .width(40)
    .height(20)
    .backgroundColor(recordType === 'give' ? '#FF6B35' : '#34C759')
    .borderRadius({ topLeft: 0, topRight: 16, bottomLeft: 8, bottomRight: 0 })
    .justifyContent(FlexAlign.Center)
    .position({ x: '100%', y: 0 })
    .translate({ x: -40, y: 0 })
    .zIndex(10)
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