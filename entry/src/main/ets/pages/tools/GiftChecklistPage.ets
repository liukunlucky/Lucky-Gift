import router from '@ohos.router';

interface ChecklistItem {
  id: string;
  title: string;
  description: string;
  isChecked: boolean;
  category: string;
}

@Entry
@Component
struct GiftChecklistPage {
  @State checklistItems: ChecklistItem[] = [];
  @State completedCount: number = 0;
  @State totalCount: number = 0;
  @State selectedCategory: string = 'all';

  aboutToAppear() {
    this.loadChecklistItems();
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

        Text('送礼检查清单')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button() {
          Text('重置')
            .fontSize(14)
            .fontColor('#FF6B35')
        }
        .width(60)
        .height(32)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.resetChecklist();
        })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      // 进度显示
      Column() {
        Row() {
          Text('完成进度')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Blank()

          Text(`${this.completedCount}/${this.totalCount}`)
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .margin({ bottom: 12 })

        Progress({
          value: this.completedCount,
          total: this.totalCount,
          type: ProgressType.Linear
        })
          .width('100%')
          .height(8)
          .color('#FF6B35')
          .backgroundColor('#F0F0F0')
          .borderRadius(4)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .margin({ top: 8, bottom: 8 })

      // 分类筛选
      Row() {
        this.buildCategoryButton('all', '全部')
        this.buildCategoryButton('preparation', '准备阶段')
        this.buildCategoryButton('selection', '选择阶段')
        this.buildCategoryButton('delivery', '送礼阶段')
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .margin({ bottom: 8 })

      // 检查清单
      List() {
        ForEach(this.getFilteredItems(), (item: ChecklistItem) => {
          ListItem() {
            this.buildChecklistItem(item)
          }
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .backgroundColor('#F8F9FA')
      .divider({ strokeWidth: 0 })
      .padding({ left: 16, right: 16, top: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  @Builder
  buildCategoryButton(category: string, title: string) {
    Button() {
      Text(title)
        .fontSize(12)
        .fontColor(this.selectedCategory === category ? Color.White : '#666666')
    }
    .backgroundColor(this.selectedCategory === category ? '#FF6B35' : '#F0F0F0')
    .borderRadius(16)
    .height(32)
    .padding({ left: 12, right: 12 })
    .margin({ right: 8 })
    .onClick(() => {
      this.selectedCategory = category;
    })
  }

  @Builder
  buildChecklistItem(item: ChecklistItem) {
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
          .fontWeight(FontWeight.Medium)
          .fontColor(item.isChecked ? '#999999' : '#333333')
          .decoration({
            type: item.isChecked ? TextDecorationType.LineThrough : TextDecorationType.None
          })
          .alignSelf(ItemAlign.Start)

        Text(item.description)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 4 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .alignSelf(ItemAlign.Start)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ bottom: 8 })
    .alignItems(VerticalAlign.Top)
    .onClick(() => {
      this.toggleChecklistItem(item);
    })
  }

  private loadChecklistItems(): void {
    this.checklistItems = [
      {
        id: '1',
        title: '确定收礼人喜好',
        description: '了解对方的兴趣爱好、生活习惯和最近的需求',
        isChecked: false,
        category: 'preparation'
      },
      {
        id: '2',
        title: '设定预算范围',
        description: '根据关系亲密度和自己的经济能力确定合理预算',
        isChecked: false,
        category: 'preparation'
      },
      {
        id: '3',
        title: '选择合适场合',
        description: '考虑送礼的时间、地点和具体场合',
        isChecked: false,
        category: 'preparation'
      },
      {
        id: '4',
        title: '研究礼物选项',
        description: '根据收礼人喜好和预算筛选合适的礼物类型',
        isChecked: false,
        category: 'selection'
      },
      {
        id: '5',
        title: '比较价格和品质',
        description: '在多个渠道对比价格，确保性价比最优',
        isChecked: false,
        category: 'selection'
      },
      {
        id: '6',
        title: '确认礼物实用性',
        description: '确保礼物对收礼人有实际价值和意义',
        isChecked: false,
        category: 'selection'
      },
      {
        id: '7',
        title: '准备精美包装',
        description: '选择合适的包装方式和材料，体现用心程度',
        isChecked: false,
        category: 'delivery'
      },
      {
        id: '8',
        title: '准备贺卡或祝福语',
        description: '写一张真诚的贺卡或准备温馨的祝福语',
        isChecked: false,
        category: 'delivery'
      },
      {
        id: '9',
        title: '确认送礼时间',
        description: '选择最佳的送礼时机，避免尴尬场合',
        isChecked: false,
        category: 'delivery'
      },
      {
        id: '10',
        title: '准备送礼说辞',
        description: '想好送礼时要说的话，表达真诚心意',
        isChecked: false,
        category: 'delivery'
      }
    ];
    this.totalCount = this.checklistItems.length;
    this.updateCompletedCount();
  }

  private getFilteredItems(): ChecklistItem[] {
    if (this.selectedCategory === 'all') {
      return this.checklistItems;
    }
    return this.checklistItems.filter(item => item.category === this.selectedCategory);
  }

  private toggleChecklistItem(item: ChecklistItem): void {
    const index = this.checklistItems.findIndex(i => i.id === item.id);
    if (index !== -1) {
      // 创建新数组来触发UI更新
      const newItems = this.checklistItems.slice();
      const updatedItem: ChecklistItem = {
        id: newItems[index].id,
        title: newItems[index].title,
        description: newItems[index].description,
        isChecked: !newItems[index].isChecked,
        category: newItems[index].category
      };
      newItems[index] = updatedItem;
      this.checklistItems = newItems;
      this.updateCompletedCount();
    }
  }

  private updateCompletedCount(): void {
    this.completedCount = this.checklistItems.filter(item => item.isChecked).length;
  }

  private resetChecklist(): void {
    // 创建新数组来触发UI更新
    const newItems = this.checklistItems.slice();
    newItems.forEach(item => {
      item.isChecked = false;
    });
    this.checklistItems = newItems;
    this.updateCompletedCount();
  }
}