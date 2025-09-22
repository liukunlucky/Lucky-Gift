import router from '@ohos.router';

interface HolidayGuide {
  id: string;
  name: string;
  date: string;
  icon: string;
  description: string;
  giftSuggestions: GiftCategory[];
  tips: string[];
}

interface GiftCategory {
  category: string;
  items: string[];
  priceRange: string;
}

@Entry
@Component
struct HolidayGuidePage {
  @State holidays: HolidayGuide[] = [];
  @State selectedHoliday: HolidayGuide | null = null;
  @State showDetail: boolean = false;

  aboutToAppear() {
    this.loadHolidays();
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
          if (this.showDetail) {
            this.showDetail = false;
            this.selectedHoliday = null;
          } else {
            router.back();
          }
        })

        Text(this.showDetail ? this.selectedHoliday?.name : '节日礼物指南')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(40)
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      if (this.showDetail && this.selectedHoliday) {
        this.buildHolidayDetail();
      } else {
        this.buildHolidayList();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  @Builder
  buildHolidayList() {
    Scroll() {
      Column() {
        // 页面标题
        Text('选择节日，获取专属送礼指南')
          .fontSize(16)
          .fontColor('#666666')
          .textAlign(TextAlign.Center)
          .margin({ top: 20, bottom: 30 })

        // 节日列表
        ForEach(this.holidays, (holiday: HolidayGuide) => {
          Row() {
            Text(holiday.icon)
              .fontSize(32)
              .margin({ right: 16 })

            Column() {
              Text(holiday.name)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)

              Text(holiday.date)
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 4 })
                .alignSelf(ItemAlign.Start)

              Text(holiday.description)
                .fontSize(14)
                .fontColor('#666666')
                .margin({ top: 8 })
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .alignSelf(ItemAlign.Start)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 12, left: 16, right: 16 })
          .alignItems(VerticalAlign.Top)
          .onClick(() => {
            this.selectedHoliday = holiday;
            this.showDetail = true;
          })
        })
      }
      .width('90%')
    }
    .layoutWeight(1)
  }

  @Builder
  buildHolidayDetail() {
    Scroll() {
      Column() {
        // 节日信息卡片
        Column() {
          Text(this.selectedHoliday!.icon)
            .fontSize(48)
            .margin({ bottom: 12 })

          Text(this.selectedHoliday!.name)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 8 })

          Text(this.selectedHoliday!.date)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 12 })

          Text(this.selectedHoliday!.description)
            .fontSize(14)
            .fontColor('#666666')
            .textAlign(TextAlign.Center)
            .lineHeight(20)
        }
        .width('100%')
        .padding(24)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ top: 16, bottom: 20, left: 16, right: 16 })

        // 礼物推荐分类
        Text('🎁 礼物推荐')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)
          .margin({ left: 16, bottom: 16 })

        ForEach(this.selectedHoliday!.giftSuggestions, (category: GiftCategory) => {
          Column() {
            Row() {
              Text(category.category)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Blank()

              Text(category.priceRange)
                .fontSize(12)
                .fontColor('#FF6B35')
                .backgroundColor('#FFF5F0')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(12)
            }
            .width('100%')
            .margin({ bottom: 12 })

            Column() {
              ForEach(category.items, (item: string) => {
                Row() {
                  Text('•')
                    .fontSize(14)
                    .fontColor('#FF6B35')
                    .margin({ right: 8 })

                  Text(item)
                    .fontSize(14)
                    .fontColor('#666666')
                    .layoutWeight(1)
                }
                .width('100%')
                .margin({ bottom: 6 })
                .alignItems(VerticalAlign.Top)
              })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 12, left: 16, right: 16 })
        })

        // 送礼小贴士
        Text('💡 送礼小贴士')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)
          .margin({ left: 16, top: 20, bottom: 16 })

        Column() {
          ForEach(this.selectedHoliday!.tips, (tip: string, index: number) => {
            Row() {
              Text(`${index + 1}`)
                .fontSize(12)
                .fontColor(Color.White)
                .backgroundColor('#FF6B35')
                .width(20)
                .height(20)
                .borderRadius(10)
                .textAlign(TextAlign.Center)
                .margin({ right: 12 })

              Text(tip)
                .fontSize(14)
                .fontColor('#666666')
                .layoutWeight(1)
                .lineHeight(20)
            }
            .width('100%')
            .margin({ bottom: 12 })
            .alignItems(VerticalAlign.Top)
          })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ bottom: 20, left: 16, right: 16 })

        // 底部按钮
        Row() {
          Button('智能推荐')
            .fontSize(16)
            .fontColor('#FF6B35')
            .backgroundColor('#FFF5F0')
            .borderRadius(25)
            .layoutWeight(1)
            .height(50)
            .margin({ right: 8 })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/tools/SmartRecommendationQuestionPage'
              });
            })

          Button('预算计算')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor('#FF6B35')
            .borderRadius(25)
            .layoutWeight(1)
            .height(50)
            .margin({ left: 8 })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/tools/BudgetCalculatorPage'
              });
            })
        }
        .width('100%')
        .visibility(Visibility.None)
        .padding({ left: 16, right: 16, bottom: 20 })
      }
      .width('100%')
    }
    .layoutWeight(1)
  }

  private loadHolidays(): void {
    this.holidays = [
      {
        id: '1',
        name: '情人节',
        date: '2月14日',
        icon: '💕',
        description: '表达爱意的浪漫节日，适合送给恋人或配偶的温馨礼物',
        giftSuggestions: [
          {
            category: '浪漫礼品',
            items: ['玫瑰花束', '情侣戒指', '香水', '巧克力礼盒', '情侣手表'],
            priceRange: '100-1000元'
          },
          {
            category: '体验类',
            items: ['烛光晚餐', '情侣SPA', '电影票', '旅行套餐'],
            priceRange: '200-2000元'
          },
          {
            category: '个性定制',
            items: ['定制照片书', '刻字饰品', '情侣T恤', '星座项链'],
            priceRange: '50-500元'
          }
        ],
        tips: [
          '提前预订餐厅和酒店，避免节日当天没有位置',
          '选择有纪念意义的礼物，比如第一次约会的地方相关物品',
          '包装要精美，红色和粉色是经典选择',
          '准备一张手写的情书或贺卡，表达真挚情感'
        ]
      },
      {
        id: '2',
        name: '母亲节',
        date: '5月第二个周日',
        icon: '🌸',
        description: '感恩母亲的节日，表达对母亲的爱与感激',
        giftSuggestions: [
          {
            category: '护肤美容',
            items: ['护肤套装', '面膜礼盒', '口红', '香水', '美容仪器'],
            priceRange: '100-800元'
          },
          {
            category: '健康养生',
            items: ['按摩器', '足浴盆', '保健品', '养生茶', '瑜伽垫'],
            priceRange: '150-1000元'
          },
          {
            category: '生活用品',
            items: ['丝巾', '包包', '首饰盒', '家居装饰', '鲜花'],
            priceRange: '80-600元'
          }
        ],
        tips: [
          '了解妈妈最近的需求和喜好',
          '选择实用性强的礼物，让妈妈经常能用到',
          '陪伴是最好的礼物，安排一起度过的时光',
          '准备一顿妈妈爱吃的饭菜'
        ]
      },
      {
        id: '3',
        name: '父亲节',
        date: '6月第三个周日',
        icon: '👔',
        description: '向父亲表达敬意和感谢的节日',
        giftSuggestions: [
          {
            category: '商务用品',
            items: ['领带', '钱包', '公文包', '钢笔', '袖扣'],
            priceRange: '100-800元'
          },
          {
            category: '兴趣爱好',
            items: ['茶具', '酒类', '书籍', '运动用品', '钓鱼装备'],
            priceRange: '150-1500元'
          },
          {
            category: '健康关怀',
            items: ['按摩椅', '血压计', '保健品', '运动手环'],
            priceRange: '200-3000元'
          }
        ],
        tips: [
          '选择符合父亲年龄和身份的礼物',
          '实用性是关键，避免过于花哨的物品',
          '可以选择和父亲一起体验的活动',
          '表达对父亲辛苦付出的感谢'
        ]
      },
      {
        id: '4',
        name: '生日',
        date: '全年',
        icon: '🎂',
        description: '庆祝生命的特殊日子，个性化礼物最受欢迎',
        giftSuggestions: [
          {
            category: '个性定制',
            items: ['定制蛋糕', '照片相册', '刻字礼品', '星座饰品'],
            priceRange: '50-500元'
          },
          {
            category: '兴趣相关',
            items: ['书籍', '游戏', '乐器', '运动装备', '手工材料'],
            priceRange: '100-1000元'
          },
          {
            category: '体验礼品',
            items: ['演唱会门票', '旅行', '课程学习', '美食体验'],
            priceRange: '200-2000元'
          }
        ],
        tips: [
          '根据对方的兴趣爱好选择礼物',
          '生日蛋糕和生日歌是必不可少的',
          '可以组织惊喜派对增加仪式感',
          '记录美好时刻，拍照留念'
        ]
      },
      {
        id: '5',
        name: '圣诞节',
        date: '12月25日',
        icon: '🎄',
        description: '充满温馨和祝福的节日，适合家人朋友间的礼物交换',
        giftSuggestions: [
          {
            category: '节日装饰',
            items: ['圣诞树', '彩灯', '装饰品', '圣诞袜', '花环'],
            priceRange: '30-300元'
          },
          {
            category: '温暖礼品',
            items: ['围巾', '手套', '毛毯', '保温杯', '暖手宝'],
            priceRange: '50-400元'
          },
          {
            category: '美食礼盒',
            items: ['巧克力', '坚果礼盒', '红酒', '咖啡', '饼干'],
            priceRange: '80-600元'
          }
        ],
        tips: [
          '红色和绿色是圣诞节的经典颜色',
          '可以准备小礼物进行交换游戏',
          '营造温馨的节日氛围很重要',
          '准备圣诞大餐和家人朋友一起分享'
        ]
      }
    ];
  }
}