import router from '@ohos.router';
import { Inspiration } from '../../model/NewDataModels';
import { InspirationDAO } from '../../database/InspirationDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';

@Entry
@Component
struct FavoritesPage {
  @State favorites: Inspiration[] = [];
  @State isLoading: boolean = true;
  @State selectedCategory: string = '全部';
  @State searchText: string = '';
  @State showDeleteDialog: boolean = false;
  @State selectedItem: Inspiration | null = null;
  
  private inspirationDAO: InspirationDAO = new InspirationDAO(new NewDatabaseManager());
  private categories: string[] = ['全部', '生日礼物', '节日礼物', '纪念日', '表达感谢', '道歉礼物', '惊喜礼物'];
  
  aboutToAppear() {
    this.loadFavorites();
  }
  
  async loadFavorites() {
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
      filtered = filtered.filter(item => 
        item.tags.includes(this.selectedCategory) || 
        item.occasions.includes(this.selectedCategory)
      );
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
  
  async toggleFavorite(inspiration: Inspiration) {
    try {
      const updatedInspiration: Inspiration = {
        id: inspiration.id,
        title: inspiration.title,
        description: inspiration.description,
        detailedDescription: inspiration.detailedDescription,
        images: inspiration.images,
        tags: inspiration.tags,
        targetAudience: inspiration.targetAudience,
        occasions: inspiration.occasions,
        interests: inspiration.interests,
        budgetRange: inspiration.budgetRange,
        giftType: inspiration.giftType,
        difficulty: inspiration.difficulty,
        timeRequired: inspiration.timeRequired,
        materials: inspiration.materials,
        steps: inspiration.steps,
        tips: inspiration.tips,
        isRecommended: inspiration.isRecommended,
        createdAt: inspiration.createdAt
      };
      
      const updateData: Inspiration = {
        id: inspiration.id,
        title: inspiration.title,
        description: inspiration.description,
        detailedDescription: inspiration.detailedDescription,
        images: inspiration.images,
        tags: inspiration.tags,
        targetAudience: inspiration.targetAudience,
        occasions: inspiration.occasions,
        interests: inspiration.interests,
        budgetRange: inspiration.budgetRange,
        giftType: inspiration.giftType,
        difficulty: inspiration.difficulty,
        timeRequired: inspiration.timeRequired,
        materials: inspiration.materials,
        steps: inspiration.steps,
        tips: inspiration.tips,
        isRecommended: false,
        createdAt: inspiration.createdAt
      };
      
      if (inspiration.id) {
        await this.inspirationDAO.updateInspiration(inspiration.id, updateData);
      }
      
      // 从收藏列表中移除
      const index = this.favorites.findIndex(item => item.id === inspiration.id);
      if (index > -1) {
        this.favorites.splice(index, 1);
      }
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
      url: 'pages/browse/InspirationDetailPage',
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
  
  goBack() {
    router.back();
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Text('←')
              .fontSize(20)
              .fontColor('#FFFFFF')
            .width(24)
            .height(24)
            .fontColor('#333333')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.goBack())
        
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
            Image($r('app.media.ic_empty'))
              .width(80)
              .height(80)
              .fillColor('#CCCCCC')
            
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
              
              Blank()
              
              Text(`总计 ${this.favorites.length} 个`)
                .fontSize(12)
                .fontColor('#999999')
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 12 })
            
            Scroll() {
              Column() {
                ForEach(this.getFilteredFavorites(), (inspiration: Inspiration) => {
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
                      
                      // 标签和分类
                      Row() {
                        Text(inspiration.tags.length > 0 ? inspiration.tags[0] : '其他')
                          .fontSize(12)
                          .fontColor('#FFFFFF')
                          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                          .backgroundColor(this.getCategoryColor(inspiration.tags.length > 0 ? inspiration.tags[0] : '其他'))
                          .borderRadius(10)
                        
                        if (inspiration.tags.length > 0) {
                          ForEach(inspiration.tags.slice(0, 2), (tag: string) => {
                            Text(`#${tag}`)
                              .fontSize(12)
                              .fontColor('#666666')
                              .margin({ left: 8 })
                          })
                        }
                        
                        Blank()
                        
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
                    
                    // 右侧操作按钮
                    Column() {
                      Button() {
                        Text('❤️')
                  .fontSize(16)
                          .width(20)
                          .height(20)
                          .fontColor('#FF6B35')
                      }
                      .width(36)
                      .height(36)
                      .backgroundColor('#FFF5F0')
                      .borderRadius(18)
                      .margin({ bottom: 8 })
                      .onClick(() => this.showDeleteConfirmDialog(inspiration))
                      
                      Button() {
                        Image($r('app.media.ic_arrow_right'))
                          .width(16)
                          .height(16)
                          .fillColor('#999999')
                      }
                      .width(36)
                      .height(36)
                      .backgroundColor('#F5F5F5')
                      .borderRadius(18)
                      .onClick(() => this.navigateToDetail(inspiration))
                    }
                    .alignItems(HorizontalAlign.Center)
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(12)
                  .margin({ bottom: 12 })
                  .alignItems(VerticalAlign.Top)
                  .shadow({
                    radius: 4,
                    color: '#1A000000',
                    offsetX: 0,
                    offsetY: 2
                  })
                })
              }
              .padding({ left: 16, right: 16, bottom: 16 })
            }
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