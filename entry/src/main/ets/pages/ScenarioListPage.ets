import { Scenario } from '../model/GiftModel';
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
struct ScenarioListPage {
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
      description: '温馨节日的欢乐礼物',
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

  build() {
    Column() {
      // 标题栏
      this.buildHeader()
      
      // 场景选择页
      this.buildScenarioGrid()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
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
        router.back();
      })
      
      Text('场景分类')
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
  buildScenarioGrid() {
    Column() {
      Text('选择送礼场景')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#666666')
        .margin({ top: 20, bottom: 20 })
      
      Grid() {
        ForEach(this.scenarios, (scenario: ScenarioInfo) => {
          GridItem() {
            this.buildScenarioCard(scenario)
          }
        }, (scenario: ScenarioInfo) => scenario.key.toString())
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(16)
      .columnsGap(16)
      .width('90%')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildScenarioCard(scenario: ScenarioInfo) {
    Column() {
      Text(scenario.icon)
        .fontSize(40)
        .margin({ bottom: 12 })
      
      Text(scenario.name)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ bottom: 8 })
      
      Text(scenario.description)
        .fontSize(12)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .opacity(0.9)
        .lineHeight(16)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(140)
    .backgroundColor(scenario.color)
    .borderRadius(16)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(16)
    .onClick(() => {
      // 跳转到礼物列表页面，传递选中的场景
      router.pushUrl({
        url: 'pages/ScenarioPage',
        params: {
          scenario: scenario.key,
          scenarioName: scenario.name
        }
      }).catch((error: Error) => {
        console.error('Failed to navigate to ScenarioPage:', error);
      });
    })
  }
}