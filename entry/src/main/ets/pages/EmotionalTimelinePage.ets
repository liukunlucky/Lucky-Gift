import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { TimelineEventDAO, TimelineEvent, EventType, EmotionLevel, RelationshipStats } from '../database/TimelineEventDAO';
import { NewDatabaseManager } from '../database/NewDatabaseManager';
import { Contact } from '../model/NewDataModels';
import { common } from '@kit.AbilityKit';
import { getRelationshipTypeName, RelationshipType } from '../model/RelationshipType';

@Entry
@Component
struct EmotionalTimelinePage {
  @State selectedContact: Contact | null = null;
  @State currentContactId: string = '';
  @State timelineEvents: TimelineEvent[] = [];
  @State filteredEvents: TimelineEvent[] = [];
  @State selectedEvent: TimelineEvent | null = null;
  @State showEventDetail: boolean = false;
  @State showAddEvent: boolean = false;
  @State showEditEvent: boolean = false;
  @State filterType: EventType | 'all' = 'all';
  @State sortBy: 'date' | 'emotion' = 'date';
  @State relationshipStats: RelationshipStats | null = null;
  @State searchKeyword: string = '';
  private dbManager: NewDatabaseManager = new NewDatabaseManager();
  private timelineDAO: TimelineEventDAO | null = null;

  // 新增事件表单
  @State newEventTitle: string = '';
  @State newEventDescription: string = '';
  @State newEventType: EventType = EventType.MEMORY;
  @State newEventDate: Date = new Date();
  @State newEventEmotion: EmotionLevel = EmotionLevel.MEDIUM;
  @State newEventMood: string = '';
  @State newEventLocation: string = '';
  @State newEventTags: string = '';
  @State newEventIsImportant: boolean = false;
  @State newEventWeather: string = '';
  @State newEventPhotos: string[] = [];

  async aboutToAppear() {
    // 从路由参数获取联系人对象
    const params = router.getParams() as Record<string, Object>;
    if (params?.selectedContact) {
      this.selectedContact = params.selectedContact as Contact;
      this.currentContactId = this.selectedContact.id;
    } else {
      // 如果没有选择联系人，返回联系人选择页面
      router.replaceUrl({
        url: 'pages/ContactSelectionPage'
      });
      return;
    }
    
    // 初始化数据库
    await this.initDatabase();
    
    // 加载数据
    await this.loadTimelineData();
  }

  async onPageShow() {
    // 加载数据
    await this.loadTimelineData();
  }

  async initDatabase() {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      await this.dbManager.initDatabase(context);
      this.timelineDAO = new TimelineEventDAO(this.dbManager);
    } catch (error) {
      console.error('初始化数据库失败:', error);
      promptAction.showToast({ message: '数据库初始化失败' });
    }
  }

  async loadTimelineData() {
    try {
      if (!this.timelineDAO) {
        console.error('TimelineDAO 未初始化');
        return;
      }
      
      this.timelineEvents = await this.timelineDAO.getTimelineEventsByContactId(this.currentContactId);
      this.calculateRelationshipStats();
      this.filterEvents();
    } catch (error) {
      console.error('加载时间轴数据失败:', error);
      promptAction.showToast({ message: '加载数据失败' });
    }
  }

  async calculateRelationshipStats() {
    try {
      if (!this.timelineDAO) {
        console.error('TimelineDAO 未初始化');
        return;
      }
      
      this.relationshipStats = await this.timelineDAO.getRelationshipStats(this.currentContactId);
    } catch (error) {
      console.error('计算关系统计失败:', error);
    }
  }

  filterEvents() {
    let filtered = this.timelineEvents;

    // 按类型过滤
    if (this.filterType !== 'all') {
      filtered = filtered.filter(event => event.type === this.filterType);
    }

    // 按关键词搜索
    if (this.searchKeyword) {
      filtered = filtered.filter(event => 
        event.title.includes(this.searchKeyword) ||
        event.description.includes(this.searchKeyword) ||
        event.tags.some(tag => tag.includes(this.searchKeyword))
      );
    }

    // 排序
    if (this.sortBy === 'date') {
      filtered.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
    } else {
      filtered.sort((a, b) => b.emotionLevel - a.emotionLevel);
    }

    this.filteredEvents = filtered;
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航
        this.buildHeader()

        // 关系统计卡片
        if (this.relationshipStats) {
          this.buildStatsCard()
        }

        // 搜索和过滤
        this.buildSearchAndFilter()

        // 时间轴
        this.buildTimeline()

      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8F9FA')

      // 事件详情弹窗
      if (this.showEventDetail && this.selectedEvent) {
        this.buildEventDetailDialog()
      }

      // 添加事件弹窗
      if (this.showAddEvent) {
        this.buildAddEventDialog()
      }

      // 编辑事件弹窗
      if (this.showEditEvent) {
        this.buildEditEventDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildHeader() {
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

      Column() {
        Text(this.selectedContact ? `${this.selectedContact.name}的时间轴` : '情感时间轴')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2C3E50')
          .textAlign(TextAlign.Center)
        
        if (this.selectedContact) {
          Text(getRelationshipTypeName(this.selectedContact.relationship as RelationshipType))
            .fontSize(12)
            .fontColor('#7F8C8D')
            .textAlign(TextAlign.Center)
            .margin({ top: 2 })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

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
        this.showAddEvent = true;
      })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: 1 })
  }

  @Builder
  buildStatsCard() {
    if (this.relationshipStats) {
      Column({ space: 16 }) {
        // 联系人信息
        Row({ space: 12 }) {
          Column({ space: 4 }) {
            Text(this.relationshipStats.contactName)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2C3E50')

            Text(`认识 ${this.relationshipStats.relationshipDuration} 天`)
              .fontSize(12)
              .fontColor('#7F8C8D')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          // 情感指数
          Column({ space: 4 }) {
            Text('情感指数')
              .fontSize(10)
              .fontColor('#7F8C8D')

            Text(this.relationshipStats.averageEmotion.toFixed(1))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getEmotionColor(this.relationshipStats.averageEmotion))
          }
          .alignItems(HorizontalAlign.Center)
        }

        // 统计数据
        Row() {
          this.buildTotalEventsItem()
          this.buildImportantEventsItem()
          this.buildGiftCountItem()
          this.buildConflictCountItem()
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ left: 16, right: 16, top: 16 })
      .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
    }
  }

  @Builder
  buildStatItem(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2C3E50')

      Text(label)
        .fontSize(10)
        .fontColor('#7F8C8D')
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildTotalEventsItem() {
    Column({ space: 4 }) {
      Text(this.relationshipStats?.totalEvents.toString() || '0')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2C3E50')

      Text('总事件')
        .fontSize(10)
        .fontColor('#7F8C8D')
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildImportantEventsItem() {
    Column({ space: 4 }) {
      Text(this.relationshipStats?.importantEvents.toString() || '0')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2C3E50')

      Text('重要事件')
        .fontSize(10)
        .fontColor('#7F8C8D')
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildGiftCountItem() {
    Column({ space: 4 }) {
      Text(this.relationshipStats?.giftCount.toString() || '0')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2C3E50')

      Text('送礼次数')
        .fontSize(10)
        .fontColor('#7F8C8D')
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildConflictCountItem() {
    Column({ space: 4 }) {
      Text(this.relationshipStats?.conflictCount.toString() || '0')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2C3E50')

      Text('矛盾次数')
        .fontSize(10)
        .fontColor('#7F8C8D')
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildSearchAndFilter() {
    Column({ space: 12 }) {
      // 搜索栏
      Row({ space: 8 }) {
        Image($r('app.media.icon_tools'))
          .width(16)
          .height(16)
          .fillColor('#7F8C8D')
          .visibility(Visibility.None)

        TextInput({ placeholder: '搜索事件...', text: this.searchKeyword })
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .placeholderColor('#CCCCCC')
          .border({ width: 0 })
          .fontSize(14)
          .onChange((value: string) => {
            this.searchKeyword = value;
            this.filterEvents();
          })
      }
      .height(36)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#F5F5F5')
      .borderRadius(18)

      // 过滤和排序
      Row({ space: 12 }) {
        // 事件类型过滤
        Scroll() {
          Row({ space: 8 }) {
            this.buildFilterChip('全部', this.filterType === 'all', () => {
              this.filterType = 'all';
              this.filterEvents();
            })
            this.buildFilterChip('相遇', this.filterType === EventType.MEET, () => {
              this.filterType = EventType.MEET;
              this.filterEvents();
            })
            this.buildFilterChip('礼物', this.filterType === EventType.GIFT, () => {
              this.filterType = EventType.GIFT;
              this.filterEvents();
            })
            this.buildFilterChip('里程碑', this.filterType === EventType.MILESTONE, () => {
              this.filterType = EventType.MILESTONE;
              this.filterEvents();
            })
            this.buildFilterChip('矛盾', this.filterType === EventType.CONFLICT, () => {
              this.filterType = EventType.CONFLICT;
              this.filterEvents();
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .layoutWeight(1)

        // 排序按钮
        Row({ space: 4 }) {
          Image($r('app.media.icon_tools'))
            .width(16)
            .height(16)
            .fillColor('#7F8C8D')

          Text(this.sortBy === 'date' ? '时间' : '情感')
            .fontSize(12)
            .fontColor('#7F8C8D')
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('#F5F5F5')
        .borderRadius(12)
        .onClick(() => {
          this.sortBy = this.sortBy === 'date' ? 'emotion' : 'date';
          this.filterEvents();
        })
      }.visibility(Visibility.None)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
  }

  @Builder
  buildFilterChip(text: string, isSelected: boolean, onTap: () => void) {
    Text(text)
      .fontSize(12)
      .fontColor(isSelected ? Color.White : '#7F8C8D')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(isSelected ? '#FF6B35' : '#F5F5F5')
      .borderRadius(16)
      .onClick(onTap)
  }

  @Builder
  buildTimeline() {
    if (this.filteredEvents.length === 0) {
      this.buildEmptyState()
    } else {
      List({ space: 0 }) {
        ForEach(this.filteredEvents, (event: TimelineEvent, index: number) => {
          ListItem() {
            this.buildTimelineItem(event, index === this.filteredEvents.length - 1)
          }
        }, (event: TimelineEvent) => event.id)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .padding({ left: 16, right: 16 })
    }
  }

  @Builder
  buildTimelineItem(event: TimelineEvent, isLast: boolean) {
    Row({ space: 16 }) {
      // 时间轴线
      Column() {
        // 事件点
        Stack() {
          Circle({ width: 12, height: 12 })
            .fill(this.getEventTypeColor(event.type))

          if (event.isImportant) {
            Circle({ width: 20, height: 20 })
              .stroke(this.getEventTypeColor(event.type))
              .strokeWidth(2)
              .fill(Color.Transparent)
          }
        }

        // 连接线
        if (!isLast) {
          Line()
            .width(2)
            .height(60)
            .stroke('#E0E0E0')
            .strokeWidth(2)
        }
      }
      .width(20)
      .alignItems(HorizontalAlign.Center)

      // 事件内容
      Column({ space: 8 }) {
        // 日期
        Text(this.formatDate(event.date))
          .fontSize(10)
          .fontColor('#95A5A6')

        // 事件卡片
        Column({ space: 12 }) {
          // 标题和类型
          Row() {
            Text(event.title)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2C3E50')
              .layoutWeight(1)

            Text(this.getEventTypeName(event.type))
              .fontSize(10)
              .fontColor(this.getEventTypeColor(event.type))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor(this.getEventTypeBgColor(event.type))
              .borderRadius(8)
          }

          // 描述
          Text(event.description)
            .fontSize(14)
            .fontColor('#7F8C8D')
            .lineHeight(18)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 情感和位置
          Row({ space: 12 }) {
            // 情感强度
            Row({ space: 4 }) {
              ForEach([1, 2, 3, 4, 5], (level: number) => {
                Image($r('app.media.icon_heart'))
                  .width(12)
                  .height(12)
                  .fillColor(level <= event.emotionLevel ? '#FF6B35' : '#E0E0E0')
              }, (level: number) => level.toString())
            }

            if (event.location) {
              Row({ space: 4 }) {
                Image($r('app.media.icon_tools'))
                  .width(12)
                  .height(12)
                  .fillColor('#95A5A6')

                Text(event.location)
                  .fontSize(10)
                  .fontColor('#95A5A6')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .layoutWeight(1)
            }
          }

          // 标签
          if (event.tags.length > 0) {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(event.tags, (tag: string) => {
                Text(`#${tag}`)
                  .fontSize(10)
                  .fontColor('#FF6B35')
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .backgroundColor('#FFF0ED')
                  .borderRadius(8)
              }, (tag: string) => tag)
            }
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
        .onClick(() => {
          this.selectedEvent = event;
          this.showEventDetail = true;
        })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: isLast ? 0 : 16 })
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  buildEmptyState() {
    Column({ space: 16 }) {
      Image($r('app.media.icon_tools'))
          .width(80)
          .height(80)
          .fillColor('#BDC3C7')

      Text('还没有记录任何事件')
        .fontSize(16)
        .fontColor('#7F8C8D')

      Text('点击右下角按钮开始记录你们的美好时光')
        .fontSize(14)
        .fontColor('#95A5A6')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildEventDetailDialog() {
    // 事件详情弹窗实现
    Column() {
      // 遮罩和详情内容
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#80000000')
          .onClick(() => {
            this.showEventDetail = false;
          })

        // 详情内容
        if (this.selectedEvent) {
          Column({ space: 20 }) {
            // 标题栏
            Row() {
              Text(this.selectedEvent.title)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2C3E50')
                .layoutWeight(1)

              Image($r('app.media.icon_close'))
            .width(24)
            .height(24)
            .fillColor('#7F8C8D')
                .onClick(() => {
                  this.showEventDetail = false;
                })
            }
            .width('100%')

            // 详细信息
            Scroll() {
              Column({ space: 16 }) {
                // 基本信息
                this.buildDetailItem('日期', this.selectedEvent.date)
                this.buildDetailItem('类型', this.getEventTypeName(this.selectedEvent.type))
                this.buildDetailItem('情感强度', `${this.selectedEvent.emotionLevel}/5`)
                if (this.selectedEvent.location) {
                  this.buildDetailItem('地点', this.selectedEvent.location)
                }
                if (this.selectedEvent.mood) {
                  this.buildDetailItem('心情', this.selectedEvent.mood)
                }
                this.buildDetailItem('描述', this.selectedEvent.description)
              }
            }
            .layoutWeight(1)

            // 操作按钮
            Row({ space: 12 }) {
              Button('编辑')
                .backgroundColor('#3498DB')
                .fontColor(Color.White)
                .layoutWeight(1)
                .onClick(() => {
                  this.showEventDetail = false;
                  this.prepareEditEvent();
                })

              Button('删除')
                .backgroundColor('#E74C3C')
                .fontColor(Color.White)
                .layoutWeight(1)
                .onClick(async () => {
                  await this.deleteEvent();
                })
            }
            .width('100%')
            .margin({ top: 16 })
          }
          .width('90%')
          .height('80%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }

  @Builder
  buildDetailItem(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#95A5A6')
        .alignSelf(ItemAlign.Start)

      Text(value)
        .fontSize(14)
        .fontColor('#2C3E50')
        .lineHeight(20)
        .alignSelf(ItemAlign.Start)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildAddEventDialog() {
    // 添加事件弹窗实现
    Column() {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#80000000')
          .onClick(() => {
            this.showAddEvent = false;
          })

        // 表单内容
        Column({ space: 16 }) {
          Text('添加新事件')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2C3E50')

          // 表单字段
          Scroll() {
            Column({ space: 12 }) {
              // 标题
              Column({ space: 4 }) {
                Text('事件标题')
                  .fontSize(12)
                  .fontColor('#7F8C8D')
                  .alignSelf(ItemAlign.Start)

                TextInput({ placeholder: '输入事件标题', text: this.newEventTitle })
                  .onChange((value: string) => {
                    this.newEventTitle = value;
                  })
              }

              // 事件类型
              Column({ space: 4 }) {
                Text('事件类型')
                  .fontSize(12)
                  .fontColor('#7F8C8D')
                  .alignSelf(ItemAlign.Start)

                Row({ space: 8 }) {
                  Text('相遇')
                    .fontSize(12)
                    .fontColor(this.newEventType === EventType.MEET ? Color.White : '#2C3E50')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.newEventType === EventType.MEET ? '#FF6B35' : '#F8F9FA')
                    .borderRadius(16)
                    .onClick(() => {
                      this.newEventType = EventType.MEET;
                    })
                  
                  Text('礼物')
                    .fontSize(12)
                    .fontColor(this.newEventType === EventType.GIFT ? Color.White : '#2C3E50')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.newEventType === EventType.GIFT ? '#FF6B35' : '#F8F9FA')
                    .borderRadius(16)
                    .onClick(() => {
                      this.newEventType = EventType.GIFT;
                    })
                  
                  Text('里程碑')
                    .fontSize(12)
                    .fontColor(this.newEventType === EventType.MILESTONE ? Color.White : '#2C3E50')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.newEventType === EventType.MILESTONE ? '#FF6B35' : '#F8F9FA')
                    .borderRadius(16)
                    .onClick(() => {
                      this.newEventType = EventType.MILESTONE;
                    })
                }
                
                Row({ space: 8 }) {
                  Text('矛盾')
                    .fontSize(12)
                    .fontColor(this.newEventType === EventType.CONFLICT ? Color.White : '#2C3E50')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.newEventType === EventType.CONFLICT ? '#FF6B35' : '#F8F9FA')
                    .borderRadius(16)
                    .onClick(() => {
                      this.newEventType = EventType.CONFLICT;
                    })
                  
                  Text('回忆')
                    .fontSize(12)
                    .fontColor(this.newEventType === EventType.MEMORY ? Color.White : '#2C3E50')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.newEventType === EventType.MEMORY ? '#FF6B35' : '#F8F9FA')
                    .borderRadius(16)
                    .onClick(() => {
                      this.newEventType = EventType.MEMORY;
                    })
                  
                  Text('朋友')
                    .fontSize(12)
                    .fontColor(this.newEventType === EventType.FRIEND ? Color.White : '#2C3E50')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.newEventType === EventType.FRIEND ? '#FF6B35' : '#F8F9FA')
                    .borderRadius(16)
                    .onClick(() => {
                      this.newEventType = EventType.FRIEND;
                    })
                }
              }

              // 日期
              Column({ space: 4 }) {
                Text('日期')
                  .fontSize(12)
                  .fontColor('#7F8C8D')
                  .alignSelf(ItemAlign.Start)

                DatePicker({
                  start: new Date('1970-1-1'),
                  end: new Date('2100-12-31'),
                  selected: this.newEventDate
                })
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                  .onDateChange((value: Date) => {
                    this.newEventDate = value;
                  })
              }

              // 情感强度
              Column({ space: 4 }) {
                Text(`情感强度: ${this.newEventEmotion}/10`)
                  .fontSize(12)
                  .fontColor('#7F8C8D')
                  .alignSelf(ItemAlign.Start)

                Slider({
                  value: this.newEventEmotion,
                  min: 1,
                  max: 10,
                  step: 1
                })
                  .trackColor('#E0E0E0')
                  .selectedColor('#FF6B35')
                  .onChange((value: number) => {
                    this.newEventEmotion = Math.round(value);
                  })
              }

              // 地点
              Column({ space: 4 }) {
                Text('地点')
                  .fontSize(12)
                  .fontColor('#7F8C8D')
                  .alignSelf(ItemAlign.Start)

                TextInput({ placeholder: '事件发生地点...', text: this.newEventLocation })
                  .onChange((value: string) => {
                    this.newEventLocation = value;
                  })
              }

              // 心情
              Column({ space: 4 }) {
                Text('心情')
                  .fontSize(12)
                  .fontColor('#7F8C8D')
                  .alignSelf(ItemAlign.Start)

                TextInput({ placeholder: '当时的心情...', text: this.newEventMood })
                  .onChange((value: string) => {
                    this.newEventMood = value;
                  })
              }

              // 天气
              Column({ space: 4 }) {
                Text('天气')
                  .fontSize(12)
                  .fontColor('#7F8C8D')
                  .alignSelf(ItemAlign.Start)

                TextInput({ placeholder: '当时的天气...', text: this.newEventWeather })
                  .onChange((value: string) => {
                    this.newEventWeather = value;
                  })
              }

              // 标签
              Column({ space: 4 }) {
                Text('标签')
                  .fontSize(12)
                  .fontColor('#7F8C8D')
                  .alignSelf(ItemAlign.Start)

                TextInput({ placeholder: '用逗号分隔多个标签...', text: this.newEventTags })
                  .onChange((value: string) => {
                    this.newEventTags = value;
                  })
              }

              // 是否重要
              Row({ space: 8 }) {
                Toggle({ type: ToggleType.Switch, isOn: this.newEventIsImportant })
                  .onChange((isOn: boolean) => {
                    this.newEventIsImportant = isOn;
                  })

                Text('标记为重要事件')
                  .fontSize(14)
                  .fontColor('#2C3E50')
              }

              // 描述
              Column({ space: 4 }) {
                Text('事件描述')
                  .fontSize(12)
                  .fontColor('#7F8C8D')
                  .alignSelf(ItemAlign.Start)

                TextArea({ placeholder: '描述这个事件...', text: this.newEventDescription })
                  .height(80)
                  .onChange((value: string) => {
                    this.newEventDescription = value;
                  })
              }
            }
          }
          .layoutWeight(1)

          // 操作按钮
          Row({ space: 12 }) {
            Button('取消')
              .backgroundColor('#F5F5F5')
              .fontColor('#2C3E50')
              .layoutWeight(1)
              .onClick(() => {
                this.showAddEvent = false;
              })

            Button('保存')
              .backgroundColor('#FF6B35')
              .fontColor(Color.White)
              .layoutWeight(1)
              .onClick(async () => {
                await this.saveNewEvent();
              })
          }
        }
        .width('90%')
        .height('80%')
        .padding(20)
        .backgroundColor(Color.White)
        .borderRadius(16)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }

  @Builder
  buildEditEventDialog() {
    // 编辑事件弹窗实现
    Column() {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#80000000')
          .onClick(() => {
            this.showEditEvent = false;
          })

        // 表单内容
        Column({ space: 20 }) {
          // 标题栏
          Row() {
            Text('编辑事件')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C3E50')
              .layoutWeight(1)

            Image($r('app.media.icon_close'))
              .width(24)
              .height(24)
              .fillColor('#7F8C8D')
              .onClick(() => {
                this.showEditEvent = false;
              })
          }
          .width('100%')

          // 表单字段
          Scroll() {
            Column({ space: 16 }) {
              // 事件标题
              Column({ space: 4 }) {
                Text('事件标题')
                  .fontSize(12)
                  .fontColor('#7F8C8D')
                  .alignSelf(ItemAlign.Start)

                TextInput({ placeholder: '输入事件标题...', text: this.newEventTitle })
                  .onChange((value: string) => {
                    this.newEventTitle = value;
                  })
              }

              // 事件类型
              Column({ space: 4 }) {
                Text('事件类型')
                  .fontSize(12)
                  .fontColor('#7F8C8D')
                  .alignSelf(ItemAlign.Start)

                Row({ space: 8 }) {
                  Text('相遇')
                    .fontSize(12)
                    .fontColor(this.newEventType === EventType.MEET ? Color.White : '#2C3E50')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.newEventType === EventType.MEET ? '#007DFF' : '#F8F9FA')
                    .borderRadius(16)
                    .onClick(() => {
                      this.newEventType = EventType.MEET;
                    })
                  
                  Text('礼物')
                    .fontSize(12)
                    .fontColor(this.newEventType === EventType.GIFT ? Color.White : '#2C3E50')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.newEventType === EventType.GIFT ? '#007DFF' : '#F8F9FA')
                    .borderRadius(16)
                    .onClick(() => {
                      this.newEventType = EventType.GIFT;
                    })
                  
                  Text('里程碑')
                    .fontSize(12)
                    .fontColor(this.newEventType === EventType.MILESTONE ? Color.White : '#2C3E50')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.newEventType === EventType.MILESTONE ? '#007DFF' : '#F8F9FA')
                    .borderRadius(16)
                    .onClick(() => {
                      this.newEventType = EventType.MILESTONE;
                    })
                  
                  Text('矛盾')
                    .fontSize(12)
                    .fontColor(this.newEventType === EventType.CONFLICT ? Color.White : '#2C3E50')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.newEventType === EventType.CONFLICT ? '#007DFF' : '#F8F9FA')
                    .borderRadius(16)
                    .onClick(() => {
                      this.newEventType = EventType.CONFLICT;
                    })
                }
              }

              // 日期
              Column({ space: 4 }) {
                Text('日期')
                  .fontSize(12)
                  .fontColor('#7F8C8D')
                  .alignSelf(ItemAlign.Start)

                DatePicker({
                  start: new Date('1970-1-1'),
                  end: new Date('2100-12-31'),
                  selected: this.newEventDate
                })
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                  .onDateChange((value: Date) => {
                    this.newEventDate = value;
                  })
              }

              // 情感强度
              Column({ space: 4 }) {
                Text(`情感强度: ${this.newEventEmotion}/10`)
                  .fontSize(12)
                  .fontColor('#7F8C8D')
                  .alignSelf(ItemAlign.Start)

                Slider({
                  value: this.newEventEmotion,
                  min: 1,
                  max: 10,
                  step: 1
                })
                  .trackColor('#E0E0E0')
                  .selectedColor('#FF6B35')
                  .onChange((value: number) => {
                    this.newEventEmotion = Math.round(value);
                  })
              }

              // 地点
              Column({ space: 4 }) {
                Text('地点')
                  .fontSize(12)
                  .fontColor('#7F8C8D')
                  .alignSelf(ItemAlign.Start)

                TextInput({ placeholder: '事件发生地点...', text: this.newEventLocation })
                  .onChange((value: string) => {
                    this.newEventLocation = value;
                  })
              }

              // 心情
              Column({ space: 4 }) {
                Text('心情')
                  .fontSize(12)
                  .fontColor('#7F8C8D')
                  .alignSelf(ItemAlign.Start)

                TextInput({ placeholder: '当时的心情...', text: this.newEventMood })
                  .onChange((value: string) => {
                    this.newEventMood = value;
                  })
              }

              // 描述
              Column({ space: 4 }) {
                Text('事件描述')
                  .fontSize(12)
                  .fontColor('#7F8C8D')
                  .alignSelf(ItemAlign.Start)

                TextArea({ placeholder: '描述这个事件...', text: this.newEventDescription })
                  .height(80)
                  .onChange((value: string) => {
                    this.newEventDescription = value;
                  })
              }
            }
          }
          .layoutWeight(1)

          // 操作按钮
          Row({ space: 12 }) {
            Button('取消')
              .backgroundColor('#F5F5F5')
              .fontColor('#2C3E50')
              .layoutWeight(1)
              .onClick(() => {
                this.showEditEvent = false;
              })

            Button('更新')
              .backgroundColor('#3498DB')
              .fontColor(Color.White)
              .layoutWeight(1)
              .onClick(async () => {
                await this.updateEvent();
              })
          }
        }
        .width('90%')
        .height('80%')
        .padding(20)
        .backgroundColor(Color.White)
        .borderRadius(16)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }

  // 保存新事件
  async saveNewEvent() {
    if (this.newEventTitle.trim() === '') {
      promptAction.showToast({ message: '请输入事件标题' });
      return;
    }

    // 处理标签
    const tags = this.newEventTags.trim() ? 
      this.newEventTags.split(',').map(tag => tag.trim()).filter(tag => tag.length > 0) : [];

    const newEvent: TimelineEvent = {
      id: Date.now().toString(),
      contactId: this.currentContactId,
      contactName: this.selectedContact?.name || '未知',
      type: this.newEventType,
      title: this.newEventTitle,
      description: this.newEventDescription,
      date: this.newEventDate.toISOString().split('T')[0],
      emotionLevel: this.newEventEmotion,
      tags: tags,
      mood: this.newEventMood,
      location: this.newEventLocation,
      weather: this.newEventWeather,
      isImportant: this.newEventIsImportant,
      photos: this.newEventPhotos
    };

    try {
      if (!this.timelineDAO) {
        promptAction.showToast({ message: '数据库未初始化' });
        return;
      }
      
      await this.timelineDAO.createTimelineEvent(newEvent);
      promptAction.showToast({ message: '事件保存成功' });
      
      // 重新加载数据
      await this.loadTimelineData();
      
      // 重置表单
      this.resetForm();
      this.showAddEvent = false;
    } catch (error) {
      console.error('保存事件失败:', error);
      promptAction.showToast({ message: '保存失败，请重试' });
    }
  }

  // 准备编辑事件
  prepareEditEvent() {
    if (this.selectedEvent) {
      this.newEventTitle = this.selectedEvent.title;
      this.newEventDescription = this.selectedEvent.description;
      this.newEventType = this.selectedEvent.type;
      this.newEventDate = new Date(this.selectedEvent.date);
      this.newEventEmotion = this.selectedEvent.emotionLevel;
      this.newEventLocation = this.selectedEvent.location || '';
      this.newEventMood = this.selectedEvent.mood || '';
      this.newEventWeather = this.selectedEvent.weather || '';
      this.newEventTags = this.selectedEvent.tags.join(', ');
      this.newEventIsImportant = this.selectedEvent.isImportant || false;
      this.newEventPhotos = this.selectedEvent.photos || [];
      this.showEditEvent = true;
    }
  }

  // 更新事件
  async updateEvent() {
    if (!this.selectedEvent || this.newEventTitle.trim() === '') {
      promptAction.showToast({ message: '请输入事件标题' });
      return;
    }

    // 处理标签
    const tags = this.newEventTags.trim() ? 
      this.newEventTags.split(',').map(tag => tag.trim()).filter(tag => tag.length > 0) : [];

    const updatedEvent: TimelineEvent = {
      id: this.selectedEvent.id,
      contactId: this.selectedEvent.contactId,
      contactName: this.selectedEvent.contactName,
      title: this.newEventTitle,
      description: this.newEventDescription,
      type: this.newEventType,
      date: this.newEventDate.toISOString().split('T')[0],
      emotionLevel: this.newEventEmotion,
      location: this.newEventLocation,
      mood: this.newEventMood,
      weather: this.newEventWeather,
      tags: tags,
      isImportant: this.newEventIsImportant,
      photos: this.newEventPhotos,
      createdAt: this.selectedEvent.createdAt,
      updatedAt: this.selectedEvent.updatedAt
    };

    try {
      if (!this.timelineDAO) {
        promptAction.showToast({ message: '数据库未初始化' });
        return;
      }
      
      await this.timelineDAO.updateTimelineEvent(updatedEvent.id!, updatedEvent);
      promptAction.showToast({ message: '事件更新成功' });
      
      // 重新加载数据
      await this.loadTimelineData();
      
      // 重置表单
      this.resetForm();
      this.showEditEvent = false;
    } catch (error) {
      console.error('更新事件失败:', error);
      promptAction.showToast({ message: '更新失败，请重试' });
    }
  }

  // 删除事件
  async deleteEvent() {
    if (!this.selectedEvent) return;

    try {
      if (!this.timelineDAO) {
        promptAction.showToast({ message: '数据库未初始化' });
        return;
      }
      
      await this.timelineDAO.deleteTimelineEvent(this.selectedEvent.id!);
      promptAction.showToast({ message: '事件删除成功' });
      
      // 重新加载数据
      await this.loadTimelineData();
      
      this.showEventDetail = false;
      this.selectedEvent = null;
    } catch (error) {
      console.error('删除事件失败:', error);
      promptAction.showToast({ message: '删除失败，请重试' });
    }
  }

  // 重置表单
  resetForm() {
    this.newEventTitle = '';
    this.newEventDescription = '';
    this.newEventMood = '';
    this.newEventLocation = '';
    this.newEventTags = '';
    this.newEventWeather = '';
    this.newEventIsImportant = false;
    this.newEventPhotos = [];
    this.newEventType = EventType.MEMORY;
    this.newEventDate = new Date();
    this.newEventEmotion = EmotionLevel.MEDIUM;
  }

  // 工具方法
  formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }

  getEventTypeName(type: EventType): string {
    const typeNames: Record<string, string> = {};
    typeNames[EventType.MEET] = '初次相遇';
    typeNames[EventType.FRIEND] = '成为朋友';
    typeNames[EventType.CLOSE] = '关系加深';
    typeNames[EventType.CONFLICT] = '产生矛盾';
    typeNames[EventType.RECONCILE] = '和解';
    typeNames[EventType.GIFT] = '送礼记录';
    typeNames[EventType.MILESTONE] = '重要里程碑';
    typeNames[EventType.MEMORY] = '美好回忆';
    return typeNames[type] || '其他';
  }

  getEventTypeColor(type: EventType): string {
    const colors: Record<string, string> = {};
    colors[EventType.MEET] = '#FF6B35';
    colors[EventType.FRIEND] = '#4CAF50';
    colors[EventType.CLOSE] = '#2196F3';
    colors[EventType.CONFLICT] = '#F44336';
    colors[EventType.RECONCILE] = '#9C27B0';
    colors[EventType.GIFT] = '#FF9800';
    colors[EventType.MILESTONE] = '#795548';
    colors[EventType.MEMORY] = '#607D8B';
    return colors[type] || '#7F8C8D';
  }

  getEventTypeBgColor(type: EventType): string {
    const colors: Record<string, string> = {};
    colors[EventType.MEET] = '#FFF0ED';
    colors[EventType.FRIEND] = '#E8F5E8';
    colors[EventType.CLOSE] = '#E3F2FD';
    colors[EventType.CONFLICT] = '#FFEBEE';
    colors[EventType.RECONCILE] = '#F3E5F5';
    colors[EventType.GIFT] = '#FFF3E0';
    colors[EventType.MILESTONE] = '#EFEBE9';
    colors[EventType.MEMORY] = '#ECEFF1';
    return colors[type] || '#F5F5F5';
  }

  getEmotionColor(emotion: number): string {
    if (emotion >= 4.5) return '#4CAF50';
    if (emotion >= 3.5) return '#8BC34A';
    if (emotion >= 2.5) return '#FFC107';
    if (emotion >= 1.5) return '#FF9800';
    return '#F44336';
  }
}