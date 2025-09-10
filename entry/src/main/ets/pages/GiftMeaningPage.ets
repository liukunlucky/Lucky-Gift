import { Gift, GiftCategory, Scenario } from '../model/GiftModel';
import { GiftRecommendationService } from '../service/GiftRecommendationService';
import router from '@ohos.router';

// 礼物含义信息接口
interface GiftMeaning {
  id: string;
  name: string;
  category: GiftCategory;
  symbolism: string; // 象征意义
  culturalBackground: string; // 文化背景
  occasions: Scenario[]; // 适用场合
  tips: string[]; // 送礼小贴士
  taboos: string[]; // 送礼禁忌
  image: string;
  color: string;
}

@Entry
@Component
struct GiftMeaningPage {
  @State selectedCategory: GiftCategory | null = null;
  @State giftMeanings: GiftMeaning[] = [];
  @State searchText: string = '';
  @State loading: boolean = false;
  private scroller: Scroller = new Scroller();
  private giftService: GiftRecommendationService = GiftRecommendationService.getInstance();

  aboutToAppear() {
    this.loadGiftMeanings();
  }

  build() {
    Column() {
      this.buildHeader()
      this.buildSearchBar()
      this.buildCategoryFilter()
      this.buildMeaningList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  @Builder
  buildHeader() {
    Row() {
      Text('←')
        .fontSize(24)
        .fontColor('#333333')
        .onClick(() => {
          router.back();
        })

      Text('礼物含义解读')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Row()
        .width(24)
        .height(24)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildSearchBar() {
    Row() {
      Text('🔍')
        .fontSize(20)
        .margin({ right: 8 })

      TextInput({ placeholder: '搜索礼物名称或含义' })
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .border({ width: 0 })
        .onChange((value: string) => {
          this.searchText = value;
          this.filterGiftMeanings();
        })
    }
    .width('100%')
    .height(44)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(22)
    .margin({ left: 16, right: 16, top: 16, bottom: 16 })
  }

  @Builder
  buildCategoryFilter() {
    Scroll(this.scroller) {
      Row() {
        this.buildCategoryChip('全部', null)
        this.buildCategoryChip('鲜花', GiftCategory.FLOWERS)
        this.buildCategoryChip('珠宝', GiftCategory.JEWELRY)
        this.buildCategoryChip('数码', GiftCategory.ELECTRONICS)
        this.buildCategoryChip('服饰', GiftCategory.CLOTHING)
        this.buildCategoryChip('美妆', GiftCategory.COSMETICS)
        this.buildCategoryChip('书籍', GiftCategory.BOOKS)
        this.buildCategoryChip('运动', GiftCategory.SPORTS)
        this.buildCategoryChip('家居', GiftCategory.HOME)
        this.buildCategoryChip('美食', GiftCategory.FOOD)
        this.buildCategoryChip('其他', GiftCategory.TOYS)
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .margin({ bottom: 16 })
  }

  @Builder
  buildCategoryChip(label: string, category: GiftCategory | null) {
    Text(label)
      .fontSize(14)
      .fontColor(this.selectedCategory === category ? Color.White : '#666666')
      .backgroundColor(this.selectedCategory === category ? '#4CAF50' : '#F0F0F0')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .borderRadius(16)
      .margin({ right: 12 })
      .onClick(() => {
        this.selectedCategory = category;
        this.filterGiftMeanings();
      })
  }

  @Builder
  buildMeaningList() {
    if (this.loading) {
      Column() {
        LoadingProgress()
          .width(40)
          .height(40)
          .color('#4CAF50')
        
        Text('加载中...')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 16 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.getFilteredMeanings(), (meaning: GiftMeaning) => {
          ListItem() {
            this.buildMeaningCard(meaning)
          }
          .margin({ bottom: 16 })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
    }
  }

  @Builder
  buildMeaningCard(meaning: GiftMeaning) {
    Column() {
      // 礼物基本信息
      Row() {
        Column() {
          Text('🎁')
            .fontSize(32)
        }
        .width(60)
        .height(60)
        .backgroundColor(meaning.color)
        .borderRadius(30)
        .justifyContent(FlexAlign.Center)
        .margin({ right: 16 })

        Column() {
          Text(meaning.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 4 })

          Text(this.getCategoryText(meaning.category))
            .fontSize(12)
            .fontColor('#999999')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor('#F0F0F0')
            .borderRadius(4)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 象征意义
      Column() {
        Row() {
          Text('💫')
            .fontSize(16)
            .margin({ right: 8 })
          
          Text('象征意义')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .margin({ bottom: 8 })

        Text(meaning.symbolism)
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(20)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })

      // 文化背景
      Column() {
        Row() {
          Text('📚')
            .fontSize(16)
            .margin({ right: 8 })
          
          Text('文化背景')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .margin({ bottom: 8 })

        Text(meaning.culturalBackground)
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(20)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })

      // 适用场合
      Column() {
        Row() {
          Text('🎯')
            .fontSize(16)
            .margin({ right: 8 })
          
          Text('适用场合')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .margin({ bottom: 8 })

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(meaning.occasions, (occasion: Scenario) => {
            Text(this.getScenarioText(occasion))
              .fontSize(12)
              .fontColor('#4CAF50')
              .backgroundColor('#E8F5E8')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(12)
              .margin({ right: 8, bottom: 8 })
          })
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })

      // 送礼小贴士
      if (meaning.tips.length > 0) {
        Column() {
          Row() {
            Text('💡')
              .fontSize(16)
              .margin({ right: 8 })
            
            Text('送礼小贴士')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
          }
          .margin({ bottom: 8 })

          ForEach(meaning.tips, (tip: string) => {
            Row() {
              Text('•')
                .fontSize(14)
                .fontColor('#4CAF50')
                .margin({ right: 8 })
              
              Text(tip)
                .fontSize(14)
                .fontColor('#666666')
                .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 4 })
          })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 16 })
      }

      // 送礼禁忌
      if (meaning.taboos.length > 0) {
        Column() {
          Row() {
            Text('⚠️')
              .fontSize(16)
              .margin({ right: 8 })
            
            Text('送礼禁忌')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FF5722')
          }
          .margin({ bottom: 8 })

          ForEach(meaning.taboos, (taboo: string) => {
            Row() {
              Text('•')
                .fontSize(14)
                .fontColor('#FF5722')
                .margin({ right: 8 })
              
              Text(taboo)
                .fontSize(14)
                .fontColor('#666666')
                .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 4 })
          })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .onClick(() => {
      // 可以跳转到礼物详情页
    })
  }

  private loadGiftMeanings() {
    this.loading = true;
    
    // 模拟加载礼物含义数据
    setTimeout(() => {
      this.giftMeanings = [
        {
          id: '1',
          name: '玫瑰花',
          category: GiftCategory.FLOWERS,
          symbolism: '玫瑰花象征着爱情、美丽和激情。红玫瑰代表热烈的爱情，粉玫瑰代表初恋和感激，白玫瑰代表纯洁的爱情。',
          culturalBackground: '玫瑰在古希腊神话中是爱神阿芙罗狄蒂的象征，在中世纪欧洲，玫瑰成为了爱情和美丽的代名词。在中国文化中，玫瑰也被赋予了浪漫和爱情的含义。',
          occasions: [Scenario.VALENTINE, Scenario.ANNIVERSARY, Scenario.WEDDING],
          tips: ['选择新鲜的玫瑰花', '不同颜色代表不同含义', '搭配精美包装更显心意'],
          taboos: ['避免送黄玫瑰给恋人（代表友谊）', '不要送枯萎的花朵'],
          image: '',
          color: '#FFE4E1'
        },
        {
          id: '2',
          name: '钻石戒指',
          category: GiftCategory.JEWELRY,
          symbolism: '钻石象征着永恒、坚贞和纯洁。戒指代表着承诺和约定，钻石戒指寓意着永恒的爱情和不变的承诺。',
          culturalBackground: '钻石被誉为"宝石之王"，在古代被认为具有神秘的力量。现代社会中，钻石戒指成为了求婚和结婚的经典选择。',
          occasions: [Scenario.WEDDING, Scenario.ANNIVERSARY, Scenario.VALENTINE],
          tips: ['选择有证书的钻石', '考虑4C标准（切工、颜色、净度、克拉）', '选择合适的戒指尺寸'],
          taboos: ['不要选择有瑕疵的钻石', '避免在不合适的场合赠送'],
          image: '',
          color: '#E6F3FF'
        },
        {
          id: '3',
          name: '巧克力',
          category: GiftCategory.FOOD,
          symbolism: '巧克力象征着甜蜜、温暖和关爱。它能够刺激大脑分泌内啡肽，带来愉悦感，因此被视为爱情的象征。',
          culturalBackground: '巧克力起源于古代玛雅和阿兹特克文明，被称为"神的食物"。在欧洲，巧克力成为了贵族的奢侈品，后来逐渐普及并成为表达爱意的礼物。',
          occasions: [Scenario.VALENTINE, Scenario.BIRTHDAY, Scenario.THANK_YOU],
          tips: ['选择高品质的巧克力', '考虑对方的口味偏好', '注意保存温度'],
          taboos: ['注意对方是否有糖尿病或过敏', '避免在炎热天气长时间携带'],
          image: '',
          color: '#F4E4BC'
        }
      ];
      this.loading = false;
    }, 1000);
  }

  private filterGiftMeanings() {
    // 根据搜索文本和分类筛选
    // 这里可以实现具体的筛选逻辑
  }

  private getFilteredMeanings(): GiftMeaning[] {
    let filtered = this.giftMeanings;
    
    // 按分类筛选
    if (this.selectedCategory !== null) {
      filtered = filtered.filter(meaning => meaning.category === this.selectedCategory);
    }
    
    // 按搜索文本筛选
    if (this.searchText.trim() !== '') {
      filtered = filtered.filter(meaning => 
        meaning.name.includes(this.searchText) || 
        meaning.symbolism.includes(this.searchText)
      );
    }
    
    return filtered;
  }

  private getCategoryText(category: GiftCategory): string {
    switch (category) {
      case GiftCategory.FLOWERS:
        return '鲜花';
      case GiftCategory.JEWELRY:
        return '珠宝';
      case GiftCategory.ELECTRONICS:
        return '数码';
      case GiftCategory.CLOTHING:
        return '服饰';
      case GiftCategory.COSMETICS:
        return '美妆';
      case GiftCategory.BOOKS:
        return '书籍';
      case GiftCategory.SPORTS:
        return '运动';
      case GiftCategory.HOME:
        return '家居';
      case GiftCategory.FOOD:
        return '美食';
      case GiftCategory.TOYS:
        return '其他';
      default:
        return '未知';
    }
  }

  private getScenarioText(scenario: Scenario): string {
    switch (scenario) {
      case Scenario.BIRTHDAY:
        return '生日';
      case Scenario.ANNIVERSARY:
        return '纪念日';
      case Scenario.VALENTINE:
        return '情人节';
      case Scenario.CHRISTMAS:
        return '圣诞节';
      case Scenario.CHRISTMAS:
        return '节日';
      case Scenario.GRADUATION:
        return '毕业';
      case Scenario.WEDDING:
        return '婚礼';
      case Scenario.WEDDING:
        return '婚礼';
      case Scenario.APOLOGY:
        return '道歉';
      case Scenario.THANK_YOU:
        return '感谢';
      case Scenario.GET_WELL:
        return '康复';
      case Scenario.GRADUATION:
        return '庆祝';
      default:
        return '其他';
    }
  }
}