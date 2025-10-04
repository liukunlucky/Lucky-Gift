import router from '@ohos.router';

// 包装风格
interface WrappingStyle {
  id: string;
  name: string;
  description: string;
  image: Resource;
  difficulty: '简单' | '中等' | '困难';
  materials: string[];
  steps: string[];
  tips: string[];
}

// 包装场合
interface WrappingOccasion {
  id: string;
  name: string;
  description: string;
  recommendedStyles: string[];
  colorSchemes: string[];
}

@Entry
@Component
struct GiftWrappingGuidePage {
  @State currentTabIndex: number = 0;
  @State wrappingStyles: WrappingStyle[] = [];
  @State occasions: WrappingOccasion[] = [];
  @State selectedStyle: WrappingStyle | null = null;
  @State showStyleDetail: boolean = false;

  aboutToAppear() {
    this.loadWrappingData();
  }

  loadWrappingData() {
    // 包装风格数据
    this.wrappingStyles = [
      {
        id: '1',
        name: '经典蝴蝶结',
        description: '优雅经典的蝴蝶结包装，适合各种场合',
        image: $r('app.media.hudiejie'),
        difficulty: '简单',
        materials: ['包装纸', '丝带', '剪刀', '双面胶'],
        steps: [
          '选择合适大小的包装纸',
          '将礼物放在包装纸中央',
          '将包装纸四角向中心折叠',
          '用双面胶固定',
          '系上丝带打蝴蝶结'
        ],
        tips: [
          '选择与礼物大小匹配的包装纸',
          '蝴蝶结要系得饱满对称',
          '可以在蝴蝶结上加小装饰'
        ]
      },
      {
        id: '2',
        name: '日式风吕敷',
        description: '简约环保的日式包装方法',
        image: $r('app.media.rishi'),
        difficulty: '中等',
        materials: ['方形布料', '装饰绳'],
        steps: [
          '将布料平铺成菱形',
          '将礼物放在中央',
          '将对角的两个角打结',
          '调整布料形状',
          '用装饰绳固定'
        ],
        tips: [
          '选择质地较好的布料',
          '打结要紧实美观',
          '可重复使用，环保实用'
        ]
      },
      {
        id: '3',
        name: '花束式包装',
        description: '像花束一样的浪漫包装方式',
        image: $r('app.media.huashu'),
        difficulty: '困难',
        materials: ['透明包装纸', '彩带', '装饰花', '胶带'],
        steps: [
          '用透明纸包裹礼物',
          '在顶部收拢成花束状',
          '用彩带扎紧',
          '添加装饰花',
          '整理包装形状'
        ],
        tips: [
          '透明纸要选择有质感的',
          '收拢时要保持对称',
          '装饰花不宜过多'
        ]
      },
      {
        id: '4',
        name: '复古牛皮纸',
        description: '简约复古的牛皮纸包装',
        image: $r('app.media.niupizhi'),
        difficulty: '简单',
        materials: ['牛皮纸', '麻绳', '标签', '印章'],
        steps: [
          '用牛皮纸包装礼物',
          '用麻绳绑扎',
          '贴上手写标签',
          '可用印章装饰',
          '添加干花或树叶'
        ],
        tips: [
          '牛皮纸要选择厚实的',
          '麻绳绑法要有层次',
          '手写标签增加温度'
        ]
      },
      {
        id: '5',
        name: '欧式宫廷风',
        description: '华丽优雅的欧式宫廷包装风格',
        image: $r('app.media.oushi'),
        difficulty: '困难',
        materials: ['金色包装纸', '蕾丝丝带', '珍珠装饰', '封蜡印章'],
        steps: [
          '用金色包装纸精心包装',
          '系上蕾丝丝带',
          '添加珍珠装饰',
          '用封蜡印章封口',
          '整体造型调整'
        ],
        tips: [
          '材料要选择高档质感',
          '装饰要对称美观',
          '封蜡印章要清晰'
        ]
      },
      {
        id: '6',
        name: '现代简约风',
        description: '简洁现代的包装设计',
        image: $r('app.media.xiandai'),
        difficulty: '简单',
        materials: ['纯色包装纸', '细丝带', '几何标签'],
        steps: [
          '选择纯色包装纸',
          '包装要平整无褶皱',
          '用细丝带简单装饰',
          '贴上几何图案标签',
          '保持整体简洁'
        ],
        tips: [
          '颜色搭配要协调',
          '线条要干净利落',
          '装饰要适度'
        ]
      },
      {
        id: '7',
        name: '田园乡村风',
        description: '温馨自然的田园风格包装',
        image: $r('app.media.tianyuan'),
        difficulty: '中等',
        materials: ['格子布料', '麻绳', '干花', '木质标签'],
        steps: [
          '用格子布料包装',
          '用麻绳绑扎',
          '添加干花装饰',
          '挂上木质标签',
          '营造自然感觉'
        ],
        tips: [
          '布料要有质感',
          '干花要搭配协调',
          '整体要有层次感'
        ]
      },
      {
        id: '8',
        name: '中式传统风',
        description: '典雅的中式传统包装',
        image: $r('app.media.zhongshi'),
        difficulty: '中等',
        materials: ['红色丝绸', '金色绳结', '中国结', '书法标签'],
        steps: [
          '用红色丝绸包装',
          '打金色绳结',
          '添加中国结装饰',
          '贴上书法标签',
          '体现传统韵味'
        ],
        tips: [
          '颜色要喜庆',
          '绳结要工整',
          '书法要端正'
        ]
      },
      {
        id: '9',
        name: '儿童卡通风',
        description: '活泼可爱的儿童包装风格',
        image: $r('app.media.ertong'),
        difficulty: '简单',
        materials: ['卡通包装纸', '彩色丝带', '贴纸', '小玩具'],
        steps: [
          '选择卡通图案包装纸',
          '用彩色丝带装饰',
          '贴上可爱贴纸',
          '添加小玩具装饰',
          '营造童趣氛围'
        ],
        tips: [
          '图案要可爱有趣',
          '颜色要鲜艳',
          '装饰要安全'
        ]
      },
      {
        id: '10',
        name: '环保创意风',
        description: '环保材料的创意包装',
        image: $r('app.media.huanbao'),
        difficulty: '中等',
        materials: ['报纸', '旧地图', '天然麻绳', '植物装饰'],
        steps: [
          '用报纸或旧地图包装',
          '用天然麻绳绑扎',
          '添加植物装饰',
          '制作环保标签',
          '体现环保理念'
        ],
        tips: [
          '材料要干净整洁',
          '创意要有新意',
          '环保理念要突出'
        ]
      }
    ];

    // 场合数据
    this.occasions = [
      {
        id: '1',
        name: '生日庆祝',
        description: '生日礼物包装要体现欢乐和祝福',
        recommendedStyles: ['经典蝴蝶结', '花束式包装'],
        colorSchemes: ['粉色系', '彩虹色', '金色系']
      },
      {
        id: '2',
        name: '婚礼庆典',
        description: '婚礼礼物包装要优雅庄重',
        recommendedStyles: ['经典蝴蝶结', '日式风吕敷'],
        colorSchemes: ['白色系', '香槟色', '淡粉色']
      },
      {
        id: '3',
        name: '节日庆祝',
        description: '节日礼物包装要有节日氛围',
        recommendedStyles: ['花束式包装', '复古牛皮纸'],
        colorSchemes: ['红色系', '绿色系', '金银色']
      },
      {
        id: '4',
        name: '商务场合',
        description: '商务礼物包装要简约专业',
        recommendedStyles: ['复古牛皮纸', '日式风吕敷'],
        colorSchemes: ['黑色系', '深蓝色', '灰色系']
      },
      {
        id: '5',
        name: '情人节',
        description: '情人节礼物包装要浪漫温馨',
        recommendedStyles: ['花束式包装', '欧式宫廷风'],
        colorSchemes: ['粉色系', '红色系', '紫色系']
      },
      {
        id: '6',
        name: '母亲节',
        description: '母亲节礼物包装要温暖感恩',
        recommendedStyles: ['田园乡村风', '经典蝴蝶结'],
        colorSchemes: ['暖色系', '粉色系', '米色系']
      },
      {
        id: '7',
        name: '儿童节',
        description: '儿童节礼物包装要活泼可爱',
        recommendedStyles: ['儿童卡通风', '现代简约风'],
        colorSchemes: ['彩虹色', '明亮色', '糖果色']
      },
      {
        id: '8',
        name: '毕业典礼',
        description: '毕业礼物包装要庄重纪念',
        recommendedStyles: ['现代简约风', '复古牛皮纸'],
        colorSchemes: ['深蓝色', '黑色系', '金色系']
      },
      {
        id: '9',
        name: '新年春节',
        description: '新年礼物包装要喜庆吉祥',
        recommendedStyles: ['中式传统风', '欧式宫廷风'],
        colorSchemes: ['红色系', '金色系', '中国红']
      },
      {
        id: '10',
        name: '环保主题',
        description: '环保主题礼物包装要绿色可持续',
        recommendedStyles: ['环保创意风', '日式风吕敷'],
        colorSchemes: ['绿色系', '自然色', '大地色']
      }
    ];
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航
        this.buildHeader()

        // 标签页
        Tabs({ index: this.currentTabIndex }) {
          TabContent() {
            this.buildStylesGrid()
          }
          .tabBar('包装风格')

          TabContent() {
            this.buildOccasionsList()
          }
          .tabBar('场合指南')

          TabContent() {
            this.buildToolsAndTips()
          }
          .tabBar('工具技巧')
        }
        .onChange((index: number) => {
          this.currentTabIndex = index;
        })
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8F9FA')

      // 风格详情弹窗
      if (this.showStyleDetail && this.selectedStyle) {
        this.buildStyleDetailDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.icon_back'))
        .width(24)
        .height(24)
        .fillColor('#2C3E50')
        .onClick(() => {
          router.back();
        })

      Text('礼物包装指南')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2C3E50')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Blank().width(24)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: 1 })
  }

  @Builder
  buildStylesGrid() {
    Scroll() {
      Column({ space: 16 }) {
        // 介绍卡片
        this.buildIntroCard()

        // 风格网格
        Grid() {
          ForEach(this.wrappingStyles, (style: WrappingStyle) => {
            GridItem() {
              this.buildStyleCard(style)
            }
          }, (style: WrappingStyle) => style.id)
        }
        .columnsTemplate('1fr 1fr')
        .rowsGap(12)
        .columnsGap(12)
        .width('100%')
      }
      .padding(16)
    }
    .width('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  buildIntroCard() {
    Column({ space: 12 }) {
      Text('包装艺术')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2C3E50')

      Text('精美的包装是礼物的第一印象，选择合适的包装风格能让你的心意更好地传达。')
        .fontSize(14)
        .fontColor('#7F8C8D')
        .lineHeight(20)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildStyleCard(style: WrappingStyle) {
    Column({ space: 8 }) {
      // 图片
      Image(style.image)
        .width('100%')
        .height(100)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)

      // 标题和难度
      Row() {
        Text(style.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2C3E50')
          .layoutWeight(1)

        Text(style.difficulty)
          .fontSize(10)
          .fontColor(this.getDifficultyColor(style.difficulty))
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor(this.getDifficultyBgColor(style.difficulty))
          .borderRadius(8)
      }
      .width('100%')

      // 描述
      Text(style.description)
        .fontSize(12)
        .fontColor('#7F8C8D')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(16)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      this.selectedStyle = style;
      this.showStyleDetail = true;
    })
  }

  @Builder
  buildOccasionsList() {
    List({ space: 12 }) {
      ForEach(this.occasions, (occasion: WrappingOccasion) => {
        ListItem() {
          this.buildOccasionCard(occasion)
        }
      }, (occasion: WrappingOccasion) => occasion.id)
    }
    .width('100%')
    .padding(16)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildOccasionCard(occasion: WrappingOccasion) {
    Column({ space: 12 }) {
      Text(occasion.name)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2C3E50')

      Text(occasion.description)
        .fontSize(14)
        .fontColor('#7F8C8D')
        .lineHeight(18)

      // 推荐风格
      Column({ space: 8 }) {
        Text('推荐风格')
          .fontSize(12)
          .fontColor('#95A5A6')

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(occasion.recommendedStyles, (style: string) => {
            Text(style)
              .fontSize(12)
              .fontColor('#FF6B35')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('#FFF0ED')
              .borderRadius(12)
          }, (style: string) => style)
        }
      }
      .alignItems(HorizontalAlign.Start)

      // 配色方案
      Column({ space: 8 }) {
        Text('配色方案')
          .fontSize(12)
          .fontColor('#95A5A6')

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(occasion.colorSchemes, (color: string) => {
            Text(color)
              .fontSize(12)
              .fontColor('#4CAF50')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('#E8F5E8')
              .borderRadius(12)
          }, (color: string) => color)
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildToolsAndTips() {
    Scroll() {
      Column({ space: 16 }) {
        // 必备工具
        this.buildToolsSection()

        // 包装技巧
        this.buildTipsSection()

        // 材料选择
        this.buildMaterialsSection()
      }
      .padding(16)
    }
    .width('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  buildToolsSection() {
    Column({ space: 12 }) {
      Text('必备工具')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2C3E50')

      Grid() {
        GridItem() {
          this.buildToolItem('剪刀', '锋利的剪刀', $r('app.media.icon_tools'))
        }
        GridItem() {
          this.buildToolItem('双面胶', '透明胶带', $r('app.media.icon_tools'))
        }
        GridItem() {
          this.buildToolItem('尺子', '测量工具', $r('app.media.icon_tools'))
        }
        GridItem() {
          this.buildToolItem('打孔器', '装饰打孔', $r('app.media.icon_tools'))
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(8)
      .columnsGap(8)
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildToolItem(name: string, desc: string, icon: Resource) {
    Column({ space: 4 }) {
      Image(icon)
        .width(32)
        .height(32)
        .fillColor('#FF6B35')

      Text(name)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2C3E50')

      Text(desc)
        .fontSize(10)
        .fontColor('#7F8C8D')
    }
    .padding(8)
    .backgroundColor('#F8F9FA')
    .borderRadius(8)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildTipsSection() {
    Column({ space: 12 }) {
      Text('包装技巧')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2C3E50')

      Column({ space: 8 }) {
        this.buildTipItem('测量准确', '包装纸要比礼物大2-3厘米')
        this.buildTipItem('折痕清晰', '用尺子压出清晰的折痕')
        this.buildTipItem('胶带隐藏', '胶带要贴在不显眼的地方')
        this.buildTipItem('装饰适度', '装饰不宜过多，简约为美')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildTipItem(title: string, content: string) {
    Row({ space: 8 }) {
      Circle({ width: 6, height: 6 })
        .fill('#FF6B35')

      Column({ space: 2 }) {
        Text(title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2C3E50')

        Text(content)
          .fontSize(12)
          .fontColor('#7F8C8D')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  buildMaterialsSection() {
    Column({ space: 12 }) {
      Text('材料选择')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2C3E50')

      Text('选择合适的包装材料是成功包装的关键，不同材料适合不同的场合和礼物类型。')
        .fontSize(14)
        .fontColor('#7F8C8D')
        .lineHeight(18)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildStyleDetailDialog() {
    if (this.selectedStyle) {
      Column() {
        // 遮罩
        Stack() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#80000000')
            .onClick(() => {
              this.showStyleDetail = false;
            })

          // 详情内容
          Column({ space: 16 }) {
            // 标题
            Row() {
              Text(this.selectedStyle.name)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2C3E50')
                .layoutWeight(1)

              Image($r('app.media.icon_close'))
                .width(24)
                .height(24)
                .fillColor('#7F8C8D')
                .onClick(() => {
                  this.showStyleDetail = false;
                })
            }
            .width('100%')

            // 详情内容滚动区域
            Scroll() {
              Column({ space: 16 }) {
                // 图片
                Image(this.selectedStyle.image)
                  .width('100%')
                  .height(200)
                  .borderRadius(8)
                  .objectFit(ImageFit.Cover)

                // 描述
                Text(this.selectedStyle.description)
                  .fontSize(14)
                  .fontColor('#7F8C8D')
                  .lineHeight(18)

                // 材料清单
                Column({ space: 8 }) {
                  Text('所需材料')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#2C3E50')

                  ForEach(this.selectedStyle.materials, (material: string) => {
                    Row({ space: 8 }) {
                      Circle({ width: 4, height: 4 })
                        .fill('#FF6B35')

                      Text(material)
                        .fontSize(14)
                        .fontColor('#2C3E50')
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Center)
                  }, (material: string) => material)
                }
                .alignItems(HorizontalAlign.Start)

                // 制作步骤
                Column({ space: 8 }) {
                  Text('制作步骤')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#2C3E50')

                  ForEach(this.selectedStyle.steps, (step: string, index: number) => {
                    Row({ space: 8 }) {
                      Text((index + 1).toString())
                        .fontSize(12)
                        .fontColor(Color.White)
                        .width(20)
                        .height(20)
                        .textAlign(TextAlign.Center)
                        .backgroundColor('#FF6B35')
                        .borderRadius(10)

                      Text(step)
                        .fontSize(14)
                        .fontColor('#2C3E50')
                        .layoutWeight(1)
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Top)
                  }, (step: string, index: number) => index.toString())
                }
                .alignItems(HorizontalAlign.Start)

                // 小贴士
                Column({ space: 8 }) {
                  Text('小贴士')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#2C3E50')

                  ForEach(this.selectedStyle.tips, (tip: string) => {
                    Row({ space: 8 }) {
                      Image($r('app.media.icon_tools'))
                        .width(16)
                        .height(16)
                        .fillColor('#4CAF50')

                      Text(tip)
                        .fontSize(14)
                        .fontColor('#2C3E50')
                        .layoutWeight(1)
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Top)
                  }, (tip: string) => tip)
                }
                .alignItems(HorizontalAlign.Start)
              }
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
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
  }

  // 获取难度颜色
  getDifficultyColor(difficulty: string): string {
    switch (difficulty) {
      case '简单':
        return '#4CAF50';
      case '中等':
        return '#FF9800';
      case '困难':
        return '#F44336';
      default:
        return '#7F8C8D';
    }
  }

  // 获取难度背景色
  getDifficultyBgColor(difficulty: string): string {
    switch (difficulty) {
      case '简单':
        return '#E8F5E8';
      case '中等':
        return '#FFF3E0';
      case '困难':
        return '#FFEBEE';
      default:
        return '#F5F5F5';
    }
  }
}