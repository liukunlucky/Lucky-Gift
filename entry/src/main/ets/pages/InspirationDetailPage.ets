import router from '@ohos.router';
import { Inspiration } from '../model/NewDataModels';
import { InspirationDAO } from '../database/InspirationDAO';
import { NewDatabaseManager } from '../database/NewDatabaseManager';

@Entry
@Component
struct InspirationDetailPage {
  @State inspiration: Inspiration | null = null;
  @State isLoading: boolean = true;
  @State isFavorite: boolean = false;
  @State showCreateRecordDialog: boolean = false;
  
  private dbManager = new NewDatabaseManager();
  private inspirationDAO: InspirationDAO = new InspirationDAO(this.dbManager);
  private inspirationId: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params.inspirationId) {
      this.inspirationId = params.inspirationId as string;
      this.loadInspirationDetail();
    } else {
      this.navigateBack();
    }
  }

  async loadInspirationDetail() {
    try {
      this.isLoading = true;
      
      // 加载灵感详情
      this.inspiration = await this.inspirationDAO.getInspirationById(this.inspirationId);
      
      if (!this.inspiration) {
        this.navigateBack();
        return;
      }
      
      // 检查是否已收藏
      // 暂时设置为false，后续可以从数据库查询
        this.isFavorite = false;
      
      // 暂时不支持浏览计数功能
      
    } catch (error) {
      console.error('加载灵感详情失败:', error);
      this.navigateBack();
    } finally {
      this.isLoading = false;
    }
  }

  // 切换收藏状态
  async toggleFavorite() {
    if (!this.inspiration) return;
    
    try {
      if (this.isFavorite) {
        await this.inspirationDAO.removeFromFavorites(this.inspirationId);
        this.isFavorite = false;
        // 暂时不支持收藏计数功能
      } else {
        await this.inspirationDAO.addToFavorites(this.inspirationId);
        this.isFavorite = true;
        // 暂时不支持收藏计数功能
      }
    } catch (error) {
      console.error('切换收藏状态失败:', error);
    }
  }

  // 创建礼物记录
  createGiftRecord() {
    if (!this.inspiration) return;
    
    router.pushUrl({
      url: 'pages/CreateGiftEventPage',
      params: {
        inspirationId: this.inspirationId,
        inspirationTitle: this.inspiration.title,
        inspirationDescription: this.inspiration.description
      }
    });
  }

  // 分享灵感
  shareInspiration() {
    if (!this.inspiration) return;
    
    // 这里可以实现分享功能
    console.log('分享灵感:', this.inspiration.title);
  }

  // 返回上一页
  navigateBack() {
    router.back();
  }

  // 获取难度显示文本
  getDifficultyText(difficulty: string): string {
    switch (difficulty) {
      case 'easy': return '简单';
      case 'medium': return '中等';
      case 'hard': return '困难';
      default: return '未知';
    }
  }

  // 获取难度颜色
  getDifficultyColor(difficulty: string): string {
    switch (difficulty) {
      case 'easy': return '#4CAF50';
      case 'medium': return '#FF9800';
      case 'hard': return '#F44336';
      default: return '#666666';
    }
  }

  // 格式化评分
  formatRating(rating: number): string {
    return rating.toFixed(1);
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => {
            this.navigateBack();
          })
        
        Text('灵感详情')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Row() {
          Image($r('app.media.icon_share'))
            .width(24)
            .height(24)
            .fillColor('#666666')
            .margin({ right: 16 })
            .onClick(() => {
              this.shareInspiration();
            })
          
          Image(this.isFavorite ? $r('app.media.icon_ax_full') : $r('app.media.icon_ax'))
            .width(24)
            .height(24)
            .fillColor(this.isFavorite ? '#FF6B35' : '#CCCCCC')
            .onClick(() => {
              this.toggleFavorite();
            })
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

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
        .height('80%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.inspiration) {
        Scroll() {
          Column() {
            // 主图
            if (this.inspiration.images && this.inspiration.images.length > 0) {
              Image(this.inspiration.images[0])
                .width('100%')
                .height(250)
                .objectFit(ImageFit.Cover)
                .backgroundColor('#F0F0F0')
            } else {
              Column() {
                Image($r('app.media.icon_search'))
                  .width(80)
                  .height(80)
                  .fillColor('#CCCCCC')
                
                Text('暂无图片')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 12 })
              }
              .width('100%')
              .height(250)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor('#F8F9FA')
            }

            Column() {
              // 标题和基本信息
              Column() {
                Text(this.inspiration.title)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .margin({ bottom: 12 })
                  .width('100%')
                  .textAlign(TextAlign.Start)
                
                // 标签
                if (this.inspiration.tags && this.inspiration.tags.length > 0) {
                  Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center }) {
                    ForEach(this.inspiration.tags, (tag: string) => {
                      Text(`#${tag}`)
                        .fontSize(12)
                        .fontColor('#FF6B35')
                        .backgroundColor('#FFF0ED')
                        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                        .borderRadius(12)
                        .margin({ right: 8, bottom: 8 })
                    })
                  }
                  .width('100%')
                  .margin({ bottom: 16 })
                }
                
                // 统计信息
                Row() {
                  Row() {
                    Image($r('app.media.icon_search'))
                      .width(16)
                      .height(16)
                      .fillColor('#666666')
                      .margin({ right: 4 })
                    
                    Text('0')
                      .fontSize(12)
                      .fontColor('#666666')
                  }
                  .margin({ right: 16 })
                  
                  Row() {
                    Image($r('app.media.icon_mine'))
                      .width(16)
                      .height(16)
                      .fillColor('#666666')
                      .margin({ right: 4 })
                    
                    Text('0')
                      .fontSize(12)
                      .fontColor('#666666')
                  }
                  .margin({ right: 16 })
                  
                  // 暂时隐藏评分功能
                  if (false) {
                    Row() {
                      Image($r('app.media.icon_tools'))
                        .width(16)
                        .height(16)
                        .fillColor('#666666')
                        .margin({ right: 4 })
                      
                      Text('0.0')
                        .fontSize(12)
                        .fontColor('#666666')
                    }
                  }
                  
                  Blank()
                }
                .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .margin({ bottom: 8 })

              // 详细描述
              Column() {
                Text('创意描述')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .margin({ bottom: 12 })
                  .alignSelf(ItemAlign.Start)
                
                Text(this.inspiration.description)
                  .fontSize(14)
                  .fontColor('#666666')
                  .lineHeight(22)
                  .width('100%')
                  .textAlign(TextAlign.Start)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .margin({ bottom: 8 })

              // 详细内容
              if (this.inspiration.detailedDescription) {
                Column() {
                  Text('实施指南')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333333')
                    .margin({ bottom: 12 })
                    .alignSelf(ItemAlign.Start)
                  
                  Text(this.inspiration.detailedDescription || '暂无详细内容')
                    .fontSize(14)
                    .fontColor('#666666')
                    .lineHeight(22)
                    .width('100%')
                    .textAlign(TextAlign.Start)
                }
                .width('100%')
                .padding(16)
                .backgroundColor(Color.White)
                .margin({ bottom: 8 })
              }

              // 参数信息
              Column() {
                Text('参考信息')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .margin({ bottom: 12 })
                  .alignSelf(ItemAlign.Start)
                
                Column() {
                  if (this.inspiration.difficulty) {
                    Row() {
                      Text('难度等级')
                        .fontSize(14)
                        .fontColor('#666666')
                        .layoutWeight(1)
                      
                      Text(this.getDifficultyText(this.inspiration.difficulty))
                        .fontSize(14)
                        .fontColor(this.getDifficultyColor(this.inspiration.difficulty))
                        .fontWeight(FontWeight.Medium)
                    }
                    .width('100%')
                    .margin({ bottom: 8 })
                  }
                  
                  if (this.inspiration.timeRequired) {
                    Row() {
                      Text('所需时间')
                        .fontSize(14)
                        .fontColor('#666666')
                        .layoutWeight(1)
                      
                      Text(this.inspiration.timeRequired)
                        .fontSize(14)
                        .fontColor('#333333')
                    }
                    .width('100%')
                    .margin({ bottom: 8 })
                  }
                  
                  if (this.inspiration.budgetRange) {
                    Row() {
                      Text('预算范围')
                        .fontSize(14)
                        .fontColor('#666666')
                        .layoutWeight(1)
                      
                      Text(this.inspiration.budgetRange.label)
                        .fontSize(14)
                        .fontColor('#FF6B35')
                        .fontWeight(FontWeight.Medium)
                    }
                    .width('100%')
                  }
                }
                .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .margin({ bottom: 20 })
            }
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        // 底部操作栏
        Row() {
          Button('收藏')
            .layoutWeight(1)
            .height(44)
            .backgroundColor(this.isFavorite ? '#FFE0D6' : '#F0F0F0')
            .fontColor(this.isFavorite ? '#FF6B35' : '#666666')
            .borderRadius(22)
            .margin({ right: 8 })
            .onClick(() => {
              this.toggleFavorite();
            })
          
          Button('创建记录')
            .layoutWeight(2)
            .height(44)
            .backgroundColor('#FF6B35')
            .fontColor(Color.White)
            .borderRadius(22)
            .margin({ left: 8 })
            .onClick(() => {
              this.createGiftRecord();
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .border({ width: { top: 1 }, color: '#F0F0F0' })
      } else {
        // 错误状态
        Column() {
          Image($r('app.media.icon_record'))
            .width(80)
            .height(80)
            .fillColor('#FF6B35')
          
          Text('加载失败')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ top: 16, bottom: 24 })
          
          Button('重新加载')
            .height(40)
            .backgroundColor('#FF6B35')
            .fontColor(Color.White)
            .borderRadius(20)
            .onClick(() => {
              this.loadInspirationDetail();
            })
        }
        .width('100%')
        .height('80%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}