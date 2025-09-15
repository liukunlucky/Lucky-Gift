import router from '@ohos.router';

interface QuickRecord {
  id: string;
  type: string;
  title: string;
  content: string;
  date: string;
  tags: string[];
}

@Entry
@Component
struct QuickRecordPage {
  @State records: QuickRecord[] = [];
  @State showAddDialog: boolean = false;
  @State newRecordType: string = 'idea';
  @State newRecordTitle: string = '';
  @State newRecordContent: string = '';
  @State selectedTags: string[] = [];
  @State availableTags: string[] = ['礼物想法', '重要日期', '预算记录', '购买清单', '送礼经验'];

  aboutToAppear() {
    this.loadRecords();
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

        Text('📝 快速记录')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button() {
          Image($r('app.media.ic_add'))
            .width(24)
            .height(24)
            .fillColor('#FF6B35')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.showAddDialog = true;
        })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      // 快捷操作按钮
      Row() {
        this.buildQuickButton('💡', '礼物想法', () => {
          this.quickAdd('idea', '礼物想法');
        })
        this.buildQuickButton('📅', '重要日期', () => {
          this.quickAdd('date', '重要日期');
        })
        this.buildQuickButton('💰', '预算记录', () => {
          this.quickAdd('budget', '预算记录');
        })
        this.buildQuickButton('🛒', '购买清单', () => {
          this.quickAdd('shopping', '购买清单');
        })
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.SpaceAround)
      .backgroundColor(Color.White)
      .margin({ bottom: 8 })

      // 记录列表
      if (this.records.length === 0) {
        Column() {
          Text('📝')
            .fontSize(48)
            .margin({ bottom: 16 })

          Text('还没有记录')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ bottom: 8 })

          Text('点击上方按钮开始记录送礼灵感')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.records, (record: QuickRecord) => {
              this.buildRecordItem(record);
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }
        .layoutWeight(1)
        .backgroundColor('#F8F9FA')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
    .bindSheet($$this.showAddDialog, this.buildAddDialog(), {
      height: 600,
      showClose: true,
      dragBar: true
    })
  }

  @Builder
  buildQuickButton(icon: string, title: string, action: () => void) {
    Column() {
      Text(icon)
        .fontSize(24)
        .margin({ bottom: 8 })

      Text(title)
        .fontSize(12)
        .fontColor('#666666')
    }
    .width(80)
    .height(80)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F8F9FA')
    .borderRadius(12)
    .onClick(action)
  }

  @Builder
  buildRecordItem(record: QuickRecord) {
    Column() {
      Row() {
        Text(this.getTypeIcon(record.type))
          .fontSize(20)
          .margin({ right: 12 })

        Column() {
          Text(record.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .alignSelf(ItemAlign.Start)

          Text(record.date)
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
            .alignSelf(ItemAlign.Start)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Button() {
          Image($r('app.media.icon_settings'))
            .width(16)
            .height(16)
            .fillColor('#CCCCCC')
        }
        .width(32)
        .height(32)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          console.info('更多操作');
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      if (record.content) {
        Text(record.content)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 12 })
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .alignSelf(ItemAlign.Start)
      }

      if (record.tags.length > 0) {
        Row() {
          ForEach(record.tags, (tag: string) => {
            Text(tag)
              .fontSize(10)
              .fontColor('#FF6B35')
              .backgroundColor('#FFF5F0')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(12)
              .margin({ right: 8 })
          })
        }
        .width('100%')
        .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 12 })
    .onClick(() => {
      console.info('查看记录详情:', record.id);
    })
  }

  @Builder
  buildAddDialog() {
    Column() {
      Text('添加新记录')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .margin({ bottom: 24 })

      // 记录类型选择
      Text('记录类型')
        .fontSize(14)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })

      Row() {
        this.buildTypeOption('idea', '💡', '礼物想法')
        this.buildTypeOption('date', '📅', '重要日期')
        this.buildTypeOption('budget', '💰', '预算记录')
        this.buildTypeOption('shopping', '🛒', '购买清单')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 20 })

      // 标题输入
      Text('标题')
        .fontSize(14)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })

      TextInput({ placeholder: '请输入标题' })
        .width('100%')
        .height(40)
        .backgroundColor('#F8F9FA')
        .borderRadius(8)
        .padding({ left: 12, right: 12 })
        .onChange((value: string) => {
          this.newRecordTitle = value;
        })
        .margin({ bottom: 16 })

      // 内容输入
      Text('内容')
        .fontSize(14)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })

      TextArea({ placeholder: '请输入详细内容...' })
        .width('100%')
        .height(100)
        .backgroundColor('#F8F9FA')
        .borderRadius(8)
        .padding(12)
        .onChange((value: string) => {
          this.newRecordContent = value;
        })
        .margin({ bottom: 16 })

      // 标签选择
      Text('标签')
        .fontSize(14)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.availableTags, (tag: string) => {
          Text(tag)
            .fontSize(12)
            .fontColor(this.selectedTags.includes(tag) ? Color.White : '#666666')
            .backgroundColor(this.selectedTags.includes(tag) ? '#FF6B35' : '#F0F0F0')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(16)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.toggleTag(tag);
            })
        })
      }
      .width('100%')
      .margin({ bottom: 24 })

      // 底部按钮
      Row() {
        Button('取消')
          .fontSize(16)
          .fontColor('#666666')
          .backgroundColor('#F0F0F0')
          .borderRadius(25)
          .layoutWeight(1)
          .height(50)
          .margin({ right: 8 })
          .onClick(() => {
            this.resetAddDialog();
          })

        Button('保存')
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#FF6B35')
          .borderRadius(25)
          .layoutWeight(1)
          .height(50)
          .margin({ left: 8 })
          .onClick(() => {
            this.saveRecord();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
  }

  @Builder
  buildTypeOption(type: string, icon: string, title: string) {
    Column() {
      Text(icon)
        .fontSize(20)
        .margin({ bottom: 4 })

      Text(title)
        .fontSize(10)
        .fontColor(this.newRecordType === type ? '#FF6B35' : '#666666')
    }
    .width(70)
    .height(60)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.newRecordType === type ? '#FFF5F0' : '#F8F9FA')
    .borderRadius(8)
    .border({
      width: 1,
      color: this.newRecordType === type ? '#FF6B35' : '#F0F0F0'
    })
    .onClick(() => {
      this.newRecordType = type;
    })
  }

  private getTypeIcon(type: string): string {
    switch (type) {
      case 'idea': return '💡';
      case 'date': return '📅';
      case 'budget': return '💰';
      case 'shopping': return '🛒';
      default: return '📝';
    }
  }

  private quickAdd(type: string, title: string): void {
    this.newRecordType = type;
    this.newRecordTitle = title;
    this.showAddDialog = true;
  }

  private toggleTag(tag: string): void {
    const index = this.selectedTags.indexOf(tag);
    if (index > -1) {
      this.selectedTags.splice(index, 1);
    } else {
      this.selectedTags.push(tag);
    }
  }

  private saveRecord(): void {
    if (!this.newRecordTitle.trim()) {
      return;
    }

    const newRecord: QuickRecord = {
      id: Date.now().toString(),
      type: this.newRecordType,
      title: this.newRecordTitle,
      content: this.newRecordContent,
      date: new Date().toLocaleDateString(),
      tags: [...this.selectedTags]
    };

    this.records.unshift(newRecord);
    this.resetAddDialog();
  }

  private resetAddDialog(): void {
    this.showAddDialog = false;
    this.newRecordType = 'idea';
    this.newRecordTitle = '';
    this.newRecordContent = '';
    this.selectedTags = [];
  }

  private loadRecords(): void {
    // 模拟加载已有记录
    this.records = [
      {
        id: '1',
        type: 'idea',
        title: '妈妈生日礼物想法',
        content: '考虑买一套护肤品，她最近总说皮肤干燥。或者买个按摩椅，她工作太累了。',
        date: '2024-01-15',
        tags: ['礼物想法', '生日']
      },
      {
        id: '2',
        type: 'budget',
        title: '情人节预算',
        content: '总预算500元：鲜花100元，晚餐200元，小礼物200元',
        date: '2024-01-10',
        tags: ['预算记录', '情人节']
      }
    ];
  }
}