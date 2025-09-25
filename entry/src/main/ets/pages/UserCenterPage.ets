import { Gift, GiftCategory, Scenario } from '../model/GiftModel';
import { GiftRecommendationService } from '../service/GiftRecommendationService';
import router from '@ohos.router';

// 用户信息接口
interface UserInfo {
  id: string;
  name: string;
  avatar: string;
  email: string;
  phone: string;
  memberLevel: string;
  joinDate: string;
}

// 价格区间接口
interface PriceRange {
  min: number;
  max: number;
}

// 用户偏好设置接口
interface UserPreferences {
  favoriteCategories: GiftCategory[];
  priceRange: PriceRange;
  reminderEnabled: boolean;
  notificationEnabled: boolean;
  theme: 'light' | 'dark';
}

// 历史记录接口
interface GiftHistory {
  id: string;
  gift: Gift;
  viewTime: string;
  action: 'view' | 'favorite' | 'share';
}

@Entry
@Component
struct UserCenterPage {
  @State userInfo: UserInfo = {
    id: '1',
    name: '礼物达人',
    avatar: '👤',
    email: 'user@example.com',
    phone: '138****8888',
    memberLevel: 'VIP',
    joinDate: '2023-01-01'
  };
  @State favoriteGifts: Gift[] = [];
  @State giftHistory: GiftHistory[] = [];
  @State userPreferences: UserPreferences = {
    favoriteCategories: [GiftCategory.FLOWERS, GiftCategory.JEWELRY],
    priceRange: { min: 100, max: 1000 } as PriceRange,
    reminderEnabled: true,
    notificationEnabled: true,
    theme: 'light'
  };
  @State currentTab: number = 0;
  @State loading: boolean = false;
  private giftService: GiftRecommendationService = GiftRecommendationService.getInstance();

  aboutToAppear() {
    this.loadUserData();
  }

  build() {
    Column() {
      this.buildHeader()
      this.buildUserProfile()
      this.buildTabBar()
      this.buildTabContent()
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

      Text('个人中心')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text('⚙️')
        .fontSize(24)
        .onClick(() => {
          // 跳转到设置页面
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
  buildUserProfile() {
    Column() {
      Row() {
        // 头像
        Column() {
          Text(this.userInfo.avatar)
            .fontSize(40)
        }
        .width(80)
        .height(80)
        .backgroundColor('#E3F2FD')
        .borderRadius(40)
        .justifyContent(FlexAlign.Center)
        .margin({ right: 16 })

        // 用户信息
        Column() {
          Row() {
            Text(this.userInfo.name)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            
            Text(this.userInfo.memberLevel)
              .fontSize(12)
              .fontColor('#FF9800')
              .backgroundColor('#FFF3E0')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .borderRadius(10)
              .margin({ left: 8 })
          }
          .margin({ bottom: 8 })

          Text(`邮箱: ${this.userInfo.email}`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 4 })

          Text(`手机: ${this.userInfo.phone}`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 4 })

          Text(`加入时间: ${this.userInfo.joinDate}`)
            .fontSize(12)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 统计信息
      Row() {
        this.buildStatItem('收藏', this.favoriteGifts.length.toString())
        this.buildStatItem('浏览', this.giftHistory.length.toString())
        this.buildStatItem('分享', '12')
        this.buildStatItem('积分', '2580')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .margin({ bottom: 16 })
  }

  @Builder
  buildStatItem(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#4CAF50')
        .margin({ bottom: 4 })
      
      Text(label)
        .fontSize(12)
        .fontColor('#999999')
    }
  }

  @Builder
  buildTabBar() {
    Row() {
      this.buildTabItem('收藏夹', 0)
      this.buildTabItem('浏览历史', 1)
      this.buildTabItem('偏好设置', 2)
    }
    .width('100%')
    .height(48)
    .backgroundColor(Color.White)
    .margin({ bottom: 16 })
  }

  @Builder
  buildTabItem(title: string, index: number) {
    Text(title)
      .fontSize(16)
      .fontColor(this.currentTab === index ? '#4CAF50' : '#666666')
      .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .height('100%')
      .backgroundColor(this.currentTab === index ? '#E8F5E8' : Color.Transparent)
      .onClick(() => {
        this.currentTab = index;
      })
  }

  @Builder
  buildTabContent() {
    if (this.currentTab === 0) {
      this.buildFavoriteList()
    } else if (this.currentTab === 1) {
      this.buildHistoryList()
    } else {
      this.buildPreferencesSettings()
    }
  }

  @Builder
  buildFavoriteList() {
    if (this.favoriteGifts.length === 0) {
      Column() {
        Text('📝')
          .fontSize(48)
          .margin({ bottom: 16 })
        
        Text('暂无收藏的礼物')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ bottom: 8 })
        
        Text('去发现更多精美礼物吧')
          .fontSize(14)
          .fontColor('#CCCCCC')
        
        Button('去推荐页面')
          .backgroundColor('#4CAF50')
          .fontColor(Color.White)
          .borderRadius(20)
          .margin({ top: 20 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/GiftRecommendationPage' });
          })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.favoriteGifts, (gift: Gift) => {
          ListItem() {
            this.buildGiftCard(gift, true)
          }
          .margin({ bottom: 12 })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
    }
  }

  @Builder
  buildHistoryList() {
    if (this.giftHistory.length === 0) {
      Column() {
        Text('📋')
          .fontSize(48)
          .margin({ bottom: 16 })
        
        Text('暂无浏览记录')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ bottom: 8 })
        
        Text('开始探索礼物世界吧')
          .fontSize(14)
          .fontColor('#CCCCCC')
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.giftHistory, (history: GiftHistory) => {
          ListItem() {
            this.buildHistoryCard(history)
          }
          .margin({ bottom: 12 })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
    }
  }

  @Builder
  buildPreferencesSettings() {
    List() {
      ListItem() {
        this.buildCategoryPreferenceSection()
      }
      .margin({ bottom: 16 })
      
      ListItem() {
        this.buildPriceRangeSection()
      }
      .margin({ bottom: 16 })
      
      ListItem() {
        this.buildNotificationSection()
      }
      .margin({ bottom: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  buildCategoryPreferenceSection() {
    Column() {
      Text('偏好分类')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 12 })
      
      this.buildCategoryPreferences()
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildPriceRangeSection() {
    Column() {
      Text('价格区间')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 12 })
      
      this.buildPriceRangeSettings()
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildNotificationSection() {
    Column() {
      Text('通知设置')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 12 })
      
      this.buildNotificationSettings()
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildCategoryPreferences() {
    Flex({ wrap: FlexWrap.Wrap }) {
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

  @Builder
  buildCategoryChip(label: string, category: GiftCategory) {
    Text(label)
      .fontSize(14)
      .fontColor(this.userPreferences.favoriteCategories.includes(category) ? Color.White : '#666666')
      .backgroundColor(this.userPreferences.favoriteCategories.includes(category) ? '#4CAF50' : '#F0F0F0')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(16)
      .margin({ right: 8, bottom: 8 })
      .onClick(() => {
        const index = this.userPreferences.favoriteCategories.indexOf(category);
        if (index > -1) {
          this.userPreferences.favoriteCategories.splice(index, 1);
        } else {
          this.userPreferences.favoriteCategories.push(category);
        }
      })
  }

  @Builder
  buildPriceRangeSettings() {
    Column() {
      Row() {
        Text('最低价格:')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ right: 8 })
        
        Text(`¥${this.userPreferences.priceRange.min}`)
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .margin({ bottom: 8 })
      
      Row() {
        Text('最高价格:')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ right: 8 })
        
        Text(`¥${this.userPreferences.priceRange.max}`)
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      
      Button('调整价格区间')
        .backgroundColor('#E3F2FD')
        .fontColor('#2196F3')
        .fontSize(14)
        .borderRadius(16)
        .margin({ top: 12 })
        .onClick(() => {
          // 打开价格设置弹窗
        })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildNotificationSettings() {
    Column() {
      Row() {
        Text('送礼提醒')
          .fontSize(14)
          .fontColor('#333333')
          .layoutWeight(1)
        
        Toggle({ type: ToggleType.Switch, isOn: this.userPreferences.reminderEnabled })
          .onChange((isOn: boolean) => {
            this.userPreferences.reminderEnabled = isOn;
          })
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      Row() {
        Text('推送通知')
          .fontSize(14)
          .fontColor('#333333')
          .layoutWeight(1)
        
        Toggle({ type: ToggleType.Switch, isOn: this.userPreferences.notificationEnabled })
          .onChange((isOn: boolean) => {
            this.userPreferences.notificationEnabled = isOn;
          })
      }
      .width('100%')
    }
  }

  @Builder
  buildGiftCard(gift: Gift, showFavorite: boolean = false) {
    Row() {
      // 礼物图片
      Column() {
        Text('🎁')
          .fontSize(24)
      }
      .width(60)
      .height(60)
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
          .margin({ bottom: 4 })
        
        Text(gift.description)
          .fontSize(14)
          .fontColor('#666666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 8 })
        
        Row() {
          Text(`¥${gift.price}`)
            .fontSize(16)
            .fontColor('#FF5722')
            .fontWeight(FontWeight.Bold)
          
          Text(this.getCategoryText(gift.category))
            .fontSize(12)
            .fontColor('#999999')
            .backgroundColor('#F0F0F0')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
            .margin({ left: 8 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 操作按钮
      if (showFavorite) {
        Text('❤️')
          .fontSize(20)
          .onClick(() => {
            // 取消收藏
            const index = this.favoriteGifts.findIndex(item => item.id === gift.id);
            if (index > -1) {
              this.favoriteGifts.splice(index, 1);
            }
          })
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .onClick(() => {
      // 跳转到礼物详情页
    })
  }

  @Builder
  buildHistoryCard(history: GiftHistory) {
    Row() {
      // 礼物图片
      Column() {
        Text('🎁')
          .fontSize(24)
      }
      .width(60)
      .height(60)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 12 })

      // 礼物信息
      Column() {
        Text(history.gift.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ bottom: 4 })
        
        Row() {
          Text(this.getActionText(history.action))
            .fontSize(12)
            .fontColor('#4CAF50')
            .backgroundColor('#E8F5E8')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
          
          Text(history.viewTime)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ left: 8 })
        }
        .margin({ bottom: 4 })
        
        Text(`¥${history.gift.price}`)
          .fontSize(14)
          .fontColor('#FF5722')
          .fontWeight(FontWeight.Medium)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .onClick(() => {
      // 跳转到礼物详情页
    })
  }

  private async loadUserData() {
    this.loading = true;
    
    try {
      // 模拟加载用户数据
      setTimeout(() => {
        // 加载收藏的礼物
        this.favoriteGifts = [];
        
        // 加载浏览历史
        this.giftHistory = [];
        
        this.loading = false;
      }, 1000);
    } catch (error) {
      console.error('加载用户数据失败:', error);
      this.loading = false;
    }
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

  private getActionText(action: string): string {
    switch (action) {
      case 'view':
        return '浏览';
      case 'favorite':
        return '收藏';
      case 'share':
        return '分享';
      default:
        return '未知';
    }
  }
}