import { Gift, GiftRecommendationRequest, Scenario, GiftCategory, PriceRange, Gender, AgeRange, Relationship } from '../model/GiftModel';
import { GiftRecommendationService } from '../service/GiftRecommendationService';

@Entry
@Component
struct GiftRecommendationPage {
  @State private gifts: Gift[] = [];
  @State private loading: boolean = false;
  @State private selectedScenario: Scenario | undefined = undefined;
  @State private selectedCategory: GiftCategory | undefined = undefined;
  @State private selectedPriceRange: PriceRange | undefined = undefined;
  @State private selectedGender: Gender | undefined = undefined;
  @State private selectedAgeRange: AgeRange | undefined = undefined;
  @State private selectedRelationship: Relationship | undefined = undefined;
  @State private searchKeyword: string = '';
  @State private recommendationReason: string = '';
  
  private giftService = GiftRecommendationService.getInstance();

  aboutToAppear() {
    this.loadRecommendations();
  }

  build() {
    Column() {
      // 标题栏
      this.buildHeader()
      
      // 筛选区域
      this.buildFilterSection()
      
      // 推荐理由
      if (this.recommendationReason) {
        this.buildRecommendationReason()
      }
      
      // 礼物列表
      this.buildGiftList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildHeader() {
    Row() {
      Text('礼物推荐')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
      
      Blank()
      
      Button('重置筛选')
        .fontSize(14)
        .backgroundColor('#FF6B6B')
        .fontColor(Color.White)
        .borderRadius(15)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .onClick(() => {
          this.resetFilters();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
  }

  @Builder
  buildFilterSection() {
    Column() {
      // 搜索框
      TextInput({ placeholder: '搜索礼物关键词...' })
        .width('100%')
        .height(40)
        .backgroundColor('#F8F8F8')
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.searchKeyword = value;
        })
        .onSubmit(() => {
          this.loadRecommendations();
        })
      
      // 场景选择
      this.buildScenarioFilter()
      
      // 分类选择
      this.buildCategoryFilter()
      
      // 价格区间
      this.buildPriceRangeFilter()
      
      // 目标人群
      this.buildTargetGroupFilter()
      
      // 搜索按钮
      Button('开始推荐')
        .width('100%')
        .height(44)
        .backgroundColor('#4CAF50')
        .fontColor(Color.White)
        .borderRadius(22)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16 })
        .onClick(() => {
          this.loadRecommendations();
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ top: 8 })
  }

  @Builder
  buildScenarioFilter() {
    Column() {
      Text('送礼场景')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })
      
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach([
          { key: Scenario.BIRTHDAY, label: '生日' },
          { key: Scenario.ANNIVERSARY, label: '纪念日' },
          { key: Scenario.VALENTINE, label: '情人节' },
          { key: Scenario.CHRISTMAS, label: '圣诞节' },
          { key: Scenario.GRADUATION, label: '毕业' },
          { key: Scenario.WEDDING, label: '婚礼' },
          { key: Scenario.THANK_YOU, label: '感谢' },
          { key: Scenario.APOLOGY, label: '道歉' }
        ], (item: Record<string, Object>) => {
          Button(item.label as string)
            .fontSize(12)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(this.selectedScenario === (item.key as Scenario) ? '#4CAF50' : '#E0E0E0')
            .fontColor(this.selectedScenario === (item.key as Scenario) ? Color.White : '#666666')
            .borderRadius(15)
            .onClick(() => {
              this.selectedScenario = this.selectedScenario === (item.key as Scenario) ? undefined : (item.key as Scenario);
            })
        })
      }
    }
    .width('100%')
    .margin({ top: 16 })
  }

  @Builder
  buildCategoryFilter() {
    Column() {
      Text('礼物分类')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })
      
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach([
          { key: GiftCategory.JEWELRY, label: '珠宝首饰' },
          { key: GiftCategory.ELECTRONICS, label: '数码电子' },
          { key: GiftCategory.FLOWERS, label: '鲜花绿植' },
          { key: GiftCategory.COSMETICS, label: '美妆护肤' },
          { key: GiftCategory.BOOKS, label: '图书文具' },
          { key: GiftCategory.CLOTHING, label: '服装配饰' },
          { key: GiftCategory.FOOD, label: '美食特产' },
          { key: GiftCategory.TOYS, label: '玩具游戏' }
        ], (item: Record<string, Object>) => {
          Button(item.label as string)
            .fontSize(12)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(this.selectedCategory === (item.key as GiftCategory) ? '#2196F3' : '#E0E0E0')
            .fontColor(this.selectedCategory === (item.key as GiftCategory) ? Color.White : '#666666')
            .borderRadius(15)
            .onClick(() => {
              this.selectedCategory = this.selectedCategory === (item.key as GiftCategory) ? undefined : (item.key as GiftCategory);
            })
        })
      }
    }
    .width('100%')
    .margin({ top: 16 })
  }

  @Builder
  buildPriceRangeFilter() {
    Column() {
      Text('价格区间')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })
      
      Row() {
        ForEach([
          { key: PriceRange.BUDGET, label: '经济型\n(0-100元)' },
          { key: PriceRange.MODERATE, label: '中档型\n(100-500元)' },
          { key: PriceRange.PREMIUM, label: '高档型\n(500-1000元)' },
          { key: PriceRange.LUXURY, label: '奢华型\n(1000元+)' }
        ], (item: Record<string, Object>) => {
          Button(item.label as string)
            .fontSize(11)
            .padding(8)
            .margin({ right: 8 })
            .backgroundColor(this.selectedPriceRange === (item.key as PriceRange) ? '#FF9800' : '#E0E0E0')
            .fontColor(this.selectedPriceRange === (item.key as PriceRange) ? Color.White : '#666666')
            .borderRadius(8)
            .layoutWeight(1)
            .onClick(() => {
              this.selectedPriceRange = this.selectedPriceRange === (item.key as PriceRange) ? undefined : (item.key as PriceRange);
            })
        })
      }
    }
    .width('100%')
    .margin({ top: 16 })
  }

  @Builder
  buildTargetGroupFilter() {
    Column() {
      Text('目标人群')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })
      
      // 性别选择
      Row() {
        Text('性别：')
          .fontSize(12)
          .fontColor('#888888')
          .width(50)
        
        ForEach([
          { key: Gender.MALE, label: '男性' },
          { key: Gender.FEMALE, label: '女性' },
          { key: Gender.UNISEX, label: '通用' }
        ], (item: Record<string, Object>) => {
          Button(item.label as string)
            .fontSize(11)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .margin({ right: 6 })
            .backgroundColor(this.selectedGender === (item.key as Gender) ? '#E91E63' : '#F0F0F0')
            .fontColor(this.selectedGender === (item.key as Gender) ? Color.White : '#666666')
            .borderRadius(12)
            .onClick(() => {
              this.selectedGender = this.selectedGender === (item.key as Gender) ? undefined : (item.key as Gender);
            })
        })
      }
      .width('100%')
      .margin({ bottom: 8 })
      
      // 年龄选择
      Row() {
        Text('年龄：')
          .fontSize(12)
          .fontColor('#888888')
          .width(50)
        
        ForEach([
          { key: AgeRange.TEEN, label: '青少年' },
          { key: AgeRange.YOUNG_ADULT, label: '青年' },
          { key: AgeRange.ADULT, label: '中年' },
          { key: AgeRange.SENIOR, label: '长者' }
        ], (item: Record<string, Object>) => {
          Button(item.label as string)
            .fontSize(11)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .margin({ right: 6 })
            .backgroundColor(this.selectedAgeRange === (item.key as AgeRange) ? '#9C27B0' : '#F0F0F0')
            .fontColor(this.selectedAgeRange === (item.key as AgeRange) ? Color.White : '#666666')
            .borderRadius(12)
            .onClick(() => {
              this.selectedAgeRange = this.selectedAgeRange === (item.key as AgeRange) ? undefined : (item.key as AgeRange);
            })
        })
      }
      .width('100%')
      .margin({ bottom: 8 })
      
      // 关系选择
      Row() {
        Text('关系：')
          .fontSize(12)
          .fontColor('#888888')
          .width(50)
        
        ForEach([
          { key: Relationship.FAMILY, label: '家人' },
          { key: Relationship.FRIEND, label: '朋友' },
          { key: Relationship.ROMANTIC, label: '恋人' },
          { key: Relationship.COLLEAGUE, label: '同事' }
        ], (item: Record<string, Object>) => {
          Button(item.label as string)
            .fontSize(11)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .margin({ right: 6 })
            .backgroundColor(this.selectedRelationship === (item.key as Relationship) ? '#607D8B' : '#F0F0F0')
            .fontColor(this.selectedRelationship === (item.key as Relationship) ? Color.White : '#666666')
            .borderRadius(12)
            .onClick(() => {
              this.selectedRelationship = this.selectedRelationship === (item.key as Relationship) ? undefined : (item.key as Relationship);
            })
        })
      }
      .width('100%')
    }
    .width('100%')
    .margin({ top: 16 })
  }

  @Builder
  buildRecommendationReason() {
    Row() {
      Text(this.recommendationReason)
        .fontSize(14)
        .fontColor('#4CAF50')
        .fontWeight(FontWeight.Medium)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#E8F5E8')
    .margin({ top: 8 })
  }

  @Builder
  buildGiftList() {
    if (this.loading) {
      Column() {
        LoadingProgress()
          .width(40)
          .height(40)
          .color('#4CAF50')
        
        Text('正在为您推荐礼物...')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 16 })
      }
      .width('100%')
      .height(200)
      .justifyContent(FlexAlign.Center)
    } else if (this.gifts.length === 0) {
      Column() {
        Text('🎁')
          .fontSize(48)
        
        Text('暂无推荐结果')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ top: 16 })
        
        Text('请尝试调整筛选条件')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 8 })
      }
      .width('100%')
      .height(200)
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.gifts, (gift: Gift) => {
          ListItem() {
            this.buildGiftCard(gift)
          }
          .margin({ bottom: 12 })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 8, bottom: 16 })
    }
  }

  @Builder
  buildGiftCard(gift: Gift) {
    Row() {
      // 礼物图片占位
      Column() {
        Text('🎁')
          .fontSize(32)
      }
      .width(80)
      .height(80)
      .backgroundColor('#F0F0F0')
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
          Text(`¥${gift.price}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B6B')
          
          Blank()
          
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
        
        // 标签
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(gift.tags.slice(0, 3), (tag: string) => {
            Text(tag)
              .fontSize(10)
              .fontColor('#4CAF50')
              .backgroundColor('#E8F5E8')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
              .margin({ right: 4, top: 4 })
          })
        }
        .margin({ top: 4 })
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

  private loadRecommendations() {
    this.loading = true;
    
    const request: GiftRecommendationRequest = {
      scenario: this.selectedScenario,
      category: this.selectedCategory,
      priceRange: this.selectedPriceRange,
      targetGroup: {
        gender: this.selectedGender || Gender.UNISEX,
        ageRange: this.selectedAgeRange || AgeRange.ADULT,
        relationship: this.selectedRelationship || Relationship.FRIEND,
        interests: []
      },
      keywords: this.searchKeyword ? [this.searchKeyword] : undefined
    };
    
    // 模拟异步加载
    setTimeout(() => {
      const response = this.giftService.getRecommendations(request);
      this.gifts = response.gifts;
      this.recommendationReason = response.recommendationReason;
      this.loading = false;
    }, 500);
  }

  private resetFilters() {
    this.selectedScenario = undefined;
    this.selectedCategory = undefined;
    this.selectedPriceRange = undefined;
    this.selectedGender = undefined;
    this.selectedAgeRange = undefined;
    this.selectedRelationship = undefined;
    this.searchKeyword = '';
    this.loadRecommendations();
  }
}