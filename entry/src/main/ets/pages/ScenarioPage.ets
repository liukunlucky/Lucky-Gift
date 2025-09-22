import { Gift, Scenario, GiftCategory, PriceRange } from '../model/GiftModel';
import { GiftRecommendationService } from '../service/GiftRecommendationService';
import router from '@ohos.router';

// 场景信息接口
interface ScenarioInfo {
  key: Scenario;
  name: string;
  icon: string;
  description: string;
  color: string;
  tips: string[];
}

@Entry
@Component
struct ScenarioPage {
  @State private selectedScenario: Scenario | undefined = undefined;
  @State private scenarioName: string = '';
  @State private scenarioGifts: Gift[] = [];
  @State private loading: boolean = false;
  
  private giftService = GiftRecommendationService.getInstance();
  
  // 场景数据
  private scenarios: ScenarioInfo[] = [
    {
      key: Scenario.BIRTHDAY,
      name: '生日礼物',
      icon: '🎂',
      description: '为生日庆祝挑选完美礼物',
      color: '#FF6B6B',
      tips: ['根据年龄选择', '考虑个人兴趣', '注重纪念意义']
    },
    {
      key: Scenario.VALENTINE,
      name: '情人节',
      icon: '💝',
      description: '表达爱意的浪漫礼物',
      color: '#E91E63',
      tips: ['浪漫为主', '个性化定制', '情感价值重于价格']
    },
    {
      key: Scenario.ANNIVERSARY,
      name: '纪念日',
      icon: '💍',
      description: '纪念重要时刻的特殊礼物',
      color: '#9C27B0',
      tips: ['纪念意义', '保存价值', '情感共鸣']
    },
    {
      key: Scenario.CHRISTMAS,
      name: '圣诞节',
      icon: '🎄',
      description: '温馨节日的祝福礼物',
      color: '#4CAF50',
      tips: ['节日氛围', '家庭温馨', '分享快乐']
    },
    {
      key: Scenario.GRADUATION,
      name: '毕业礼物',
      icon: '🎓',
      description: '庆祝学业成就的励志礼物',
      color: '#2196F3',
      tips: ['实用性强', '励志意义', '未来导向']
    },
    {
      key: Scenario.WEDDING,
      name: '婚礼礼物',
      icon: '💒',
      description: '祝福新人的美好礼物',
      color: '#FF9800',
      tips: ['成双成对', '实用家居', '美好寓意']
    },
    {
      key: Scenario.THANK_YOU,
      name: '感谢礼物',
      icon: '🙏',
      description: '表达感激之情的贴心礼物',
      color: '#607D8B',
      tips: ['心意为重', '实用贴心', '不宜过贵']
    },
    {
      key: Scenario.APOLOGY,
      name: '道歉礼物',
      icon: '🌹',
      description: '表达歉意的诚意礼物',
      color: '#795548',
      tips: ['诚意为先', '对方喜好', '适度价值']
    }
  ];

  aboutToAppear() {
    // 检查是否有传入的场景参数
    const params = router.getParams() as Record<string, Object>;
    if (params && params['scenario']) {
      this.selectedScenario = params['scenario'] as Scenario;
      this.scenarioName = params['scenarioName'] as string || this.getScenarioName(this.selectedScenario);
      this.loadScenarioGifts();
    }
  }

  build() {
    Column() {
      // 标题栏
      this.buildHeader()
      
      // 场景详情页（礼物列表）
      this.buildScenarioDetail()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  goBack() {
    router.back();
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
        this.goBack()
      })
      
      Text(this.scenarioName || '礼物推荐')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      Blank().width(40)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
  }



  @Builder
  buildScenarioDetail() {
    Column() {
      // 场景介绍卡片
      this.buildScenarioIntro()
      
      // 推荐礼物列表
      this.buildGiftList()
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  buildScenarioIntro() {
    Column() {
      if (this.selectedScenario) {
        Row() {
          Text(this.getScenarioIcon())
            .fontSize(32)
            .margin({ right: 16 })
          
          Column() {
            Text(this.getScenarioName(this.selectedScenario))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
            
            Text(this.getScenarioDescription())
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 4 })
              .alignSelf(ItemAlign.Start)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        
        // 选礼贴士
        Column() {
          Text('选礼贴士')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })
          
          ForEach(this.getScenarioTips(), (tip: string, index: number) => {
            Row() {
              Text(`${index + 1}.`)
                .fontSize(12)
                .fontColor(this.getScenarioColor())
                .width(20)
              
              Text(tip)
                .fontSize(12)
                .fontColor('#666666')
                .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 4 })
          })
        }
        .width('100%')
        .margin({ top: 16 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 8, bottom: 16 })
  }

  @Builder
  buildGiftList() {
    Column() {
      Row() {
        Text('推荐礼物')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        
        Blank()
        
        Text(`共${this.scenarioGifts.length}件`)
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })
      
      if (this.loading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#4CAF50')
          
          Text('正在加载推荐礼物...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 16 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.scenarioGifts, (gift: Gift) => {
            ListItem() {
              this.buildGiftCard(gift)
            }
            .margin({ bottom: 12 })
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, bottom: 16 })
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  buildGiftCard(gift: Gift) {
    Row() {
      // 礼物图片占位
      Column() {
        Image(gift.imageUrl)
      }
      .width(80)
      .height(80)
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      
      // 礼物信息
      Column() {
        Text(gift.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Text(gift.description)
          .fontSize(12)
          .fontColor('#666666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })
        
        Row() {
          Row() {
            Text('⭐')
              .fontSize(12)
            Text(`${gift.rating}`)
              .fontSize(12)
              .fontColor('#666666')
            Text(`(${gift.reviewCount})`)
              .fontSize(10)
              .fontColor('#999999')
          }
        }
        .width('100%')
        .margin({ top: 8 })
        
        // 适用场景标签
        if (gift.meaning) {
          Text(`💝 ${gift.meaning}`)
            .fontSize(10)
            .fontColor('#4CAF50')
            .backgroundColor('#E8F5E8')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(8)
            .margin({ top: 4 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .onClick(() => {
      // 点击查看礼物详情
      console.log('查看礼物详情:', gift.name);
    })
  }

  private loadScenarioGifts() {
    if (!this.selectedScenario) return;
    
    this.loading = true;
    
    // 模拟异步加载
    setTimeout(() => {
      const response = this.giftService.getRecommendations({
        scenario: this.selectedScenario
      });
      this.scenarioGifts = response.gifts;
      this.loading = false;
    }, 500);
  }

  private getScenarioName(scenario: Scenario): string {
    const found = this.scenarios.find(s => s.key === scenario);
    return found ? found.name : '未知场景';
  }

  private getCurrentScenario(): ScenarioInfo | undefined {
    return this.scenarios.find(s => s.key === this.selectedScenario);
  }

  private getScenarioIcon(): string {
    const scenario = this.getCurrentScenario();
    return scenario ? scenario.icon : '🎁';
  }

  private getScenarioDescription(): string {
    const scenario = this.getCurrentScenario();
    return scenario ? scenario.description : '';
  }

  private getScenarioColor(): string {
    const scenario = this.getCurrentScenario();
    return scenario ? scenario.color : '#4CAF50';
  }

  private getScenarioTips(): string[] {
    const scenario = this.getCurrentScenario();
    return scenario ? scenario.tips : [];
  }
}