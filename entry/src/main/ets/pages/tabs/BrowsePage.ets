import router from '@ohos.router';
import { Inspiration } from '../../model/NewDataModels';
import { InspirationDAO } from '../../database/InspirationDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';
import { InspirationDataInitializer } from '../../database/InspirationDataInitializer';
import { MockData } from '../../data/MockData';
import { common } from '@kit.AbilityKit';
import { 
  RecipientType, 
  OccasionType, 
  BudgetRange as BudgetRangeEnum, 
  GiftType,
  TagInfo,
  TagCategory,
  getTagInfo,
  getRecipientTypeName,
  getOccasionTypeName,
  getBudgetRangeName,
  getGiftTypeName,
  RecipientTypeNames,
  OccasionTypeNames,
  BudgetRangeNames,
  GiftTypeNames
} from '../../model/GiftEnums';
import { TagComponent } from '../../components/TagComponent';

// 快速筛选器接口
interface QuickFilter {
  label: string;
  category: TagCategory;
  value: string;
}

// Select组件选项接口
interface SelectOption {
  value: string;
}

// 分类导航项接口
interface CategoryNavigationItem {
  label: string;
  category: TagCategory;
  value: string;
}

// 分类导航接口
interface CategoryNavigation {
  icon: string;
  title: string;
  items: CategoryNavigationItem[];
}

// 快速筛选器接口（兼容原有）搜索条件接口
interface SearchCondition {
  id: string;
  label: string;
  type: string;
  options: SearchOption[];
  selectedValue?: string;
  selectedLabel?: string;
}

// 搜索选项接口
interface SearchOption {
  label: string;
  value: string;
}



// 分类导航接口（保留兼容）
interface Category {
  title: string;
  icon: Resource;
  items: string[];
}

@Component
export struct BrowsePage {
  @State inspirations: Inspiration[] = [];
  @State filteredInspirations: Inspiration[] = [];
  @State selectedFilters: string[] = [];
  @State searchKeyword: string = '';
  @State isLoading: boolean = true;
  
  // 新增：多维度搜索状态
  @State searchConditions: SearchCondition[] = [];
  

  
  private dbManager: NewDatabaseManager | null = null;
  private inspirationDAO: InspirationDAO | null = null;
  private dataInitializer: InspirationDataInitializer = new InspirationDataInitializer();
  
  // 热门标签配置（使用新枚举系统）
  private hotTags: QuickFilter[] = [
    { label: getOccasionTypeName(OccasionType.BIRTHDAY), category: TagCategory.OCCASION, value: OccasionType.BIRTHDAY },
    { label: getRecipientTypeName(RecipientType.BOYFRIEND), category: TagCategory.RECIPIENT, value: RecipientType.BOYFRIEND },
    { label: getGiftTypeName(GiftType.DIY_HANDMADE), category: TagCategory.GIFT_TYPE, value: GiftType.DIY_HANDMADE },
    { label: getBudgetRangeName(BudgetRangeEnum.RANGE_100_200), category: TagCategory.BUDGET, value: BudgetRangeEnum.RANGE_100_200 },
    { label: getOccasionTypeName(OccasionType.VALENTINE_DAY), category: TagCategory.OCCASION, value: OccasionType.VALENTINE_DAY },
    { label: getRecipientTypeName(RecipientType.FATHER), category: TagCategory.RECIPIENT, value: RecipientType.FATHER }
  ];

  // 分类导航配置（使用新枚举系统）
  private categoryNavigation: CategoryNavigation[] = [
    {
      icon: '👤',
      title: '按对象',
      items: [
        { label: getRecipientTypeName(RecipientType.ELDER_RELATIVE), category: TagCategory.RECIPIENT, value: RecipientType.ELDER_RELATIVE },
        { label: getRecipientTypeName(RecipientType.BOYFRIEND), category: TagCategory.RECIPIENT, value: RecipientType.BOYFRIEND },
        { label: getRecipientTypeName(RecipientType.BESTIE), category: TagCategory.RECIPIENT, value: RecipientType.BESTIE },
        { label: getRecipientTypeName(RecipientType.COLLEAGUE), category: TagCategory.RECIPIENT, value: RecipientType.COLLEAGUE }
      ]
    },
    {
      icon: '🎉',
      title: '按场合',
      items: [
        { label: getOccasionTypeName(OccasionType.BIRTHDAY), category: TagCategory.OCCASION, value: OccasionType.BIRTHDAY },
        { label: getOccasionTypeName(OccasionType.VALENTINE_DAY), category: TagCategory.OCCASION, value: OccasionType.VALENTINE_DAY },
        { label: getOccasionTypeName(OccasionType.CHRISTMAS), category: TagCategory.OCCASION, value: OccasionType.CHRISTMAS },
        { label: getOccasionTypeName(OccasionType.ANNIVERSARY), category: TagCategory.OCCASION, value: OccasionType.ANNIVERSARY }
      ]
    },
    {
      icon: '🎁',
      title: '按类型',
      items: [
        { label: getGiftTypeName(GiftType.DIY_HANDMADE), category: TagCategory.GIFT_TYPE, value: GiftType.DIY_HANDMADE },
        { label: getGiftTypeName(GiftType.TECH_DIGITAL), category: TagCategory.GIFT_TYPE, value: GiftType.TECH_DIGITAL },
        { label: getOccasionTypeName(OccasionType.GRADUATION), category: TagCategory.OCCASION, value: OccasionType.GRADUATION },
        { label: getGiftTypeName(GiftType.BEAUTY_SKINCARE), category: TagCategory.GIFT_TYPE, value: GiftType.BEAUTY_SKINCARE }
      ]
    },
    {
      icon: '💰',
      title: '按预算',
      items: [
        { label: getBudgetRangeName(BudgetRangeEnum.UNDER_50), category: TagCategory.BUDGET, value: BudgetRangeEnum.UNDER_50 },
        { label: getBudgetRangeName(BudgetRangeEnum.RANGE_100_200), category: TagCategory.BUDGET, value: BudgetRangeEnum.RANGE_100_200 },
        { label: getBudgetRangeName(BudgetRangeEnum.RANGE_500_1000), category: TagCategory.BUDGET, value: BudgetRangeEnum.RANGE_500_1000 },
        { label: getBudgetRangeName(BudgetRangeEnum.OVER_2000), category: TagCategory.BUDGET, value: BudgetRangeEnum.OVER_2000 }
      ]
    }
  ];


  async aboutToAppear() {
    // 初始化数据库
    const context = getContext(this) as common.UIAbilityContext;
    this.dbManager = new NewDatabaseManager();
    await this.dbManager.initDatabase(context);
    
    // 初始化DAO
    this.inspirationDAO = new InspirationDAO(this.dbManager);
    
    this.initializeSearchConditions();
    this.loadInspirations();
  }
  
  // 初始化搜索条件
  initializeSearchConditions() {
    this.searchConditions = [
      {
        id: 'audience',
        label: '送给谁',
        type: 'audience',
        options: [
          { label: '不限', value: '' },
          { label: RecipientTypeNames[RecipientType.FATHER], value: RecipientType.FATHER },
          { label: RecipientTypeNames[RecipientType.MOTHER], value: RecipientType.MOTHER },
          { label: RecipientTypeNames[RecipientType.GRANDFATHER], value: RecipientType.GRANDFATHER },
          { label: RecipientTypeNames[RecipientType.GRANDMOTHER], value: RecipientType.GRANDMOTHER },
          { label: RecipientTypeNames[RecipientType.ELDER_RELATIVE], value: RecipientType.ELDER_RELATIVE },
          { label: RecipientTypeNames[RecipientType.BOYFRIEND], value: RecipientType.BOYFRIEND },
          { label: RecipientTypeNames[RecipientType.GIRLFRIEND], value: RecipientType.GIRLFRIEND },
          { label: RecipientTypeNames[RecipientType.HUSBAND], value: RecipientType.HUSBAND },
          { label: RecipientTypeNames[RecipientType.WIFE], value: RecipientType.WIFE },
          { label: RecipientTypeNames[RecipientType.BESTIE], value: RecipientType.BESTIE },
          { label: RecipientTypeNames[RecipientType.FRIEND], value: RecipientType.FRIEND },
          { label: RecipientTypeNames[RecipientType.COLLEAGUE], value: RecipientType.COLLEAGUE },
          { label: RecipientTypeNames[RecipientType.BOSS], value: RecipientType.BOSS },
          { label: RecipientTypeNames[RecipientType.TEACHER], value: RecipientType.TEACHER },
          { label: RecipientTypeNames[RecipientType.CHILD], value: RecipientType.CHILD },
          { label: RecipientTypeNames[RecipientType.SIBLING], value: RecipientType.SIBLING },
          { label: RecipientTypeNames[RecipientType.CLASSMATE], value: RecipientType.CLASSMATE },
          { label: RecipientTypeNames[RecipientType.NEIGHBOR], value: RecipientType.NEIGHBOR },
          { label: RecipientTypeNames[RecipientType.CLIENT], value: RecipientType.CLIENT },
          { label: RecipientTypeNames[RecipientType.OTHER], value: RecipientType.OTHER }
        ]
      },
      {
        id: 'occasion',
        label: '什么场合',
        type: 'occasion',
        options: [
          { label: '不限', value: '' },
          { label: OccasionTypeNames[OccasionType.BIRTHDAY], value: OccasionType.BIRTHDAY },
          { label: OccasionTypeNames[OccasionType.ANNIVERSARY], value: OccasionType.ANNIVERSARY },
          { label: OccasionTypeNames[OccasionType.WEDDING_ANNIVERSARY], value: OccasionType.WEDDING_ANNIVERSARY },
          { label: OccasionTypeNames[OccasionType.VALENTINE_DAY], value: OccasionType.VALENTINE_DAY },
          { label: OccasionTypeNames[OccasionType.CHRISTMAS], value: OccasionType.CHRISTMAS },
          { label: OccasionTypeNames[OccasionType.NEW_YEAR], value: OccasionType.NEW_YEAR },
          { label: OccasionTypeNames[OccasionType.SPRING_FESTIVAL], value: OccasionType.SPRING_FESTIVAL },
          { label: OccasionTypeNames[OccasionType.MOTHERS_DAY], value: OccasionType.MOTHERS_DAY },
          { label: OccasionTypeNames[OccasionType.FATHERS_DAY], value: OccasionType.FATHERS_DAY },
          { label: OccasionTypeNames[OccasionType.TEACHERS_DAY], value: OccasionType.TEACHERS_DAY },
          { label: OccasionTypeNames[OccasionType.GRADUATION], value: OccasionType.GRADUATION },
          { label: OccasionTypeNames[OccasionType.PROMOTION], value: OccasionType.PROMOTION },
          { label: OccasionTypeNames[OccasionType.NEW_JOB], value: OccasionType.NEW_JOB },
          { label: OccasionTypeNames[OccasionType.HOUSEWARMING], value: OccasionType.HOUSEWARMING },
          { label: OccasionTypeNames[OccasionType.WEDDING], value: OccasionType.WEDDING },
          { label: OccasionTypeNames[OccasionType.BABY_SHOWER], value: OccasionType.BABY_SHOWER },
          { label: OccasionTypeNames[OccasionType.GET_WELL], value: OccasionType.GET_WELL },
          { label: OccasionTypeNames[OccasionType.APOLOGY], value: OccasionType.APOLOGY },
          { label: OccasionTypeNames[OccasionType.THANK_YOU], value: OccasionType.THANK_YOU },
          { label: OccasionTypeNames[OccasionType.ENCOURAGEMENT], value: OccasionType.ENCOURAGEMENT },
          { label: OccasionTypeNames[OccasionType.JUST_BECAUSE], value: OccasionType.JUST_BECAUSE },
          { label: OccasionTypeNames[OccasionType.OTHER], value: OccasionType.OTHER }
        ]
      },
      {
        id: 'budget',
        label: '预算范围',
        type: 'budget',
        options: [
          { label: '不限', value: '' },
          { label: BudgetRangeNames[BudgetRangeEnum.UNDER_50], value: BudgetRangeEnum.UNDER_50 },
          { label: BudgetRangeNames[BudgetRangeEnum.RANGE_50_100], value: BudgetRangeEnum.RANGE_50_100 },
          { label: BudgetRangeNames[BudgetRangeEnum.RANGE_100_200], value: BudgetRangeEnum.RANGE_100_200 },
          { label: BudgetRangeNames[BudgetRangeEnum.RANGE_200_500], value: BudgetRangeEnum.RANGE_200_500 },
          { label: BudgetRangeNames[BudgetRangeEnum.RANGE_500_1000], value: BudgetRangeEnum.RANGE_500_1000 },
          { label: BudgetRangeNames[BudgetRangeEnum.RANGE_1000_2000], value: BudgetRangeEnum.RANGE_1000_2000 },
          { label: BudgetRangeNames[BudgetRangeEnum.OVER_2000], value: BudgetRangeEnum.OVER_2000 }
        ]
      },
      {
        id: 'type',
        label: '礼物类型',
        type: 'type',
        options: [
          { label: '不限', value: '' },
          { label: GiftTypeNames[GiftType.DIY_HANDMADE], value: GiftType.DIY_HANDMADE },
          { label: GiftTypeNames[GiftType.EXPERIENCE], value: GiftType.EXPERIENCE },
          { label: GiftTypeNames[GiftType.DAILY_ITEMS], value: GiftType.DAILY_ITEMS },
          { label: GiftTypeNames[GiftType.CREATIVE_NOVEL], value: GiftType.CREATIVE_NOVEL },
          { label: GiftTypeNames[GiftType.TECH_DIGITAL], value: GiftType.TECH_DIGITAL },
          { label: GiftTypeNames[GiftType.BEAUTY_SKINCARE], value: GiftType.BEAUTY_SKINCARE },
          { label: GiftTypeNames[GiftType.BOOKS_STATIONERY], value: GiftType.BOOKS_STATIONERY },
          { label: GiftTypeNames[GiftType.CLOTHING_ACCESSORIES], value: GiftType.CLOTHING_ACCESSORIES },
          { label: GiftTypeNames[GiftType.FOOD_BEVERAGE], value: GiftType.FOOD_BEVERAGE },
          { label: GiftTypeNames[GiftType.HOME_DECOR], value: GiftType.HOME_DECOR },
          { label: GiftTypeNames[GiftType.SPORTS_FITNESS], value: GiftType.SPORTS_FITNESS },
          { label: GiftTypeNames[GiftType.TRAVEL_OUTDOOR], value: GiftType.TRAVEL_OUTDOOR },
          { label: GiftTypeNames[GiftType.JEWELRY], value: GiftType.JEWELRY },
          { label: GiftTypeNames[GiftType.FLOWERS_PLANTS], value: GiftType.FLOWERS_PLANTS },
          { label: GiftTypeNames[GiftType.COLLECTIBLES], value: GiftType.COLLECTIBLES },
          { label: GiftTypeNames[GiftType.OTHER], value: GiftType.OTHER }
        ]
      }
    ];
  }

  async loadInspirations() {
    try {
      this.isLoading = true;
      
      if (!this.inspirationDAO) {
        console.error('数据库未初始化');
        this.inspirations = this.getMockInspirations();
        this.filteredInspirations = this.inspirations;
        return;
      }
      
      this.inspirations = await this.inspirationDAO.getAllInspirations();
      
      // 如果数据库中没有数据，使用预置数据
      if (this.inspirations.length === 0) {
        this.inspirations = this.getMockInspirations();
      }
      
      this.filteredInspirations = this.inspirations;
    } catch (error) {
      console.error('加载灵感数据失败:', error);
      // 如果数据库为空，显示示例数据
      this.inspirations = this.getMockInspirations();
      this.filteredInspirations = this.inspirations;
    } finally {
      this.isLoading = false;
    }
  }



  // 获取示例灵感数据
  getMockInspirations(): Inspiration[] {
    return MockData.getAllInspirations();
  }

  // 应用筛选（新版本）
  applyFilters() {
    let result = this.inspirations;
    
    // 搜索关键词筛选
    if (this.searchKeyword.trim()) {
      const keyword = this.searchKeyword.toLowerCase();
      result = result.filter(item => 
        item.title.toLowerCase().includes(keyword) ||
        item.description.toLowerCase().includes(keyword) ||
        item.tags.some(tag => tag.toLowerCase().includes(keyword))
      );
    }
    
    // 多维度条件筛选
    this.searchConditions.forEach(condition => {
      if (condition.selectedValue && condition.selectedValue !== '') {
        switch (condition.type) {
          case 'audience':
            // 直接用枚举值在tags字段中匹配
            const recipientType = condition.selectedValue as RecipientType;
            result = result.filter(item => item.tags.includes(recipientType));
            break;
          case 'occasion':
            // 直接用枚举值在tags字段中匹配
            const occasionType = condition.selectedValue as OccasionType;
            result = result.filter(item => item.tags.includes(occasionType));
            break;
          case 'budget':
            // 直接用枚举值在tags字段中匹配
            const budgetRangeType = condition.selectedValue as BudgetRangeEnum;
            result = result.filter(item => item.tags.includes(budgetRangeType));
            break;
          case 'type':
            // 直接用枚举值在tags字段中匹配
            const giftType = condition.selectedValue as GiftType;
            result = result.filter(item => item.tags.includes(giftType));
            break;
        }
      }
    });
    
    // 兼容原有热门标签筛选
    this.selectedFilters.forEach(filter => {
      const filterConfig = this.hotTags.find(f => f.label === filter);
      if (filterConfig) {
        switch (filterConfig.category) {
          case TagCategory.OCCASION:
            result = result.filter(item => item.occasions.includes(filterConfig.value));
            break;
          case TagCategory.RECIPIENT:
            result = result.filter(item => item.targetAudience.includes(filterConfig.value));
            break;
          case TagCategory.BUDGET:
            const budget = parseInt(filterConfig.value);
            result = result.filter(item => item.budgetRange.max <= budget);
            break;
          case TagCategory.GIFT_TYPE:
            result = result.filter(item => item.giftType === filterConfig.value);
            break;
        }
      }
    });
    
    this.filteredInspirations = result;
  }
  

  
  // 选择搜索条件
  selectSearchOption(conditionId: string, option: SearchOption) {
    const conditionIndex = this.searchConditions.findIndex(c => c.id === conditionId);
    if (conditionIndex !== -1) {
      // 创建新的数组来触发状态更新
      const newConditions: SearchCondition[] = [];
      for (let i = 0; i < this.searchConditions.length; i++) {
        if (i === conditionIndex) {
          const updatedCondition: SearchCondition = {
            id: this.searchConditions[i].id,
            label: this.searchConditions[i].label,
            type: this.searchConditions[i].type,
            options: this.searchConditions[i].options,
            selectedValue: option.value,
            selectedLabel: option.label
          };
          newConditions.push(updatedCondition);
        } else {
          newConditions.push(this.searchConditions[i]);
        }
      }
      this.searchConditions = newConditions;
    }
    this.applyFilters();
  }
  
  // 重置所有筛选条件
  resetAllFilters() {
    // 创建新的数组来触发状态更新
    const newConditions: SearchCondition[] = [];
    for (let i = 0; i < this.searchConditions.length; i++) {
      const resetCondition: SearchCondition = {
        id: this.searchConditions[i].id,
        label: this.searchConditions[i].label,
        type: this.searchConditions[i].type,
        options: this.searchConditions[i].options,
        selectedValue: '',
        selectedLabel: ''
      };
      newConditions.push(resetCondition);
    }
    this.searchConditions = newConditions;
    this.selectedFilters = [];
    this.searchKeyword = '';
    this.applyFilters();
  }

  // 切换筛选器
  toggleFilter(filterLabel: string) {
    const index = this.selectedFilters.indexOf(filterLabel);
    if (index > -1) {
      this.selectedFilters.splice(index, 1);
    } else {
      this.selectedFilters.push(filterLabel);
    }
    this.applyFilters();
  }

  // 导航到分类页面
  navigateToCategory(category: Category) {
    try {
      // 跳转到筛选页面，传递分类信息
      router.pushUrl({
        url: 'pages/tabs/InspirationFilterPage',
        params: {
          filterType: 'category',
          filterValue: category.title,
          title: category.title,
          categoryItems: category.items
        }
      });
      
      console.log('导航到分类页面:', category.title);
    } catch (error) {
      console.error('导航失败:', error);
      
      // 如果导航失败，则在当前页面应用筛选
      this.selectedFilters = [];
      this.searchKeyword = '';
      
      // 根据分类设置相应的筛选条件
      switch (category.title) {
        case '按对象送':
          this.selectedFilters = ['👨‍👩‍👧‍👦 孝敬父母', '❤️ 情侣专属'];
          break;
        case '按场合送':
          this.selectedFilters = ['💝 生日必备', '🎉 节日庆祝'];
          break;
        case '按预算送':
          this.selectedFilters = ['💰 百元好礼'];
          break;
        case '按类型送':
          this.selectedFilters = ['🎨 DIY手作'];
          break;
        case '按兴趣送':
        case '按季节送':
          this.selectedFilters = ['🎉 节日庆祝'];
          break;
      }
      
      this.applyFilters();
      console.log('在当前页面应用筛选:', category.title, this.selectedFilters);
    }
  }

  // 导航到灵感详情页
  navigateToInspirationDetail(inspiration: Inspiration) {
    router.pushUrl({
      url: 'pages/InspirationDetailPage',
      params: {
        inspirationId: inspiration.id
      }
    });
  }

  // 导航到筛选页面
  navigateToFilter(filterType: string, filterValue: string, title?: string) {
    router.pushUrl({
      url: 'pages/tabs/InspirationFilterPage',
      params: {
        filterType: filterType,
        filterValue: filterValue,
        title: title || filterValue
      }
    });
  }

  build() {
    Stack() {
      Column() {
        // 顶部搜索栏
        Row() {
          TextInput({ placeholder: '搜索灵感创意...' })
            .layoutWeight(1)
            .height(40)
            .borderRadius(20)
            .backgroundColor('#F0F0F0')
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.searchKeyword = value;
              this.applyFilters();
            })
          
          // // 重置按钮
          // Button('重置')
          //   .fontSize(14)
          //   .height(40)
          //   .padding({ left: 16, right: 16 })
          //   .backgroundColor('#FF6B35')
          //   .fontColor(Color.White)
          //   .borderRadius(20)
          //   .margin({ left: 12 })
          //   .onClick(() => {
          //     this.resetAllFilters();
          //   })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor(Color.White)
        
        // 多维度搜索条件栏 - 使用Select组件
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.searchConditions, (condition: SearchCondition) => {
              Select(condition.options.map((option: SearchOption) => {
                const selectOption: SelectOption = { value: option.label };
                return selectOption;
              }))
                .selected(condition.options.findIndex(option => option.value === condition.selectedValue))
                .value(condition.selectedLabel || condition.label)
                .font({ size: 12 })
                .fontColor('#333333')
                .selectedOptionFont({ size: 12 })
                .optionFont({ size: 12 })
                .backgroundColor('#F8F8F8')
                .borderRadius(16)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .height(28)
                .optionHeight(300)
                .constraintSize({ minWidth: 60 })
                .border({
                  width: 1,
                  color: condition.selectedValue ? '#4CAF50' : '#E0E0E0'
                })
                .onSelect((index: number) => {
                  this.selectSearchOption(condition.id, condition.options[index]);
                })
            }, (condition: SearchCondition) => condition.id)
          }
          .padding({ left: 16, right: 16 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .padding({ top: 12, bottom: 12 })

        if (this.isLoading) {
          // 加载状态
          Column() {
            LoadingProgress()
              .width(50)
              .height(50)
              .color('#FF6B35')
            
            Text('加载中...')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 12 })
          }
          .width('100%')
          .height('60%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          Scroll() {
            Column() {
              // 灵感推荐列表
              Column() {
                Row() {
                  Text('灵感推荐')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                  
                  Blank()
                  
                  Text(`共${this.filteredInspirations.length}个创意`)
                    .fontSize(12)
                    .fontColor('#666666')
                }
                .width('100%')
                .margin({ bottom: 12 })
                
                if (this.filteredInspirations.length === 0) {
                  Column() {
                    Image($r('app.media.icon_empty'))
                      .width(173)
                      .height(128)
                      .margin({ bottom: 16 })
                    
                    Text('暂无匹配的灵感')
                      .fontSize(16)
                      .fontColor('#666666')
                      .margin({ bottom: 12 })
                    
                    Text('试试调整筛选条件或搜索关键词')
                      .fontSize(14)
                      .fontColor('#999999')
                  }
                  .width('100%')
                  .layoutWeight(1)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .padding({ left: 24, right: 24 })
                } else {
                  ForEach(this.filteredInspirations, (inspiration: Inspiration) => {
                    this.buildInspirationCard(inspiration)
                  }, (inspiration: Inspiration) => (inspiration.id || 0).toString())
                }
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16, bottom: 106 })
              .justifyContent(FlexAlign.Start)
              .alignItems(HorizontalAlign.Start)
            }
          }
          .scrollBar(BarState.Off)
}
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8F9FA')
      

    }
     .width('100%')
     .height('100%')
   }
   
   @Builder
  buildInspirationCard(inspiration: Inspiration) {
    Column() {
      Row() {
        Column() {
          Text(inspiration.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })
          
          Text(inspiration.description)
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 12 })
          
          // 标签 - 使用新的TagComponent
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start}) {
            ForEach(inspiration.tags.slice(0, 3), (tag: string) => {
              TagComponent({
                tagInfo: this.createTagInfo(tag),
                tagFontSize: 10,
                tagClickable: false,
                tagSelected: false
              }).margin(2)
            })
          }
          
          // 难度标签
          Row() {
            Text(inspiration.difficulty === 'easy' ? '简单' : inspiration.difficulty === 'medium' ? '中等' : '困难')
              .fontSize(10)
              .fontColor(inspiration.difficulty === 'easy' ? '#4CAF50' : inspiration.difficulty === 'medium' ? '#FF9800' : '#F44336')
              .backgroundColor(inspiration.difficulty === 'easy' ? '#E8F5E8' : inspiration.difficulty === 'medium' ? '#FFF3E0' : '#FFEBEE')
              .borderRadius(10)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .margin(2) // 与TagComponent保持一致的margin
          }
          .margin({ top: 8 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        
        // 缩略图 - 横图比例
        if (inspiration.images && inspiration.images.length > 0) {
          Image(inspiration.images[0])
            .width(120)
            .height(80)
            .borderRadius(8)
            .objectFit(ImageFit.Cover)
        } else {
          Column() {
            Image($r('app.media.ic_gift_placeholder'))
              .width(80)
              .height(53)
          }
          .width(120)
          .height(80)
          .backgroundColor('#F0F0F0')
          .borderRadius(8)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .margin({ left: 16 }) // 增加左边距
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 16 }) // 增加底部间距
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 }) // 添加阴影效果
    .onClick(() => {
      this.navigateToInspirationDetail(inspiration);
    })
  }

  // 辅助方法：根据标签字符串或枚举值创建TagInfo对象
  private createTagInfo(tag: string): TagInfo {
    // 首先检查是否是枚举值，如果是则直接使用getTagInfo
    // 检查是否是RecipientType枚举值
    if (tag === RecipientType.BOYFRIEND || tag === RecipientType.GIRLFRIEND || 
        tag === RecipientType.FATHER || tag === RecipientType.MOTHER || 
        tag === RecipientType.FRIEND || tag === RecipientType.COLLEAGUE || 
        tag === RecipientType.CHILD || tag === RecipientType.ELDER_RELATIVE ||
        tag === RecipientType.GRANDFATHER || tag === RecipientType.GRANDMOTHER ||
        tag === RecipientType.HUSBAND || tag === RecipientType.WIFE ||
        tag === RecipientType.BESTIE || tag === RecipientType.BOSS ||
        tag === RecipientType.TEACHER || tag === RecipientType.SIBLING ||
        tag === RecipientType.CLASSMATE || tag === RecipientType.NEIGHBOR ||
        tag === RecipientType.CLIENT || tag === RecipientType.OTHER) {
      const tagInfo = getTagInfo(TagCategory.RECIPIENT, tag);
      if (tagInfo) return tagInfo;
    }
    
    // 检查是否是OccasionType枚举值
    if (tag === OccasionType.BIRTHDAY || tag === OccasionType.VALENTINE_DAY || 
        tag === OccasionType.ANNIVERSARY || tag === OccasionType.CHRISTMAS || 
        tag === OccasionType.NEW_YEAR || tag === OccasionType.MOTHERS_DAY || 
        tag === OccasionType.FATHERS_DAY || tag === OccasionType.GRADUATION || 
        tag === OccasionType.WEDDING || tag === OccasionType.PROMOTION || 
        tag === OccasionType.HOUSEWARMING || tag === OccasionType.APOLOGY || 
        tag === OccasionType.THANK_YOU || tag === OccasionType.GET_WELL) {
      const tagInfo = getTagInfo(TagCategory.OCCASION, tag);
      if (tagInfo) return tagInfo;
    }
    
    // 检查是否是GiftType枚举值
    if (tag === GiftType.JEWELRY || tag === GiftType.BOOKS_STATIONERY || 
        tag === GiftType.TECH_DIGITAL || tag === GiftType.DAILY_ITEMS || 
        tag === GiftType.FOOD_BEVERAGE || tag === GiftType.TRAVEL_OUTDOOR || 
        tag === GiftType.DIY_HANDMADE || tag === GiftType.EXPERIENCE || 
        tag === GiftType.HOME_DECOR || tag === GiftType.SPORTS_FITNESS || 
        tag === GiftType.CREATIVE_NOVEL) {
      const tagInfo = getTagInfo(TagCategory.GIFT_TYPE, tag);
      if (tagInfo) return tagInfo;
    }
    
    // 检查是否是BudgetRangeEnum枚举值
    if (tag === BudgetRangeEnum.UNDER_50 || tag === BudgetRangeEnum.RANGE_50_100 || 
        tag === BudgetRangeEnum.RANGE_100_200 || tag === BudgetRangeEnum.RANGE_200_500 || 
        tag === BudgetRangeEnum.RANGE_500_1000 || tag === BudgetRangeEnum.RANGE_1000_2000 || 
        tag === BudgetRangeEnum.OVER_2000) {
      const tagInfo = getTagInfo(TagCategory.BUDGET, tag);
      if (tagInfo) return tagInfo;
    }
    
    // 如果不是枚举值，尝试按字符串查找
    let tagInfo = getTagInfo(TagCategory.GIFT_TYPE, tag);
    if (!tagInfo) {
      tagInfo = getTagInfo(TagCategory.RECIPIENT, tag);
    }
    if (!tagInfo) {
      tagInfo = getTagInfo(TagCategory.OCCASION, tag);
    }
    if (!tagInfo) {
      tagInfo = getTagInfo(TagCategory.BUDGET, tag);
    }
    
    // 如果找不到匹配的标签，创建一个默认的TagInfo
    if (!tagInfo) {
      const defaultTagInfo: TagInfo = {
        category: TagCategory.GIFT_TYPE,
        value: tag,
        label: tag,
        color: '#B2BEC3' // 默认灰色
      };
      return defaultTagInfo;
    }
    
    return tagInfo;
  }
}