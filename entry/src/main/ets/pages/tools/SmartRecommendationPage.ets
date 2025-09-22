import router from '@ohos.router';

interface GiftSuggestion {
  id: string;
  name: string;
  category: string;
  price: string;
  reason: string;
  image: Resource;
  rating: number;
}

@Entry
@Component
struct SmartRecommendationPage {
  @State suggestions: GiftSuggestion[] = [];
  @State isAnalyzing: boolean = true;
  @State userAnswers: Record<string, string> = {};

  aboutToAppear() {
    // 获取从问题页面传递的用户回答
    const params = router.getParams() as Record<string, string | number | boolean>;
    if (params && params.answers && typeof params.answers === 'object') {
      this.userAnswers = params.answers as Record<string, string>;
      this.generateRecommendations();
    } else {
      // 如果没有参数，直接显示默认推荐
      this.generateRecommendations();
    }
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

        Text('推荐结果')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .textAlign(TextAlign.Center)
        Blank().width(40)
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      if (this.isAnalyzing) {
        // 分析中状态
        Column() {
          LoadingProgress()
            .width(60)
            .height(60)
            .color('#FF6B35')

          Text('正在分析中...')
            .fontSize(16)
            .fontColor('#333333')
            .margin({ top: 20 })

          Text('根据您的回答为您推荐最合适的礼物')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 推荐结果
        this.buildResultsView();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }



  @Builder
  buildResultsView() {
    Scroll() {
      Column() {
        // 结果标题
        Text('为您推荐以下礼物')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 20 })

        // 推荐列表
        ForEach(this.suggestions, (suggestion: GiftSuggestion) => {
          Column() {
            Row() {
              Image(suggestion.image)
                .width(80)
                .height(80)
                .borderRadius(8)
                .backgroundColor('#F0F0F0')

              Column() {
                Text(suggestion.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .alignSelf(ItemAlign.Start)

                Text(suggestion.category)
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 4 })
                  .alignSelf(ItemAlign.Start)

                // 评分
                Row() {
                  ForEach([0, 1, 2, 3, 4], (starIndex: number) => {
                    Text('⭐')
                      .fontSize(12)
                      .fontColor(starIndex < suggestion.rating ? '#FFD700' : '#E0E0E0')
                  }, (starIndex: number) => starIndex.toString())
                }
                .margin({ top: 4 })
              }
              .layoutWeight(1)
              .margin({ left: 12 })
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)

            Text(`推荐理由：${suggestion.reason}`)
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 12 })
              .alignSelf(ItemAlign.Start)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 12 })
        })
      }
      .width('100%')
      .padding(20)
    }
  }



  private generateRecommendations(): void {
    this.isAnalyzing = true;
    
    setTimeout(() => {
      // 根据用户回答生成个性化推荐
      this.suggestions = this.getPersonalizedRecommendations();
      this.isAnalyzing = false;
    }, 2000);
  }

  private getPersonalizedRecommendations(): GiftSuggestion[] {
    // 根据用户回答生成个性化推荐
    const recipient = this.userAnswers['recipient'] || '朋友';
    const occasion = this.userAnswers['occasion'] || '生日';
    
    const allRecommendations: GiftSuggestion[] = [
      {
        id: '1',
        name: '施华洛世奇水晶项链',
        category: '首饰',
        price: '￥299',
        reason: `根据您选择的${recipient}和${occasion}，水晶象征纯洁与永恒，表达对爱情的美好祝愿`,
        image: $r('app.media.shlsq'),
        rating: 4.8
      },
      {
        id: '2',
        name: 'AirPods Pro 无线耳机',
        category: '电子产品',
        price: '￥1899',
        reason: '科技产品代表对未来的期许和对品质生活的追求',
        image: $r('app.media.airpod'),
        rating: 4.7
      },
      {
        id: '3',
        name: '永生花玻璃罩礼盒',
        category: '鲜花',
        price: '￥168',
        reason: '永生花象征永恒不变的爱情和美好回忆',
        image: $r('app.media.ysh'),
        rating: 4.6
      },
      {
        id: '4',
        name: '圣诞主题香薰蜡烛套装',
        category: '家居用品',
        price: '￥89',
        reason: '香薰蜡烛代表温暖和光明，为节日增添温馨氛围',
        image: $r('app.media.shengdan'),
        rating: 4.5
      },
      {
        id: '5',
        name: '圣诞雪花球音乐盒',
        category: '玩具',
        price: '￥128',
        reason: '雪花球象征着纯洁和美好愿望，音乐带来节日欢乐',
        image: $r('app.media.sjt'),
        rating: 4.7
      },
      {
        id: '6',
        name: '圣诞毛绒玩具礼盒',
        category: '玩具',
        price: '￥158',
        reason: '毛绒玩具代表温暖的陪伴和童真的快乐',
        image: $r('app.media.sdwj'),
        rating: 4.8
      },
      {
        id: '7',
        name: '圣诞热红酒香料包',
        category: '美食',
        price: '￥68',
        reason: '热红酒是圣诞节的传统饮品，象征温暖和团聚',
        image: $r('app.media.rhj'),
        rating: 4.4
      },
      {
        id: '8',
        name: '手写感谢卡片套装',
        category: '文具',
        price: '￥35',
        reason: '手写卡片传达最真挚的感谢之情，心意比价值更重要',
        image: $r('app.media.creative_fun_gift'),
        rating: 4.6
      },
      {
        id: '9',
        name: '精品茶叶礼盒',
        category: '美食',
        price: '￥128',
        reason: '茶叶代表清香淡雅，表达对对方的尊重和感谢',
        image: $r('app.media.cylh'),
        rating: 4.7
      },
      {
        id: '10',
        name: '多肉植物组合盆栽',
        category: '鲜花',
        price: '￥88',
        reason: '植物象征生命力和成长，感谢对方给予的帮助和支持',
        image: $r('app.media.drzw'),
        rating: 4.5
      },
      {
        id: '11',
        name: '定制感谢巧克力礼盒',
        category: '美食',
        price: '￥98',
        reason: '巧克力的甜蜜如同感谢的心情，定制文字更显用心',
        image: $r('app.media.qkllh'),
        rating: 4.6
      },
      {
        id: '12',
        name: '情侣对杯套装',
        category: '家居用品',
        price: '￥168',
        reason: '对杯象征夫妻恩爱，共饮一杯茶，共度一生情',
        image: $r('app.media.qldb'),
        rating: 4.7
      },
      {
        id: '13',
        name: '新婚床品四件套',
        category: '家居用品',
        price: '￥299',
        reason: '红色床品寓意新婚生活红红火火，幸福美满',
        image: $r('app.media.wedding_blessing_gift'),
        rating: 4.8
      },
      {
        id: '14',
        name: '水晶相框对装',
        category: '家居用品',
        price: '￥188',
        reason: '相框保存美好回忆，水晶象征纯洁透明的爱情',
        image: $r('app.media.sjxk'),
        rating: 4.6
      },
      {
        id: '15',
        name: '高档餐具套装',
        category: '家居用品',
        price: '￥588',
        reason: '餐具套装寓意新人共同用餐，分享生活的点点滴滴',
        image: $r('app.media.gdcj'),
        rating: 4.9
      },
      {
        id: '16',
        name: '情侣香薰机套装',
        category: '电子产品',
        price: '￥398',
        reason: '香薰营造温馨氛围，智能科技提升生活品质',
        image: $r('app.media.qlxxj'),
        rating: 4.5
      }
    ];

    // 从16个推荐中随机选择1个
    const randomIndex = Math.floor(Math.random() * allRecommendations.length);
    return [allRecommendations[randomIndex]];
  }

  private resetRecommendation(): void {
    // 返回到问题页面重新开始
    router.pushUrl({
      url: 'pages/tools/SmartRecommendationQuestionPage'
    }).catch((error: Error) => {
      console.error('Failed to navigate to question page:', error);
    });
  }
}