import { Gift, GiftCategory, Scenario, PriceRange } from '../model/GiftModel';
import { GiftRecommendationService } from '../service/GiftRecommendationService';
import router from '@ohos.router';

// 筛选条件接口
interface FilterConditions {
  keyword: string;
  category: GiftCategory | null;
  scenario: Scenario | null;
  priceMin: number;
  priceMax: number;
  sortBy: 'price' | 'rating' | 'popularity' | 'newest';
  sortOrder: 'asc' | 'desc';
}

// 价格区间选项
interface PriceRangeOption {
  label: string;
  min: number;
  max: number;
}

@Entry
@Component
struct SearchFilterPage {
  @State searchKeyword: string = '';
  @State filteredGifts: Gift[] = [];
  @State allGifts: Gift[] = [];
  @State loading: boolean = false;
  @State showFilter: boolean = false;
  @State filterConditions: FilterConditions = {
    keyword: '',
    category: null,
    scenario: null,
    priceMin: 0,
    priceMax: 10000,
    sortBy: 'popularity',
    sortOrder: 'desc'
  };
  
  private giftService: GiftRecommendationService = GiftRecommendationService.getInstance();
  private scroller: Scroller = new Scroller();
  
  // 价格区间选项
  private priceRanges: PriceRangeOption[] = [
    { label: '不限', min: 0, max: 10000 },
    { label: '100以下', min: 0, max: 100 },
    { label: '100-300', min: 100, max: 300 },
    { label: '300-500', min: 300, max: 500 },
    { label: '500-1000', min: 500, max: 1000 },
    { label: '1000-3000', min: 1000, max: 3000 },
    { label: '3000以上', min: 3000, max: 10000 }
  ];

  aboutToAppear() {
    this.loadGifts();
  }

  build() {
    Column() {
      this.buildHeader()
      this.buildSearchBar()
      this.buildFilterBar()
      if (this.showFilter) {
        this.buildFilterPanel()
      }
      this.buildResultList()
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

      Text('礼物搜索')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text('🔍')
        .fontSize(24)
        .onClick(() => {
          this.performSearch();
        })
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
      TextInput({ placeholder: '搜索礼物名称、品牌、关键词...' })
        .layoutWeight(1)
        .height(40)
        .backgroundColor('#F5F5F5')
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .fontSize(14)
        .onChange((value: string) => {
          this.searchKeyword = value;
          this.filterConditions.keyword = value;
        })
        .onSubmit(() => {
          this.performSearch();
        })

      Button('搜索')
        .backgroundColor('#4CAF50')
        .fontColor(Color.White)
        .fontSize(14)
        .borderRadius(20)
        .height(40)
        .margin({ left: 12 })
        .onClick(() => {
          this.performSearch();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
  }

  @Builder
  buildFilterBar() {
    Row() {
      Text('筛选')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ right: 8 })

      Button(this.showFilter ? '收起筛选' : '展开筛选')
        .backgroundColor(this.showFilter ? '#FF9800' : '#E3F2FD')
        .fontColor(this.showFilter ? Color.White : '#2196F3')
        .fontSize(12)
        .borderRadius(12)
        .height(32)
        .onClick(() => {
          this.showFilter = !this.showFilter;
        })

      Blank()

      Text(`共${this.filteredGifts.length}件商品`)
        .fontSize(12)
        .fontColor('#999999')

      Button('重置')
        .backgroundColor('#F0F0F0')
        .fontColor('#666666')
        .fontSize(12)
        .borderRadius(12)
        .height(32)
        .margin({ left: 8 })
        .onClick(() => {
          this.resetFilters();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })
  }

  @Builder
  buildFilterPanel() {
    Column() {
      // 分类筛选
      this.buildCategoryFilter()
      
      Divider().margin({ top: 16, bottom: 16 })
      
      // 场景筛选
      this.buildScenarioFilter()
      
      Divider().margin({ top: 16, bottom: 16 })
      
      // 价格筛选
      this.buildPriceFilter()
      
      Divider().margin({ top: 16, bottom: 16 })
      
      // 排序选项
      this.buildSortOptions()
      
      // 应用筛选按钮
      Button('应用筛选')
        .backgroundColor('#4CAF50')
        .fontColor(Color.White)
        .width('100%')
        .height(44)
        .borderRadius(22)
        .margin({ top: 20 })
        .onClick(() => {
          this.applyFilters();
          this.showFilter = false;
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })
  }

  @Builder
  buildCategoryFilter() {
    Column() {
      Text('礼物分类')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 12 })
        .alignSelf(ItemAlign.Start)
      
      Flex({ wrap: FlexWrap.Wrap }) {
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
      }
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildCategoryChip(label: string, category: GiftCategory | null) {
    Text(label)
      .fontSize(14)
      .fontColor(this.filterConditions.category === category ? Color.White : '#666666')
      .backgroundColor(this.filterConditions.category === category ? '#4CAF50' : '#F0F0F0')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(16)
      .margin({ right: 8, bottom: 8 })
      .onClick(() => {
        this.filterConditions.category = category;
      })
  }

  @Builder
  buildScenarioFilter() {
    Column() {
      Text('使用场景')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 12 })
        .alignSelf(ItemAlign.Start)
      
      Flex({ wrap: FlexWrap.Wrap }) {
        this.buildScenarioChip('全部', null)
        this.buildScenarioChip('生日', Scenario.BIRTHDAY)
        this.buildScenarioChip('情人节', Scenario.VALENTINE)
        this.buildScenarioChip('毕业典礼', Scenario.GRADUATION)
        this.buildScenarioChip('婚礼', Scenario.WEDDING)
        this.buildScenarioChip('圣诞节', Scenario.CHRISTMAS)
        this.buildScenarioChip('纪念日', Scenario.ANNIVERSARY)
        this.buildScenarioChip('道歉', Scenario.APOLOGY)
        this.buildScenarioChip('感谢', Scenario.THANK_YOU)
        this.buildScenarioChip('祝贺', Scenario.CONGRATULATIONS)
      }
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildScenarioChip(label: string, scenario: Scenario | null) {
    Text(label)
      .fontSize(14)
      .fontColor(this.filterConditions.scenario === scenario ? Color.White : '#666666')
      .backgroundColor(this.filterConditions.scenario === scenario ? '#4CAF50' : '#F0F0F0')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(16)
      .margin({ right: 8, bottom: 8 })
      .onClick(() => {
        this.filterConditions.scenario = scenario;
      })
  }

  @Builder
  buildPriceFilter() {
    Column() {
      Text('价格区间')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 12 })
        .alignSelf(ItemAlign.Start)
      
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.priceRanges, (range: PriceRangeOption) => {
          this.buildPriceChip(range)
        })
      }
      
      // 自定义价格区间
      Row() {
        Text('自定义:')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ right: 8 })
        
        TextInput({ placeholder: '最低价' })
          .width(80)
          .height(32)
          .fontSize(12)
          .backgroundColor('#F5F5F5')
          .borderRadius(4)
          .textAlign(TextAlign.Center)
          .type(InputType.Number)
          .onChange((value: string) => {
            this.filterConditions.priceMin = parseInt(value) || 0;
          })
        
        Text('-')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ left: 8, right: 8 })
        
        TextInput({ placeholder: '最高价' })
          .width(80)
          .height(32)
          .fontSize(12)
          .backgroundColor('#F5F5F5')
          .borderRadius(4)
          .textAlign(TextAlign.Center)
          .type(InputType.Number)
          .onChange((value: string) => {
            this.filterConditions.priceMax = parseInt(value) || 10000;
          })
      }
      .margin({ top: 12 })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildPriceChip(range: PriceRangeOption) {
    Text(range.label)
      .fontSize(14)
      .fontColor(this.filterConditions.priceMin === range.min && this.filterConditions.priceMax === range.max ? Color.White : '#666666')
      .backgroundColor(this.filterConditions.priceMin === range.min && this.filterConditions.priceMax === range.max ? '#4CAF50' : '#F0F0F0')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(16)
      .margin({ right: 8, bottom: 8 })
      .onClick(() => {
        this.filterConditions.priceMin = range.min;
        this.filterConditions.priceMax = range.max;
      })
  }

  @Builder
  buildSortOptions() {
    Column() {
      Text('排序方式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 12 })
        .alignSelf(ItemAlign.Start)
      
      Flex({ wrap: FlexWrap.Wrap }) {
        this.buildSortChip('人气推荐', 'popularity', 'desc')
        this.buildSortChip('价格从低到高', 'price', 'asc')
        this.buildSortChip('价格从高到低', 'price', 'desc')
        this.buildSortChip('评分最高', 'rating', 'desc')
        this.buildSortChip('最新上架', 'newest', 'desc')
      }
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildSortChip(label: string, sortBy: string, sortOrder: string) {
    Text(label)
      .fontSize(14)
      .fontColor(this.filterConditions.sortBy === sortBy && this.filterConditions.sortOrder === sortOrder ? Color.White : '#666666')
      .backgroundColor(this.filterConditions.sortBy === sortBy && this.filterConditions.sortOrder === sortOrder ? '#4CAF50' : '#F0F0F0')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(16)
      .margin({ right: 8, bottom: 8 })
      .onClick(() => {
        this.filterConditions.sortBy = sortBy as 'price' | 'rating' | 'popularity' | 'newest';
        this.filterConditions.sortOrder = sortOrder as 'asc' | 'desc';
      })
  }

  @Builder
  buildResultList() {
    if (this.loading) {
      Column() {
        Text('🔍')
          .fontSize(48)
          .margin({ bottom: 16 })
        
        Text('正在搜索...')
          .fontSize(16)
          .fontColor('#666666')
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.filteredGifts.length === 0) {
      Column() {
        Text('😔')
          .fontSize(48)
          .margin({ bottom: 16 })
        
        Text('没有找到相关礼物')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ bottom: 8 })
        
        Text('试试调整搜索条件或筛选条件')
          .fontSize(14)
          .fontColor('#999999')
        
        Button('重新搜索')
          .backgroundColor('#4CAF50')
          .fontColor(Color.White)
          .borderRadius(20)
          .margin({ top: 20 })
          .onClick(() => {
            this.resetFilters();
            this.loadGifts();
          })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      Scroll(this.scroller) {
        Column() {
          ForEach(this.filteredGifts, (gift: Gift) => {
            this.buildGiftCard(gift)
          })
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
      }
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
    }
  }

  @Builder
  buildGiftCard(gift: Gift) {
    Row() {
      // 礼物图片
      Column() {
        Text('🎁')
          .fontSize(32)
      }
      .width(80)
      .height(80)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 12 })

      // 礼物信息
      Column() {
        Text(gift.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 4 })
        
        Text(gift.description)
          .fontSize(14)
          .fontColor('#666666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 8 })
        
        Row() {
          Text(`¥${gift.price}`)
            .fontSize(18)
            .fontColor('#FF5722')
            .fontWeight(FontWeight.Bold)
          
          Text(`⭐ ${gift.rating}`)
            .fontSize(12)
            .fontColor('#FF9800')
            .margin({ left: 8 })
          
          Blank()
          
          Text(this.getCategoryText(gift.category))
            .fontSize(12)
            .fontColor('#999999')
            .backgroundColor('#F0F0F0')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
        }
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 收藏按钮
      Text('♡')
        .fontSize(24)
        .fontColor('#CCCCCC')
        .onClick(() => {
          // 添加到收藏
        })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ bottom: 12 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/GiftDetailPage',
        params: { giftId: gift.id }
      });
    })
  }

  private loadGifts() {
    this.loading = true;
    
    // 模拟加载礼物数据
    setTimeout(() => {
      this.allGifts = this.giftService.getRecommendations({
          scenario: Scenario.BIRTHDAY,
          priceRange: PriceRange.MODERATE
        }).gifts;
      this.filteredGifts = [...this.allGifts];
      this.loading = false;
    }, 500);
  }

  private performSearch() {
    this.loading = true;
    
    setTimeout(() => {
      this.applyFilters();
      this.loading = false;
    }, 300);
  }

  private applyFilters() {
    let results = [...this.allGifts];
    
    // 关键词搜索
    if (this.filterConditions.keyword.trim()) {
      const keyword = this.filterConditions.keyword.toLowerCase();
      results = results.filter(gift => 
        gift.name.toLowerCase().includes(keyword) ||
        gift.description.toLowerCase().includes(keyword)
      );
    }
    
    // 分类筛选
    if (this.filterConditions.category !== null) {
      results = results.filter(gift => gift.category === this.filterConditions.category);
    }
    
    // 场景筛选
    if (this.filterConditions.scenario !== null) {
      results = results.filter(gift => gift.scenarios.includes(this.filterConditions.scenario!));
    }
    
    // 价格筛选
    results = results.filter(gift => 
      gift.price >= this.filterConditions.priceMin && 
      gift.price <= this.filterConditions.priceMax
    );
    
    // 排序
    results.sort((a, b) => {
      let comparison = 0;
      
      switch (this.filterConditions.sortBy) {
        case 'price':
          comparison = a.price - b.price;
          break;
        case 'rating':
          comparison = a.rating - b.rating;
          break;
        case 'popularity':
          comparison = a.rating - b.rating; // 使用评分代替人气
          break;
        case 'newest':
          comparison = a.id.localeCompare(b.id); // 使用ID排序代替创建时间
          break;
      }
      
      return this.filterConditions.sortOrder === 'desc' ? -comparison : comparison;
    });
    
    this.filteredGifts = results;
  }

  private resetFilters() {
    this.searchKeyword = '';
    this.filterConditions = {
      keyword: '',
      category: null,
      scenario: null,
      priceMin: 0,
      priceMax: 10000,
      sortBy: 'popularity',
      sortOrder: 'desc'
    };
    this.filteredGifts = [...this.allGifts];
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
}