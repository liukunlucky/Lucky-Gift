import router from '@ohos.router';
import { Inspiration } from '../../model/NewDataModels';
import { InspirationDAO } from '../../database/InspirationDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';
import { 
  RecipientType, 
  OccasionType, 
  BudgetRange as BudgetRangeEnum, 
  GiftType,
  TagInfo,
  TagCategory,
  getTagInfo,
  RecipientTypeNames,
  OccasionTypeNames,
  GiftTypeNames
} from '../../model/GiftEnums';
import { TagComponent } from '../../components/TagComponent';

@Entry
@Component
struct FavoritesPage {
  @State favorites: Inspiration[] = [];
  @State isLoading: boolean = true;
  @State selectedCategory: string = '全部';
  @State searchText: string = '';
  @State showDeleteDialog: boolean = false;
  @State selectedItem: Inspiration | null = null;
  
  private dbManager: NewDatabaseManager = new NewDatabaseManager();
  private inspirationDAO: InspirationDAO | null = null;
  private categories: string[] = [
    '全部',
    // 场合类型
    '生日', '纪念日', '情人节', '圣诞节', '新年', '母亲节', '父亲节', '毕业典礼', '婚礼', '升职加薪', '乔迁新居', '道歉', '感谢', '康复祝福',
    // 收礼人类型  
    '父亲', '母亲', '爷爷/外公', '奶奶/外婆', '其他长辈', '男朋友', '女朋友', '丈夫', '妻子', '闺蜜', '朋友', '同事', '领导', '老师', '小朋友', '兄弟姐妹',
    // 礼物类型
    'DIY手作', '体验服务', '日用实物', '创意新奇', '科技数码', '美妆护肤', '书籍文具', '服装配饰', '食品饮料', '家居装饰', '运动健身', '旅行户外', '珠宝首饰', '鲜花植物'
  ];
  
  // async aboutToAppear() {
  //   // 初始化数据库
  //   await this.dbManager.initDatabase(getContext(this));
  //   this.inspirationDAO = new InspirationDAO(this.dbManager);
  //
  //   this.loadFavorites();
  // }

  async onPageShow() {
    // 初始化数据库
    await this.dbManager.initDatabase(getContext(this));
    this.inspirationDAO = new InspirationDAO(this.dbManager);

    this.loadFavorites();
  }
  
  async loadFavorites() {
    if (!this.inspirationDAO) {
      console.error('数据库未初始化');
      this.isLoading = false;
      return;
    }
    
    this.isLoading = true;
    
    try {
      this.favorites = await this.inspirationDAO.getFavoriteInspirations();
    } catch (error) {
      console.error('加载收藏失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  getFilteredFavorites(): Inspiration[] {
    let filtered = this.favorites;
    
    // 分类筛选
    if (this.selectedCategory !== '全部') {
      // 将显示名称转换为对应的枚举值进行匹配
      const enumValue = this.getEnumValueByDisplayName(this.selectedCategory);
      
      filtered = filtered.filter(item => {
        // 检查targetAudience（收礼人类型）
        if (item.targetAudience && item.targetAudience.includes(enumValue)) {
          return true;
        }
        // 检查occasions（场合类型）
        if (item.occasions && item.occasions.includes(enumValue)) {
          return true;
        }
        // 检查giftType（礼物类型）
        if (item.giftType === enumValue) {
          return true;
        }
        // 检查tags（标签）- 可能包含显示名称
        if (item.tags && item.tags.includes(this.selectedCategory)) {
          return true;
        }
        return false;
      });
    }
    
    // 搜索筛选
    if (this.searchText.trim()) {
      const searchLower = this.searchText.toLowerCase();
      filtered = filtered.filter(item => 
        item.title.toLowerCase().includes(searchLower) ||
        item.description.toLowerCase().includes(searchLower) ||
        item.tags.some(tag => tag.toLowerCase().includes(searchLower))
      );
    }
    
    return filtered;
  }
  
  // 根据显示名称获取对应的枚举值
  private getEnumValueByDisplayName(displayName: string): string {
    // 检查收礼人类型
    const recipientEntries = Object.entries(RecipientTypeNames);
    for (let i = 0; i < recipientEntries.length; i++) {
      const entry = recipientEntries[i];
      const enumKey = entry[0];
      const displayValue = entry[1];
      if (displayValue === displayName) {
        return enumKey;
      }
    }
    
    // 检查场合类型
    const occasionEntries = Object.entries(OccasionTypeNames);
    for (let i = 0; i < occasionEntries.length; i++) {
      const entry = occasionEntries[i];
      const enumKey = entry[0];
      const displayValue = entry[1];
      if (displayValue === displayName) {
        return enumKey;
      }
    }
    
    // 检查礼物类型
    const giftTypeEntries = Object.entries(GiftTypeNames);
    for (let i = 0; i < giftTypeEntries.length; i++) {
      const entry = giftTypeEntries[i];
      const enumKey = entry[0];
      const displayValue = entry[1];
      if (displayValue === displayName) {
        return enumKey;
      }
    }
    
    // 如果没有找到对应的枚举值，返回原始显示名称
    return displayName;
  }
  
  async toggleFavorite(inspiration: Inspiration) {
    if (!inspiration.id || !this.inspirationDAO) return;
    
    try {
      // 调用DAO的取消收藏方法
      await this.inspirationDAO.removeFromFavorites(inspiration.id);
      
      // 从本地收藏列表中移除
      const index = this.favorites.findIndex(item => item.id === inspiration.id);
      if (index > -1) {
        this.favorites.splice(index, 1);
      }
      
      // 触发ProfilePage刷新，更新收藏数量显示
      AppStorage.setOrCreate('refreshProfilePage', Date.now());
    } catch (error) {
      console.error('取消收藏失败:', error);
    }
  }
  
  showDeleteConfirmDialog(inspiration: Inspiration) {
    this.selectedItem = inspiration;
    this.showDeleteDialog = true;
  }
  
  async deleteFromFavorites() {
    if (!this.selectedItem) return;
    
    await this.toggleFavorite(this.selectedItem);
    this.showDeleteDialog = false;
    this.selectedItem = null;
  }
  
  navigateToDetail(inspiration: Inspiration) {
    router.pushUrl({
      url: 'pages/InspirationDetailPage',
      params: {
        inspirationId: inspiration.id
      }
    });
  }
  
  getCategoryColor(category: string): string {
    const colorMap: Record<string, string> = {
      '生日礼物': '#FF6B35',
      '节日礼物': '#4CAF50',
      '纪念日': '#E91E63',
      '表达感谢': '#2196F3',
      '道歉礼物': '#9C27B0',
      '惊喜礼物': '#FF9800'
    };
    return colorMap[category] || '#607D8B';
  }

  // 将标签字符串转换为TagInfo对象，处理枚举值转换为中文名称
  private createTagInfo(tag: string): TagInfo {
    // 首先检查是否是枚举值，如果是则直接使用getTagInfo
    // 检查是否是RecipientType枚举值
    if (tag === RecipientType.BOYFRIEND || tag === RecipientType.GIRLFRIEND || 
        tag === RecipientType.FATHER || tag === RecipientType.MOTHER || 
        tag === RecipientType.FRIEND || tag === RecipientType.COLLEAGUE || 
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
  
  goBack() {
    router.back();
  }

  // 构建左滑操作按钮
  @Builder
  buildSwipeAction(inspiration: Inspiration) {
    Row() {
      Button() {
        Column() {
          Image($r('app.media.icon_like_full'))
            .width(24)
            .height(24)
            .fillColor('#FF6B35')
          Text('取消收藏')
            .fontSize(12)
            .fontColor('#FF6B35')
            .margin({ top: 4 })
        }
      }
      .width(80)
      .backgroundColor(Color.Transparent)
      .height('100%')
      .borderRadius(0)
      .onClick(() => {
        this.showDeleteConfirmDialog(inspiration);
      })
    }
    .height('100%')
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
          this.goBack()
        })
        
        Text('我的收藏')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Row()
          .width(40)
          .height(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      // 搜索栏
      Row() {
        Row() {
          Image($r('app.media.ic_search'))
            .width(20)
            .height(20)
            .fillColor('#999999')
            .margin({ right: 8 })
          
          TextInput({ placeholder: '搜索收藏的灵感...' })
            .fontSize(16)
            .backgroundColor(Color.Transparent)
            .border({ width: 0 })
            .layoutWeight(1)
            .onChange((value: string) => {
              this.searchText = value;
            })
        }
        .width('100%')
        .height(40)
        .backgroundColor('#F8F9FA')
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      
      // 分类筛选
      Scroll() {
        Row() {
          ForEach(this.categories, (category: string) => {
            Button() {
              Text(category)
                .fontSize(14)
                .fontColor(this.selectedCategory === category ? '#FFFFFF' : '#666666')
            }
            .backgroundColor(this.selectedCategory === category ? '#FF6B35' : '#F5F5F5')
            .borderRadius(16)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .margin({ right: 12 })
            .onClick(() => {
              this.selectedCategory = category;
            })
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .backgroundColor('#FFFFFF')
      .padding({ bottom: 16 })
      
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#FF6B35')
          
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        
        if (this.getFilteredFavorites().length === 0) {
          Column() {
            Image($r('app.media.icon_empty'))
              .width(173)
              .height(128)

            Text(this.searchText.trim() || this.selectedCategory !== '全部' ? '没有找到相关收藏' : '还没有收藏任何灵感')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 20 })
            
            if (!this.searchText.trim() && this.selectedCategory === '全部') {
              Text('去浏览页面发现更多创意吧')
                .fontSize(14)
                .fontColor('#CCCCCC')
                .margin({ top: 8 })
            }
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          // 收藏列表
          Column() {
            // 统计信息
            Row() {
              Text(`共 ${this.getFilteredFavorites().length} 个收藏`)
                .fontSize(14)
                .fontColor('#666666')
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 12, top: 12 })
            
            List({ space: 12 }) {
              ForEach(this.getFilteredFavorites(), (inspiration: Inspiration) => {
                ListItem() {
                  Row() {
                    // 左侧内容
                    Column() {
                      // 标题和描述
                      Text(inspiration.title)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .alignSelf(ItemAlign.Start)
                        .margin({ bottom: 4 })
                      
                      Text(inspiration.description)
                        .fontSize(14)
                        .fontColor('#666666')
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .alignSelf(ItemAlign.Start)
                        .margin({ bottom: 8 })
                      
                      // 标签和分类 - 使用统一的TagComponent
                      Row() {
                        // 显示前3个标签，使用TagComponent
                        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start}) {
                          ForEach(inspiration.tags.slice(0, 3), (tag: string) => {
                            TagComponent({
                              tagInfo: this.createTagInfo(tag),
                              tagFontSize: 10,
                              tagClickable: false,
                              tagSelected: false
                            }).margin({ right: 4, bottom: 4 })
                          })
                        }
                        .layoutWeight(1)
                        
                        Text(`¥${inspiration.budgetRange.min}-${inspiration.budgetRange.max}`)
                          .fontSize(12)
                          .fontColor('#FF6B35')
                          .fontWeight(FontWeight.Medium)
                      }
                      .width('100%')
                      .alignItems(VerticalAlign.Center)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    .padding({ right: 12 })
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(12)
                  .alignItems(VerticalAlign.Top)
                  .shadow({
                    radius: 4,
                    color: '#1A000000',
                    offsetX: 0,
                    offsetY: 2
                  })
                  .onClick(() => this.navigateToDetail(inspiration))
                }
                .swipeAction({
                  end: {
                    builder: () => {
                      this.buildSwipeAction(inspiration)
                    }
                  }
                })
              })
            }
            .padding({ left: 16, right: 16, bottom: 16 })
            .layoutWeight(1)
            .scrollBar(BarState.Off)
          }
          .layoutWeight(1)
        }
      }
      
      // 删除确认对话框
      if (this.showDeleteDialog && this.selectedItem) {
        Stack() {
          // 背景遮罩
          Rect()
            .width('100%')
            .height('100%')
            .fill('#80000000')
            .onClick(() => {
              this.showDeleteDialog = false;
              this.selectedItem = null;
            })
          
          // 对话框内容
          Column() {
            Text('取消收藏')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ bottom: 16 })
            
            Text(`确定要取消收藏「${this.selectedItem.title}」吗？`)
              .fontSize(16)
              .fontColor('#666666')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 24 })
            
            Row() {
              Button('取消')
                .fontSize(16)
                .fontColor('#666666')
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .layoutWeight(1)
                .margin({ right: 8 })
                .onClick(() => {
                  this.showDeleteDialog = false;
                  this.selectedItem = null;
                })
              
              Button('确定')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .backgroundColor('#F44336')
                .borderRadius(8)
                .layoutWeight(1)
                .margin({ left: 8 })
                .onClick(() => this.deleteFromFavorites())
            }
            .width('100%')
          }
          .width('80%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .padding(24)
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}