import router from '@ohos.router';
import { GiftDAO } from '../database/GiftDAO';
import { Gift, UserReview, PurchaseLink } from '../model/DataModels';

@Entry
@Component
struct GiftDetailPage {
  @State gift: Gift | null = null;
  @State reviews: UserReview[] = [];
  @State similarGifts: Gift[] = [];
  @State isLoading: boolean = true;
  @State currentImageIndex: number = 0;
  @State showFullDescription: boolean = false;
  @State isFavorite: boolean = false;
  
  private giftDAO: GiftDAO = new GiftDAO();
  private giftId: string = '';
  
  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    this.giftId = params?.giftId as string || '';
    
    if (this.giftId) {
      this.loadGiftDetail();
    } else {
      this.isLoading = false;
    }
  }
  
  private async loadGiftDetail() {
    try {
      this.isLoading = true;
      
      // 从数据库获取礼物详情
      this.gift = await this.giftDAO.getGiftById(this.giftId);
      
      if (this.gift) {
        // 获取相似礼物
        this.similarGifts = await this.giftDAO.getGiftsByCategory(this.gift.category, 5);
        // 过滤掉当前礼物
        this.similarGifts = this.similarGifts.filter(g => g.id !== this.giftId);
        
        // 模拟评论数据（实际应用中可以从数据库获取）
        this.reviews = this.getMockReviews();
      }
    } catch (error) {
      console.error('加载礼物详情失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
  

  

  
  private getMockReviews(): UserReview[] {
    return [
      {
        id: '1',
        userName: '小美',
        avatar: 'https://example.com/avatar1.jpg',
        rating: 5,
        comment: '非常漂亮的项链，水晶很亮，做工精致，女朋友很喜欢！',
        date: '2024-01-15',
        images: ['https://example.com/review1.jpg']
      },
      {
        id: '2',
        userName: '阳光男孩',
        avatar: 'https://example.com/avatar2.jpg',
        rating: 4,
        comment: '质量不错，包装也很精美，就是价格有点贵',
        date: '2024-01-10'
      },
      {
        id: '3',
        userName: '温柔女子',
        avatar: 'https://example.com/avatar3.jpg',
        rating: 5,
        comment: '收到了，很满意！水晶闪闪发光，戴上很显气质',
        date: '2024-01-08'
      }
    ];
  }
  
  private toggleFavorite() {
    this.isFavorite = !this.isFavorite;
  }
  
  private handlePurchase() {
    // 购买逻辑
    console.log('购买礼物:', this.gift?.name);
  }
  
  private navigateToGiftDetail(giftId: string) {
    router.pushUrl({
      url: 'pages/GiftDetailPage',
      params: { giftId: giftId }
    });
  }
  
  build() {
    Column() {
      // 顶部导航栏
      this.buildNavigationBar()
      
      if (this.isLoading) {
        this.buildLoadingView()
      } else if (this.gift) {
        Scroll() {
          Column() {
            // 商品图片轮播
            this.buildImageCarousel()
            
            // 商品基本信息
            this.buildBasicInfo()
            
            // 商品详情
            this.buildDetailInfo()
            
            // 购买链接
            this.buildPurchaseLinks()
            
            // 用户评价
            this.buildReviews()
            
            // 相似推荐
            this.buildSimilarGifts()
          }
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .layoutWeight(1)
        
        // 底部操作栏
        this.buildBottomActions()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
  
  @Builder
  buildNavigationBar() {
    Row() {
      Text('←')
        .fontSize(24)
        .fontColor('#333333')
        .onClick(() => {
          router.back();
        })
      
      Text('礼物详情')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      Text('⋯')
        .fontSize(24)
        .fontColor('#333333')
        .onClick(() => {
          // 分享功能
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }
  
  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#4CAF50')
      
      Text('加载中...')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
  
  @Builder
  buildImageCarousel() {
    Stack() {
      Image(this.gift!.imageUrl)
        .width('100%')
        .height(300)
        .objectFit(ImageFit.Cover)
      
      // 收藏按钮
      Row() {
        Text(this.isFavorite ? '❤️' : '🤍')
          .fontSize(24)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding({ top: 16, right: 16 })
      .onClick(() => {
        this.isFavorite = !this.isFavorite;
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
  }
  
  @Builder
  buildBasicInfo() {
    Column() {
      // 商品名称
      Text(this.gift!.name)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 8 })
      
      // 价格和评分
      Row() {
        Text(`¥${this.gift!.price}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF6B35')
        
        Blank()
        
        Row() {
          ForEach([0, 1, 2, 3, 4], (index: number) => {
            Text(index < Math.floor(this.gift!.rating) ? '⭐' : '☆')
              .fontSize(16)
              .fontColor(index < Math.floor(this.gift!.rating) ? '#FFD700' : '#E0E0E0')
          })
          
          Text(`${this.gift!.rating}`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 4 })
          
          Text(`(${this.gift!.reviewCount}条评价)`)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ left: 4 })
        }
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      // 标签
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.gift!.tags, (tag: string, index: number) => {
          Text(tag)
            .fontSize(12)
            .fontColor('#4CAF50')
            .backgroundColor('#E8F5E8')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(12)
            .margin({ right: 8, bottom: 8 })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })
  }
  
  @Builder
  buildDetailInfo() {
    Column() {
      Row() {
        Text('商品详情')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        
        Blank()
        
        Text(this.showFullDescription ? '收起' : '展开')
          .fontSize(14)
          .fontColor('#4CAF50')
          .onClick(() => {
            this.showFullDescription = !this.showFullDescription;
          })
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      Text(this.gift!.description)
        .fontSize(14)
        .fontColor('#666666')
        .lineHeight(20)
        .maxLines(this.showFullDescription ? undefined : 3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ bottom: 12 })
      
      if (this.gift!.meaning) {
        Column() {
          Text('寓意解读')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .margin({ bottom: 8 })
          
          Text(this.gift!.meaning)
            .fontSize(14)
            .fontColor('#666666')
            .lineHeight(20)
            .width('100%')
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#FFF8E1')
        .borderRadius(8)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })
  }
  
  @Builder
  buildPurchaseLinks() {
    Column() {
      Text('购买渠道')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 12 })
      
      ForEach(this.gift!.purchaseLinks, (link: PurchaseLink, index: number) => {
        Row() {
          Column() {
            Text(link.platform)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
            
            Text(link.inStock ? '有货' : '缺货')
              .fontSize(12)
              .fontColor(link.inStock ? '#4CAF50' : '#FF5722')
          }
          .alignItems(HorizontalAlign.Start)
          
          Blank()
          
          Text(`¥${link.price}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B35')
          
          Button(link.inStock ? '去购买' : '缺货')
            .fontSize(12)
            .backgroundColor(link.inStock ? '#4CAF50' : '#CCCCCC')
            .fontColor(Color.White)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ left: 12 })
            .enabled(link.inStock)
            .onClick(() => {
              if (link.inStock) {
                // 跳转到购买链接
              }
            })
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#F8F8F8')
        .borderRadius(8)
        .margin({ bottom: 8 })
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })
  }
  
  @Builder
  buildReviews() {
    Column() {
      Row() {
        Text('用户评价')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        
        Blank()
        
        Text('查看全部')
          .fontSize(14)
          .fontColor('#4CAF50')
          .onClick(() => {
            // 跳转到评价页面
          })
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      ForEach(this.reviews.slice(0, 3), (review: UserReview, index: number) => {
        Column() {
          Row() {
            Image(review.avatar)
              .width(32)
              .height(32)
              .borderRadius(16)
              .backgroundColor('#E0E0E0')
            
            Column() {
              Text(review.userName)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              
              Row() {
                ForEach([0, 1, 2, 3, 4], (index: number) => {
                  Text(index < review.rating ? '⭐' : '☆')
                    .fontSize(12)
                    .fontColor(index < review.rating ? '#FFD700' : '#E0E0E0')
                })
                
                Text(review.date)
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ left: 8 })
              }
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 8 })
            .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 8 })
          
          Text(review.comment)
            .fontSize(14)
            .fontColor('#666666')
            .lineHeight(20)
            .width('100%')
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#F8F8F8')
        .borderRadius(8)
        .margin({ bottom: 8 })
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })
  }
  
  @Builder
  buildSimilarGifts() {
    Column() {
      Text('相似推荐')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 12 })
      
      Scroll() {
        Row() {
          ForEach(this.similarGifts, (gift: Gift, index: number) => {
            Column() {
              Image(gift.imageUrl)
                .width(120)
                .height(120)
                .borderRadius(8)
                .backgroundColor('#E0E0E0')
              
              Text(gift.name)
                .fontSize(12)
                .fontColor('#333333')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width(120)
                .margin({ top: 8 })
              
              Text(`¥${gift.price}`)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF6B35')
                .margin({ top: 4 })
            }
            .width(120)
            .margin({ right: 12 })
            .onClick(() => this.navigateToGiftDetail(gift.id))
          })
        }
        .padding({ left: 16, right: 16 })
      }
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
    .backgroundColor(Color.White)
  }
  
  @Builder
  buildBottomActions() {
    Row() {
      Button('加入收藏')
        .fontSize(14)
        .backgroundColor(this.isFavorite ? '#FF6B35' : '#E0E0E0')
        .fontColor(this.isFavorite ? Color.White : '#666666')
        .layoutWeight(1)
        .margin({ right: 8 })
        .onClick(this.toggleFavorite.bind(this))
      
      Button('立即购买')
        .fontSize(14)
        .backgroundColor('#4CAF50')
        .fontColor(Color.White)
        .layoutWeight(2)
        .onClick(this.handlePurchase.bind(this))
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .border({ width: { top: 1 }, color: '#E0E0E0' })
  }
}