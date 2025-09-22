import router from '@ohos.router';

interface RecommendationQuestion {
  id: string;
  question: string;
  options: string[];
  selectedOption: string;
}

@Entry
@Component
struct SmartRecommendationQuestionPage {
  @State currentStep: number = 0;
  @State questions: RecommendationQuestion[] = [];

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

        Text('智能礼物推荐')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .textAlign(TextAlign.Center)

        Button() {
          Image($r('app.media.icon_reset'))
            .width(24)
            .height(24)
            .fillColor('#333333')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.resetRecommendation();
        })
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      this.buildQuestionView();
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
            ForEach(this.questions[this.currentStep].options, (option: string, _index: number) => {
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
      .constraintSize({ minHeight: '60%' })

      // 底部按钮 - 固定在底部
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
      .padding({ left: 20, right: 20, top: 16, bottom: 20 })
      .backgroundColor(Color.White)
      .shadow({
        radius: 8,
        color: '#1A000000',
        offsetX: 0,
        offsetY: -2
      })
    }
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
    // 使用响应式更新方法 - 创建新数组触发UI更新
    const updatedQuestions: RecommendationQuestion[] = [];
    for (const question of this.questions) {
      if (question.id === questionId) {
        const updatedQuestion: RecommendationQuestion = {
          id: question.id,
          question: question.question,
          options: question.options,
          selectedOption: option
        };
        updatedQuestions.push(updatedQuestion);
      } else {
        updatedQuestions.push(question);
      }
    }
    this.questions = updatedQuestions;
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

    setTimeout(() => {
      // 收集用户的回答
      const answers: Record<string, string> = {};
      for (const question of this.questions) {
        answers[question.id] = question.selectedOption;
      }
      
      // 跳转到结果页面，传递用户回答
      router.pushUrl({
        url: 'pages/tools/SmartRecommendationPage',
        params: {
          answers: answers
        }
      }).catch((error: Error) => {
        console.error('Failed to navigate to results page:', error);
      });
    }, 10);
  }

  private resetRecommendation(): void {
    this.currentStep = 0;
    this.questions.forEach(question => {
      question.selectedOption = '';
    });
  }
}