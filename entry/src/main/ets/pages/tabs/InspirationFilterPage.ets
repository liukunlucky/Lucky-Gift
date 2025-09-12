import { Inspiration, InspirationTag } from '../../model/NewDataModels';
import { InspirationDAO } from '../../database/InspirationDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';
import { MockData } from '../../data/MockData';
import router from '@ohos.router';

interface RouterParams {
  filterType: string;
  filterValue: string;
  title?: string;
}

interface BudgetRange {
  min: number;
  max: number;
}

@Entry
@Component
struct InspirationFilterPage {
  @State filterType: string = '';
  @State filterValue: string = '';
  @State inspirations: Inspiration[] = [];
  @State filteredInspirations: Inspiration[] = [];
  @State isLoading: boolean = true;
  @State selectedTags: string[] = [];
  @State availableTags: string[] = [];
  @State sortBy: string = 'default'; // default, price_low, price_high, popular
  
  private dbManager = new NewDatabaseManager();
  private inspirationDAO: InspirationDAO = new InspirationDAO(this.dbManager);
  
  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    
    this.filterType = params.filterType || '';
    this.filterValue = params.filterValue || '';
    
    this.loadData();
  }
  
  async loadData() {
    try {
      this.isLoading = true;
      
      // 根据筛选类型加载数据
      switch (this.filterType) {
        case 'category':
          this.inspirations = await this.inspirationDAO.getInspirationsByFilters({ tags: [this.filterValue] });
          break;
        case 'tag':
          this.inspirations = await this.inspirationDAO.getInspirationsByFilters({ tags: [this.filterValue] });
          break;
        case 'budget':
          const budgetRange = this.getBudgetRange(this.filterValue);
          this.inspirations = await this.inspirationDAO.getInspirationsByBudgetRange(
            budgetRange.min, budgetRange.max
          );
          break;
        default:
          this.inspirations = await this.inspirationDAO.getAllInspirations();
      }
      
      // 如果数据库没有数据，使用mock数据
      if (this.inspirations.length === 0) {
        this.inspirations = this.getMockInspirations();
      }
      
      // 暂时使用空数组，后续可以从数据库获取标签
      this.availableTags = [];
      
      this.applyFilters();
    } catch (error) {
      console.error('加载筛选数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  getMockInspirations(): Inspiration[] {
    return MockData.getMockInspirations();
  }
  
  getBudgetRange(budgetType: string): BudgetRange {
    switch (budgetType) {
      case '50元以下':
        return { min: 0, max: 50 };
      case '50-200元':
        return { min: 50, max: 200 };
      case '200-500元':
        return { min: 200, max: 500 };
      case '500元以上':
        return { min: 500, max: 999999 };
      default:
        return { min: 0, max: 999999 };
    }
  }
  
  applyFilters() {
    let filtered = [...this.inspirations];
    
    // 应用标签筛选
    if (this.selectedTags.length > 0) {
      filtered = filtered.filter(inspiration => 
        this.selectedTags.some(tag => inspiration.tags.includes(tag))
      );
    }
    
    // 应用排序
    switch (this.sortBy) {
      case 'price_low':
        filtered.sort((a, b) => (a.budgetRange.min || 0) - (b.budgetRange.min || 0));
        break;
      case 'price_high':
        filtered.sort((a, b) => (b.budgetRange.min || 0) - (a.budgetRange.min || 0));
        break;
      case 'popular':
        filtered.sort(() => 0); // 暂时不支持按热度排序
        break;
    }
    
    this.filteredInspirations = filtered;
  }
  
  toggleTag(tagName: string) {
    const index = this.selectedTags.indexOf(tagName);
    if (index > -1) {
      this.selectedTags.splice(index, 1);
    } else {
      this.selectedTags.push(tagName);
    }
    this.applyFilters();
  }
  
  changeSortBy(sortType: string) {
    this.sortBy = sortType;
    this.applyFilters();
  }
  
  navigateToDetail(inspiration: Inspiration) {
    router.pushUrl({
      url: 'pages/tabs/InspirationDetailPage',
      params: {
        inspirationId: inspiration.id
      }
    });
  }
  
  goBack() {
    router.back();
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Text('←')
          .fontSize(24)
          .fontColor('#333333')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.goBack())
        
        Text(this.getPageTitle())
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Row().width(40) // 占位
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#FF6B35')
          
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Column() {
          // 筛选和排序栏
          Row() {
            // 标签筛选
            if (this.availableTags.length > 0) {
              Scroll() {
                Row() {
                  ForEach(this.availableTags.slice(0, 8), (tag: InspirationTag) => {
                    Button(tag.name)
                      .fontSize(12)
                      .fontColor(this.selectedTags.includes(tag.name) ? '#FFFFFF' : '#666666')
                      .backgroundColor(this.selectedTags.includes(tag.name) ? '#FF6B35' : '#F5F5F5')
                      .borderRadius(16)
                      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                      .margin({ right: 8 })
                      .onClick(() => this.toggleTag(tag.name))
                  })
                }
                .padding({ left: 16, right: 16 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .layoutWeight(1)
            }
            
            // 排序按钮
            Button() {
              Row() {
                Text('排序')
                  .fontSize(12)
                  .fontColor('#666666')
                Text('⇅')
                  .fontSize(16)
                  .fontColor('#666666')
                  .margin({ left: 4 })
              }
            }
            .backgroundColor('#F5F5F5')
            .borderRadius(16)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 16 })
            .onClick(() => {
              // 显示排序选项
            })
          }
          .width('100%')
          .height(48)
          .alignItems(VerticalAlign.Center)
          
          // 结果统计
          Row() {
            Text(`共找到 ${this.filteredInspirations.length} 个创意`)
              .fontSize(14)
              .fontColor('#666666')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          
          // 灵感列表
          if (this.filteredInspirations.length === 0) {
            Column() {
              Text('📭')
                .fontSize(80)
                .width(80)
                .height(80)
              
              Text('暂无相关创意')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 16 })
              
              Text('试试调整筛选条件')
                .fontSize(14)
                .fontColor('#CCCCCC')
                .margin({ top: 8 })
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          } else {
            List() {
              ForEach(this.filteredInspirations, (inspiration: Inspiration) => {
                ListItem() {
                  this.InspirationCard(inspiration)
                }
                .margin({ bottom: 12 })
              })
            }
            .width('100%')
            .layoutWeight(1)
            .padding({ left: 16, right: 16, top: 8 })
          }
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
  
  getPageTitle(): string {
    switch (this.filterType) {
      case 'category':
        return this.filterValue;
      case 'tag':
        return `#${this.filterValue}`;
      case 'budget':
        return this.filterValue;
      default:
        return '灵感筛选';
    }
  }
  
  @Builder
  InspirationCard(inspiration: Inspiration) {
    Column() {
      Row() {
        // 左侧图片
        if (inspiration.images && inspiration.images.length > 0) {
           Image(inspiration.images[0])
             .width(80)
             .height(80)
             .borderRadius(8)
             .objectFit(ImageFit.Cover)
         } else {
           Text('🎁')
             .fontSize(40)
             .width(80)
             .height(80)
             .borderRadius(8)
             .backgroundColor('#F0F0F0')
             .textAlign(TextAlign.Center)
         }
        
        // 右侧内容
        Column() {
          Text(inspiration.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          Text(inspiration.description)
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
          
          // 标签
          if (inspiration.tags.length > 0) {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(inspiration.tags.slice(0, 3), (tag: string) => {
                Text(`#${tag}`)
                  .fontSize(12)
                  .fontColor('#FF6B35')
                  .backgroundColor('#FFF5F0')
                  .borderRadius(10)
                  .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                  .margin({ right: 6, top: 4 })
              })
            }
            .margin({ top: 8 })
          }
          
          // 价格
          if (inspiration.budgetRange.min > 0) {
                Text(`约 ¥${inspiration.budgetRange.min}${inspiration.budgetRange.max > inspiration.budgetRange.min ? '-' + inspiration.budgetRange.max : ''}`)
              .fontSize(14)
              .fontColor('#FF6B35')
              .fontWeight(FontWeight.Medium)
              .margin({ top: 8 })
          }
        }
        .layoutWeight(1)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .padding(16)
    .onClick(() => this.navigateToDetail(inspiration))
  }
}