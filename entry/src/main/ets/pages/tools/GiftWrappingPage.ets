import router from '@ohos.router';

interface WrappingStyle {
  id: number;
  name: string;
  description: string;
  difficulty: string;
  materials: string[];
  steps: string[];
  imageUrl: string;
  category: string;
}

@Entry
@Component
struct GiftWrappingPage {
  @State selectedCategory: string = '全部';
  @State wrappingStyles: WrappingStyle[] = [];
  @State categories: string[] = ['全部', '简约风', '可爱风', '商务风', '节日风', '创意风'];

  aboutToAppear() {
    this.loadWrappingStyles();
  }

  // 加载包装样式数据
  loadWrappingStyles() {
    this.wrappingStyles = [
      {
        id: 1,
        name: '经典蝴蝶结包装',
        description: '优雅的蝴蝶结包装，适合各种场合',
        difficulty: '简单',
        materials: ['包装纸', '丝带', '双面胶', '剪刀'],
        steps: [
          '将礼品放在包装纸中央',
          '将包装纸对折包裹礼品',
          '用双面胶固定包装纸',
          '在顶部系上蝴蝶结'
        ],
        imageUrl: '',
        category: '简约风'
      },
      {
        id: 2,
        name: '日式风呂敷包装',
        description: '传统日式包装方法，环保又美观',
        difficulty: '中等',
        materials: ['风呂敷布', '装饰绳'],
        steps: [
          '将布料平铺在桌面',
          '将礼品放在布料中央',
          '将对角的布料打结',
          '调整布料形状'
        ],
        imageUrl: '',
        category: '创意风'
      },
      {
        id: 3,
        name: '花束式包装',
        description: '像花束一样的包装方式，浪漫温馨',
        difficulty: '中等',
        materials: ['透明包装纸', '彩带', '装饰花', '胶带'],
        steps: [
          '用透明纸包裹礼品',
          '在顶部收紧形成花束状',
          '用彩带绑紧',
          '添加装饰花'
        ],
        imageUrl: '',
        category: '可爱风'
      },
      {
        id: 4,
        name: '商务礼盒包装',
        description: '正式的商务包装，适合商务场合',
        difficulty: '简单',
        materials: ['礼盒', '缎带', '贺卡', '封蜡'],
        steps: [
          '将礼品放入礼盒',
          '盖上盒盖',
          '用缎带装饰',
          '贴上贺卡'
        ],
        imageUrl: '',
        category: '商务风'
      },
      {
        id: 5,
        name: '圣诞主题包装',
        description: '充满节日气氛的圣诞包装',
        difficulty: '中等',
        materials: ['红色包装纸', '金色丝带', '圣诞装饰', '铃铛'],
        steps: [
          '用红色包装纸包裹',
          '系上金色丝带',
          '添加圣诞装饰',
          '挂上小铃铛'
        ],
        imageUrl: '',
        category: '节日风'
      }
    ];
  }

  // 获取过滤后的包装样式
  getFilteredStyles(): WrappingStyle[] {
    if (this.selectedCategory === '全部') {
      return this.wrappingStyles;
    }
    return this.wrappingStyles.filter(style => style.category === this.selectedCategory);
  }

  // 返回上一页
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
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.goBack())
        
        Text('礼物包装')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Row().width(40) // 占位
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      // 分类选择
      Row() {
        List({ space: 8 }) {
          ForEach(this.categories, (category: string) => {
            ListItem() {
              Text(category)
                .fontSize(14)
                .fontColor(this.selectedCategory === category ? '#FFFFFF' : '#666666')
                .backgroundColor(this.selectedCategory === category ? '#FF6B35' : '#F8F9FA')
                .borderRadius(16)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .onClick(() => {
                  this.selectedCategory = category;
                })
            }
          }, (category: string) => category)
        }
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      // 包装样式列表
      List() {
        ForEach(this.getFilteredStyles(), (style: WrappingStyle) => {
          ListItem() {
            Column() {
              // 样式图片占位
              Column() {
                Text('🎁')
                  .fontSize(48)
              }
              .width('100%')
              .height(120)
              .backgroundColor('#F8F9FA')
              .borderRadius(8)
              .justifyContent(FlexAlign.Center)
              
              // 样式信息
              Column() {
                Row() {
                  Text(style.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333333')
                    .layoutWeight(1)
                  
                  Text(style.difficulty)
                    .fontSize(12)
                    .fontColor('#FFFFFF')
                    .backgroundColor(style.difficulty === '简单' ? '#4CAF50' : '#FF9800')
                    .borderRadius(4)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                }
                .width('100%')
                .margin({ top: 12 })
                
                Text(style.description)
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ top: 4 })
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                
                // 所需材料
                Column() {
                  Text('所需材料：')
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ bottom: 4 })
                  
                  Text(style.materials.join('、'))
                    .fontSize(12)
                    .fontColor('#666666')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .margin({ top: 8 })
                
                // 查看详情按钮
                Button('查看教程')
                  .fontSize(14)
                  .fontColor('#FF6B35')
                  .backgroundColor(Color.Transparent)
                  .border({ width: 1, color: '#FF6B35' })
                  .borderRadius(4)
                  .width('100%')
                  .height(32)
                  .margin({ top: 12 })
                  .onClick(() => {
                    this.showTutorial(style);
                  })
              }
              .width('100%')
              .padding(16)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .margin({ bottom: 12 })
          }
        }, (style: WrappingStyle) => style.id.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  // 显示教程详情
  showTutorial(style: WrappingStyle) {
    AlertDialog.show({
      title: style.name + ' 教程',
      message: this.formatSteps(style.steps),
      confirm: {
        value: '知道了',
        action: () => {}
      }
    });
  }

  // 格式化步骤文本
  formatSteps(steps: string[]): string {
    let result = '';
    steps.forEach((step, index) => {
      result += `${index + 1}. ${step}\n`;
    });
    return result;
  }
}