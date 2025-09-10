import router from '@ohos.router';

interface BudgetItem {
  id: string;
  name: string;
  amount: number;
  category: string;
}

interface BudgetCategory {
  name: string;
  color: string;
  icon: string;
}

@Entry
@Component
struct BudgetCalculatorPage {
  @State totalBudget: number = 0;
  @State budgetItems: BudgetItem[] = [];
  @State currentItemName: string = '';
  @State currentItemAmount: number = 0;
  @State selectedCategory: string = '礼物';
  @State showAddDialog: boolean = false;
  @State editingItemId: string = '';
  
  // 预算分类
  private categories: BudgetCategory[] = [
    { name: '礼物', color: '#FF6B35', icon: '🎁' },
    { name: '包装', color: '#4CAF50', icon: '📦' },
    { name: '卡片', color: '#2196F3', icon: '💌' },
    { name: '运费', color: '#9C27B0', icon: '🚚' },
    { name: '其他', color: '#607D8B', icon: '📝' }
  ];
  
  aboutToAppear() {
    this.loadSampleData();
  }
  
  loadSampleData() {
    // 加载示例数据
    this.totalBudget = 1000;
    this.budgetItems = [
      {
        id: '1',
        name: '生日礼物',
        amount: 300,
        category: '礼物'
      },
      {
        id: '2',
        name: '礼品包装',
        amount: 50,
        category: '包装'
      },
      {
        id: '3',
        name: '贺卡制作',
        amount: 20,
        category: '卡片'
      }
    ];
  }
  
  getTotalSpent(): number {
    return this.budgetItems.reduce((total, item) => total + item.amount, 0);
  }
  
  getRemainingBudget(): number {
    return this.totalBudget - this.getTotalSpent();
  }
  
  getBudgetProgress(): number {
    if (this.totalBudget === 0) return 0;
    return (this.getTotalSpent() / this.totalBudget) * 100;
  }
  
  getCategoryTotal(categoryName: string): number {
    return this.budgetItems
      .filter(item => item.category === categoryName)
      .reduce((total, item) => total + item.amount, 0);
  }
  
  getCategoryColor(categoryName: string): string {
    const category = this.categories.find(c => c.name === categoryName);
    return category ? category.color : '#999999';
  }
  
  getCategoryIcon(categoryName: string): string {
    const category = this.categories.find(c => c.name === categoryName);
    return category ? category.icon : '📝';
  }
  
  showAddItemDialog() {
    this.currentItemName = '';
    this.currentItemAmount = 0;
    this.selectedCategory = '礼物';
    this.editingItemId = '';
    this.showAddDialog = true;
  }
  
  showEditItemDialog(item: BudgetItem) {
    this.currentItemName = item.name;
    this.currentItemAmount = item.amount;
    this.selectedCategory = item.category;
    this.editingItemId = item.id;
    this.showAddDialog = true;
  }
  
  saveItem() {
    if (!this.currentItemName.trim() || this.currentItemAmount <= 0) {
      return;
    }
    
    if (this.editingItemId) {
      // 编辑现有项目
      const index = this.budgetItems.findIndex(item => item.id === this.editingItemId);
      if (index > -1) {
        this.budgetItems[index] = {
          id: this.budgetItems[index].id,
          name: this.currentItemName,
          amount: this.currentItemAmount,
          category: this.selectedCategory
        };
      }
    } else {
      // 添加新项目
      const newItem: BudgetItem = {
        id: Date.now().toString(),
        name: this.currentItemName,
        amount: this.currentItemAmount,
        category: this.selectedCategory
      };
      this.budgetItems.push(newItem);
    }
    
    this.showAddDialog = false;
  }
  
  deleteItem(itemId: string) {
    const index = this.budgetItems.findIndex(item => item.id === itemId);
    if (index > -1) {
      this.budgetItems.splice(index, 1);
    }
  }
  
  resetBudget() {
    this.budgetItems = [];
    this.totalBudget = 0;
  }
  
  goBack() {
    router.back();
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Text('←')
              .fontSize(20)
              .fontColor('#333333')
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.goBack())
        
        Text('预算计算器')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button() {
          Text('🔄')
              .fontSize(16)
              .fontColor('#999999')
            .width(20)
            .height(20)
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.resetBudget())
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      Scroll() {
        Column() {
          // 总预算设置
          Column() {
            Text('总预算')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 16 })
            
            Row() {
              Text('¥')
                .fontSize(24)
                .fontColor('#FF6B35')
                .fontWeight(FontWeight.Bold)
              
              TextInput({ placeholder: '0' })
                .type(InputType.Number)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF6B35')
                .backgroundColor(Color.Transparent)
                .border({ width: 0 })
                .layoutWeight(1)
                .onChange((value: string) => {
                  this.totalBudget = parseFloat(value) || 0;
                })
            }
            .width('100%')
            .height(60)
            .backgroundColor('#FFF5F0')
            .borderRadius(12)
            .padding({ left: 20, right: 20 })
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .padding(16)
          .margin({ bottom: 16 })
          
          // 预算概览
          Column() {
            Text('预算概览')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 16 })
            
            // 进度条
            Column() {
              Row() {
                Text('已使用')
                  .fontSize(14)
                  .fontColor('#666666')
                
                Blank()
                
                Text(`¥${this.getTotalSpent()}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FF6B35')
              }
              .width('100%')
              .margin({ bottom: 8 })
              
              Progress({
                value: this.getTotalSpent(),
                total: this.totalBudget || 1,
                type: ProgressType.Linear
              })
                .width('100%')
                .height(8)
                .color('#FF6B35')
                .backgroundColor('#F0F0F0')
                .borderRadius(4)
              
              Row() {
                Text(`剩余: ¥${this.getRemainingBudget()}`)
                  .fontSize(14)
                  .fontColor(this.getRemainingBudget() >= 0 ? '#4CAF50' : '#F44336')
                
                Blank()
                
                Text(`${this.getBudgetProgress().toFixed(1)}%`)
                  .fontSize(14)
                  .fontColor('#666666')
              }
              .width('100%')
              .margin({ top: 8 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .padding(16)
          .margin({ bottom: 16 })
          
          // 分类统计
          Column() {
            Row() {
              Text('分类统计')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              
              Blank()
              
              Button() {
                Row() {
                  Image($r('app.media.ic_add'))
                    .width(16)
                    .height(16)
                    .fillColor('#FF6B35')
                    .margin({ right: 4 })
                  
                  Text('添加')
                    .fontSize(14)
                    .fontColor('#FF6B35')
                }
              }
              .backgroundColor(Color.Transparent)
              .onClick(() => this.showAddItemDialog())
            }
            .width('100%')
            .margin({ bottom: 16 })
            
            if (this.budgetItems.length === 0) {
              Column() {
                Image($r('app.media.ic_empty'))
                  .width(60)
                  .height(60)
                  .fillColor('#CCCCCC')
                
                Text('还没有预算项目')
                  .fontSize(16)
                  .fontColor('#999999')
                  .margin({ top: 16 })
                
                Text('点击上方添加按钮开始规划预算')
                  .fontSize(14)
                  .fontColor('#CCCCCC')
                  .margin({ top: 8 })
              }
              .width('100%')
              .height(120)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            } else {
              // 分类汇总
              Column() {
                ForEach(this.categories, (category: BudgetCategory) => {
                  if (this.getCategoryTotal(category.name) > 0) {
                    Row() {
                      Text(category.icon)
                        .fontSize(20)
                        .margin({ right: 12 })
                      
                      Column() {
                        Text(category.name)
                          .fontSize(16)
                          .fontColor('#333333')
                        
                        Text(`¥${this.getCategoryTotal(category.name)}`)
                          .fontSize(14)
                          .fontColor(category.color)
                          .fontWeight(FontWeight.Medium)
                          .margin({ top: 2 })
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)
                      
                      Text(`${((this.getCategoryTotal(category.name) / this.getTotalSpent()) * 100).toFixed(1)}%`)
                        .fontSize(14)
                        .fontColor('#666666')
                    }
                    .width('100%')
                    .padding({ top: 12, bottom: 12 })
                    .alignItems(VerticalAlign.Center)
                  }
                })
              }
              .width('100%')
              .margin({ bottom: 16 })
              
              // 详细列表
              Column() {
                Text('详细列表')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 12 })
                
                ForEach(this.budgetItems, (item: BudgetItem) => {
                  Row() {
                    Text(this.getCategoryIcon(item.category))
                      .fontSize(16)
                      .margin({ right: 12 })
                    
                    Column() {
                      Text(item.name)
                        .fontSize(16)
                        .fontColor('#333333')
                        .alignSelf(ItemAlign.Start)
                      
                      Text(item.category)
                        .fontSize(12)
                        .fontColor('#999999')
                        .alignSelf(ItemAlign.Start)
                        .margin({ top: 2 })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    
                    Text(`¥${item.amount}`)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.getCategoryColor(item.category))
                      .margin({ right: 12 })
                    
                    Button() {
                      Text('✏️')
                        .fontSize(16)
                        .width(16)
                        .height(16)
                    }
                    .width(32)
                    .height(32)
                    .backgroundColor(Color.Transparent)
                    .onClick(() => this.showEditItemDialog(item))
                    
                    Button() {
                      Text('🗑️')
                        .fontSize(16)
                        .width(16)
                        .height(16)
                    }
                    .width(32)
                    .height(32)
                    .backgroundColor(Color.Transparent)
                    .onClick(() => this.deleteItem(item.id))
                  }
                  .width('100%')
                  .padding({ top: 12, bottom: 12 })
                  .alignItems(VerticalAlign.Center)
                  .border({ width: { bottom: 1 }, color: '#F0F0F0' })
                })
              }
            }
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .padding(16)
        }
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      
      // 添加/编辑对话框
      if (this.showAddDialog) {
        Stack() {
          // 背景遮罩
          Rect()
            .width('100%')
            .height('100%')
            .fill('#80000000')
            .onClick(() => {
              this.showAddDialog = false;
            })
          
          // 对话框内容
          Column() {
            Text(this.editingItemId ? '编辑项目' : '添加项目')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ bottom: 20 })
            
            // 项目名称
            Column() {
              Text('项目名称')
                .fontSize(14)
                .fontColor('#666666')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })
              
              TextInput({ placeholder: '输入项目名称' })
                .fontSize(16)
                .backgroundColor('#F8F9FA')
                .borderRadius(8)
                .padding({ left: 16, right: 16 })
                .onChange((value: string) => {
                  this.currentItemName = value;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ bottom: 16 })
            
            // 金额
            Column() {
              Text('金额')
                .fontSize(14)
                .fontColor('#666666')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })
              
              TextInput({ placeholder: '0' })
                .type(InputType.Number)
                .fontSize(16)
                .backgroundColor('#F8F9FA')
                .borderRadius(8)
                .padding({ left: 16, right: 16 })
                .onChange((value: string) => {
                  this.currentItemAmount = parseFloat(value) || 0;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ bottom: 16 })
            
            // 分类选择
            Column() {
              Text('分类')
                .fontSize(14)
                .fontColor('#666666')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })
              
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.categories, (category: BudgetCategory) => {
                  Button() {
                    Row() {
                      Text(category.icon)
                        .fontSize(16)
                        .margin({ right: 6 })
                      
                      Text(category.name)
                        .fontSize(14)
                        .fontColor(this.selectedCategory === category.name ? '#FFFFFF' : '#666666')
                    }
                  }
                  .backgroundColor(this.selectedCategory === category.name ? category.color : '#F5F5F5')
                  .borderRadius(16)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => {
                    this.selectedCategory = category.name;
                  })
                })
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ bottom: 24 })
            
            // 按钮
            Row() {
              Button('取消')
                .fontSize(16)
                .fontColor('#666666')
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .layoutWeight(1)
                .margin({ right: 8 })
                .onClick(() => {
                  this.showAddDialog = false;
                })
              
              Button('保存')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .backgroundColor('#FF6B35')
                .borderRadius(8)
                .layoutWeight(1)
                .margin({ left: 8 })
                .onClick(() => this.saveItem())
            }
            .width('100%')
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .padding(24)
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}