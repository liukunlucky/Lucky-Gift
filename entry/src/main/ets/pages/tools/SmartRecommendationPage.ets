import router from '@ohos.router';

interface RecommendationQuestion {
  id: string;
  question: string;
  options: string[];
  selectedOption: string;
}

interface GiftSuggestion {
  id: string;
  name: string;
  category: string;
  price: string;
  reason: string;
  image: string;
  rating: number;
}

@Entry
@Component
struct SmartRecommendationPage {
  @State currentStep: number = 0;
  @State questions: RecommendationQuestion[] = [];
  @State suggestions: GiftSuggestion[] = [];
  @State isAnalyzing: boolean = false;
  @State showResults: boolean = false;

  aboutToAppear() {
    this.loadQuestions();
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

        Text('🤖 智能礼物推荐')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button() {
          Text('重新开始')
            .fontSize(14)
            .fontColor('#FF6B35')
        }
        .width(80)
        .height(32)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.resetRecommendation();
        })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      if (this.isAnalyzing) {
        // 分析中状态
        Column() {
          LoadingProgress()
            .width(60)
            .height(60)
            .color('#FF6B35')

          Text('AI正在分析中...')
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
      } else if (this.showResults) {
        // 推荐结果
        this.buildResultsView();
      } else {
        // 问答流程
        this.buildQuestionView();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  @Builder
  buildQuestionView() {
    Column() {
      // 进度指示器
      Row() {
        Text(`${this.currentStep + 1}/${this.questions.length}`)
          .fontSize(14)
          .fontColor('#666666')

        Blank()

        Progress({
          value: this.currentStep + 1,
          total: this.questions.length,
          type: ProgressType.Linear
        })
          .width(200)
          .height(4)
          .color('#FF6B35')
          .backgroundColor('#F0F0F0')
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Color.White)

      Scroll() {
        Column() {
          if (this.currentStep < this.questions.length) {
            Text(this.questions[this.currentStep].question)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 30 })

            // 选项列表
            Column() {
              ForEach(this.questions[this.currentStep].options, (option: string, index: number) => {
                Row() {
                  Text(option)
                    .fontSize(16)
                    .fontColor(this.questions[this.currentStep].selectedOption === option ? '#FF6B35' : '#333333')
                    .layoutWeight(1)

                  if (this.questions[this.currentStep].selectedOption === option) {
                    Image($r('app.media.icon_check'))
                      .width(20)
                      .height(20)
                      .fillColor('#FF6B35')
                  }
                }
                .width('100%')
                .height(60)
                .padding({ left: 20, right: 20 })
                .backgroundColor(this.questions[this.currentStep].selectedOption === option ? '#FFF5F0' : Color.White)
                .borderRadius(12)
                .border({
                  width: 2,
                  color: this.questions[this.currentStep].selectedOption === option ? '#FF6B35' : '#F0F0F0'
                })
                .margin({ bottom: 12 })
                .onClick(() => {
                  this.selectOption(this.questions[this.currentStep].id, option);
                })
              }, (option: string) => option)
            }
            .width('100%')
          }
        }
        .width('100%')
        .padding(20)
      }
      .layoutWeight(1)

      // 底部按钮
      Row() {
        if (this.currentStep > 0) {
          Button('上一步')
            .fontSize(16)
            .fontColor('#666666')
            .backgroundColor('#F0F0F0')
            .borderRadius(25)
            .width(100)
            .height(50)
            .onClick(() => {
              this.previousStep();
            })
        }

        Blank()

        Button(this.currentStep === this.questions.length - 1 ? '获取推荐' : '下一步')
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor(this.canProceed() ? '#FF6B35' : '#CCCCCC')
          .borderRadius(25)
          .width(120)
          .height(50)
          .enabled(this.canProceed())
          .onClick(() => {
            if (this.currentStep === this.questions.length - 1) {
              this.generateRecommendations();
            } else {
              this.nextStep();
            }
          })
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Color.White)
    }
  }

  @Builder
  buildResultsView() {
    Scroll() {
      Column() {
        // 结果标题
        Text('🎁 为您推荐以下礼物')
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

                Text(suggestion.price)
                  .fontSize(14)
                  .fontColor('#FF6B35')
                  .fontWeight(FontWeight.Medium)
                  .margin({ top: 8 })
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

            Button('查看详情')
              .fontSize(14)
              .fontColor('#FF6B35')
              .backgroundColor('#FFF5F0')
              .borderRadius(20)
              .height(36)
              .width(100)
              .margin({ top: 12 })
              .alignSelf(ItemAlign.End)
              .onClick(() => {
                console.info('查看礼物详情:', suggestion.id);
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 12 })
        })

        // 重新推荐按钮
        Button('重新推荐')
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#FF6B35')
          .borderRadius(25)
          .width(200)
          .height(50)
          .margin({ top: 20, bottom: 20 })
          .onClick(() => {
            this.resetRecommendation();
          })
      }
      .width('100%')
      .padding(20)
    }
    .layoutWeight(1)
  }

  private loadQuestions(): void {
    this.questions = [
      {
        id: '1',
        question: '您要送礼给谁？',
        options: ['恋人/配偶', '家人', '朋友', '同事', '长辈'],
        selectedOption: ''
      },
      {
        id: '2',
        question: '什么场合送礼？',
        options: ['生日', '节日庆祝', '纪念日', '感谢/道歉', '日常表达'],
        selectedOption: ''
      },
      {
        id: '3',
        question: '您的预算范围？',
        options: ['50元以下', '50-200元', '200-500元', '500-1000元', '1000元以上'],
        selectedOption: ''
      },
      {
        id: '4',
        question: '收礼人的性别？',
        options: ['男性', '女性', '不确定'],
        selectedOption: ''
      },
      {
        id: '5',
        question: '收礼人的年龄段？',
        options: ['儿童(0-12岁)', '青少年(13-18岁)', '青年(19-35岁)', '中年(36-55岁)', '老年(55岁以上)'],
        selectedOption: ''
      }
    ];
  }

  private selectOption(questionId: string, option: string): void {
    const questionIndex = this.questions.findIndex(q => q.id === questionId);
    if (questionIndex !== -1) {
      this.questions[questionIndex].selectedOption = option;
    }
  }

  private canProceed(): boolean {
    if (this.currentStep < this.questions.length) {
      return this.questions[this.currentStep].selectedOption !== '';
    }
    return false;
  }

  private nextStep(): void {
    if (this.currentStep < this.questions.length - 1) {
      this.currentStep++;
    }
  }

  private previousStep(): void {
    if (this.currentStep > 0) {
      this.currentStep--;
    }
  }

  private generateRecommendations(): void {
    this.isAnalyzing = true;
    
    // 模拟AI分析过程
    setTimeout(() => {
      this.suggestions = [
        {
          id: '1',
          name: '定制照片相册',
          category: '纪念品',
          price: '￥128',
          reason: '根据您的选择，这是一份充满回忆和个人意义的礼物',
          image: '',
          rating: 5
        },
        {
          id: '2',
          name: '香薰蜡烛套装',
          category: '生活用品',
          price: '￥89',
          reason: '营造温馨氛围，适合表达关怀之意',
          image: '',
          rating: 4
        },
        {
          id: '3',
          name: '手工巧克力礼盒',
          category: '美食',
          price: '￥156',
          reason: '甜蜜的味道传递甜蜜的心意',
          image: '',
          rating: 4
        }
      ];
      
      this.isAnalyzing = false;
      this.showResults = true;
    }, 2000);
  }

  private resetRecommendation(): void {
    this.currentStep = 0;
    this.showResults = false;
    this.isAnalyzing = false;
    this.suggestions = [];
    this.questions.forEach(question => {
      question.selectedOption = '';
    });
  }
}