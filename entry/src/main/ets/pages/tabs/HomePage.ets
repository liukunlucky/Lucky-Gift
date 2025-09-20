import router from '@ohos.router';
import { MockData } from '../../data/MockData';
import { Inspiration } from '../../model/NewDataModels';
import { TagInfo, TagCategory, getTagInfo } from '../../model/GiftEnums';
import { RecipientType, OccasionType, GiftType, BudgetRange } from '../../model/GiftEnums';
import { TagComponent } from '../../components/TagComponent';

// 轮播图内容接口
interface BannerItem {
  id: string;
  title: string;
  subtitle: string;
  description: string;
  backgroundColor: string;
  textColor: string;
  icon: Resource;
  actionText?: string;
  actionType?: string;
}

interface FunctionIcon {
  id: string;
  title: string;
  icon: Resource;
  action: () => void;
}

@Component
export struct HomePage {
  tabsController?: TabsController;
  @State private recommendedInspirations: Inspiration[] = [];
  @State bannerItems: BannerItem[] = [];
  @State currentBannerIndex: number = 0;

  aboutToAppear() {
    this.loadRecommendedInspirations();
    this.bannerItems = this.getBannerItems();
  }

  // 随机获取8条灵感数据
  private loadRecommendedInspirations() {
    const allInspirations = MockData.getAllInspirations();
    const shuffled = allInspirations.sort(() => 0.5 - Math.random());
    this.recommendedInspirations = shuffled.slice(0, 8);
  }

  // 获取功能图标配置
  private getFunctionIcons(): FunctionIcon[] {
    const icons: FunctionIcon[] = [];
    
    // 礼物灵感
    const inspiration: FunctionIcon = {
      id: 'inspiration',
      title: '礼物灵感',
      icon: $r('app.media.icon_insp'),
      action: () => {
        // 切换到灵感Tab
        if (this.tabsController) {
          this.tabsController.changeIndex(1);
        }
      }
    };
    icons.push(inspiration);

    // 礼物记录
    const record: FunctionIcon = {
      id: 'record',
      title: '礼物记录',
      icon: $r('app.media.icon_record'),
      action: () => {
        router.pushUrl({
          url: 'pages/tabs/CreateGiftEventPage'
        }).catch((error: Error) => {
          console.error('Failed to navigate to CreateGiftEventPage:', error);
        });
      }
    };
    icons.push(record);

    // 我的收藏
    const favorites: FunctionIcon = {
      id: 'favorites',
      title: '我的收藏',
      icon: $r('app.media.icon_shoucang'),
      action: () => {
        router.pushUrl({
          url: 'pages/profile/FavoritesPage'
        }).catch((error: Error) => {
          console.error('Failed to navigate to FavoritesPage:', error);
        });
      }
    };
    icons.push(favorites);

    // 我的关系
    const relationship: FunctionIcon = {
      id: 'relationship',
      title: '我的关系',
      icon: $r('app.media.icon_rq'),
      action: () => {
        router.pushUrl({
          url: 'pages/profile/RelationshipNetworkPage'
        }).catch((error: Error) => {
          console.error('Failed to navigate to RelationshipNetworkPage:', error);
        });
      }
    };
    icons.push(relationship);

    // 礼物提醒
    const reminder: FunctionIcon = {
      id: 'reminder',
      title: '礼物提醒',
      icon: $r('app.media.icon_ld'),
      action: () => {
        router.pushUrl({
          url: 'pages/profile/GiftReminderPage'
        }).catch((error: Error) => {
          console.error('Failed to navigate to GiftReminderPage:', error);
        });
      }
    };
    icons.push(reminder);

    // 智能推荐
    const smartRecommend: FunctionIcon = {
      id: 'smart_recommend',
      title: '智能推荐',
      icon: $r('app.media.icon_tuijian'),
      action: () => {
        router.pushUrl({
          url: 'pages/tools/SmartRecommendationPage'
        }).catch((error: Error) => {
          console.error('Failed to navigate to SmartRecommendationPage:', error);
        });
      }
    };
    icons.push(smartRecommend);

    // 礼卡制作
    const giftCard: FunctionIcon = {
      id: 'gift_card',
      title: '礼卡制作',
      icon: $r('app.media.icon_heka'),
      action: () => {
        router.pushUrl({
          url: 'pages/tools/GiftCardMakerPage'
        }).catch((error: Error) => {
          console.error('Failed to navigate to GiftCardMakerPage:', error);
        });
      }
    };
    icons.push(giftCard);

    // 场景分类
    const scenario: FunctionIcon = {
      id: 'scenario',
      title: '场景分类',
      icon: $r('app.media.icon_changjing'),
      action: () => {
        router.pushUrl({
          url: 'pages/ScenarioPage'
        }).catch((error: Error) => {
          console.error('Failed to navigate to ScenarioPage:', error);
        });
      }
    };
    icons.push(scenario);

    return icons;
  }

  build() {
    Scroll() {
      Column({ space: 24 }) {
        // 顶部标题区域
        this.buildHeaderSection()

        // 功能图标区域
        this.buildFunctionIconsSection()

        // 轮播图区域
        Column({ space: 12 }) {
          Swiper() {
            ForEach(this.bannerItems, (item: BannerItem) => {
              this.buildBannerItem(item);
            }, (item: BannerItem) => item.id)
          }
          .autoPlay(true)
          .interval(4000)
          .indicator(
            new DotIndicator()
              .itemWidth(8)
              .itemHeight(8)
              .selectedItemWidth(16)
              .selectedItemHeight(8)
              .color('#33FFFFFF')
              .selectedColor('#FFFFFF')
          )
          .loop(true)
          .duration(300)
          .itemSpace(0)
          .width('100%')
          .height(140)
          .onChange((index: number) => {
            this.currentBannerIndex = index;
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16 })

        // 推荐灵感区域
        this.buildRecommendedSection()
      }
      .width('100%')
      .padding({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
    .scrollBar(BarState.Off)
  }

  @Builder
  buildHeaderSection() {
    Column({ space: 8 }) {
      // App名称
      Text('送什么礼')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontFamily('cjzj')
        .fontColor('#2C3E50')

      // 描述文字
      Text('找礼、记礼、送礼超简单')
        .fontSize(16)
        .fontColor($r('app.color.secondary_text_color'))
        .margin({ top: 8 })
    }
    .padding(16)
    .width('100%')
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildFunctionIconsSection() {
    Column({ space: 20 }) {
      // 第一行4个图标
      Row({ space: 20 }) {
        ForEach(this.getFunctionIcons().slice(0, 4), (icon: FunctionIcon) => {
          this.buildFunctionIcon(icon);
        }, (icon: FunctionIcon) => icon.id)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)

      // 第二行4个图标
      Row({ space: 20 }) {
        ForEach(this.getFunctionIcons().slice(4, 8), (icon: FunctionIcon) => {
          this.buildFunctionIcon(icon);
        }, (icon: FunctionIcon) => icon.id)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .padding({left: 16, right: 16})
    .width('100%')
  }

  @Builder
  buildFunctionIcon(icon: FunctionIcon) {
    Column({ space: 8 }) {
      // 圆形背景
      Stack() {
        Circle({ width: 60, height: 60 })
          .fill('#F34F40')
          .shadow({
            radius: 8,
            color: '#00000010',
            offsetX: 0,
            offsetY: 2
          })

        Image(icon.icon)
          .width(32)
          .height(32)
          .fillColor('#FFFFFF')
      }
      .width(60)
      .height(60)

      // 功能名称
      Text(icon.title)
        .fontSize(12)
        .fontColor('#2C3E50')
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width(70)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      icon.action();
    })
  }

  @Builder
  buildRecommendedSection() {
    Column({ space: 16 }) {
      // 标题行
      Row() {
        Text('推荐灵感')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2C3E50')

        Blank()

        Row({ space: 4 }) {
          Text('查看更多')
            .fontSize(14)
            .fontColor('#F34F40')

          Image($r('app.media.ic_arrow_right'))
            .width(12)
            .height(12)
            .fillColor('#F34F40')
        }
        .onClick(() => {
          // 跳转到灵感浏览页面
          router.pushUrl({
            url: 'pages/tabs/BrowsePage'
          }).catch((error: Error) => {
            console.error('Failed to navigate to BrowsePage:', error);
          });
        })
      }
      .width('100%')

      // 灵感列表
      Column() {
        ForEach(this.recommendedInspirations, (inspiration: Inspiration) => {
          this.buildInspirationCard(inspiration);
        }, (inspiration: Inspiration) => inspiration.id || '')
      }
      .width('100%')
    }
    .padding({left: 16, right: 16})
    .width('100%')
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
          
          // 标签 - 使用统一的TagComponent
          if (inspiration.tags && inspiration.tags.length > 0) {
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start}) {
              ForEach(inspiration.tags.slice(0, 3), (tag: string) => {
                TagComponent({
                  tagInfo: this.createTagInfo(tag),
                  tagFontSize: 10,
                  tagClickable: false,
                  tagSelected: false
                }).margin(2)
              }, (tag: string) => tag)
            }
          }

        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        
        // 缩略图 - 横图比例，与灵感页面保持一致
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
          .margin({ left: 16 })
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 16 })
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/InspirationDetailPage',
        params: { inspirationId: inspiration.id }
      }).catch((error: Error) => {
        console.error('Failed to navigate to InspirationDetailPage:', error);
      });
    })
  }

  // 获取标签的中文显示名称
  private getTagDisplayName(tag: string): string {
    const tagInfo = this.createTagInfo(tag);
    return tagInfo.label;
  }

  // 获取轮播图数据
  getBannerItems(): BannerItem[] {
    return [
      {
        id: 'record',
        title: '备忘',
        subtitle: '记录送礼想法',
        description: '记录送礼想法和灵感，不错过任何重要时刻',
        backgroundColor: '#81C784',
        textColor: '#FFFFFF',
        icon: $r('app.media.icon_record'),
        actionType: 'record'
      },
      {
        id: 'reminder',
        title: '送礼提醒',
        subtitle: '重要日期提醒',
        description: '设置重要日期提醒，不错过任何送礼机会',
        backgroundColor: '#64B5F6',
        textColor: '#FFFFFF',
        icon: $r('app.media.icon_rl'),
        actionType: 'reminder'
      },
      {
        id: 'checklist',
        title: '礼物清单检查',
        subtitle: '确保送礼万无一失',
        description: '检查礼物清单，确保每个细节都完美',
        backgroundColor: '#FFB74D',
        textColor: '#FFFFFF',
        icon: $r('app.media.icon_check'),
        actionType: 'checklist'
      },
      {
        id: 'giftcard',
        title: '礼物卡制作器',
        subtitle: '制作精美的礼物卡片',
        description: '制作个性化礼物卡片，让礼物更有意义',
        backgroundColor: '#F06292',
        textColor: '#FFFFFF',
        icon: $r('app.media.icon_hk'),
        actionType: 'giftcard'
      },
      {
        id: 'budget',
        title: '预算计算器',
        subtitle: '合理分配送礼预算',
        description: '智能计算送礼预算，让每一分钱都花得值得',
        backgroundColor: '#A1887F',
        textColor: '#FFFFFF',
        icon: $r('app.media.icon_jsq'),
        actionType: 'budget'
      },
      {
        id: 'countdown',
        title: '节日倒计时',
        subtitle: '不错过重要节日',
        description: '倒计时提醒重要节日，提前准备完美礼物',
        backgroundColor: '#9575CD',
        textColor: '#FFFFFF',
        icon: $r('app.media.icon_rl'),
        actionType: 'countdown'
      }
    ];
  }

  // 处理轮播图动作
  private handleBannerAction(actionType: string): void {
    switch (actionType) {
      case 'record':
        router.pushUrl({
          url: 'pages/tools/QuickRecordPage'
        }).catch((error: Error) => {
          console.error('Failed to navigate to GiftRecordPage:', error);
        });
        break;
      case 'reminder':
        router.pushUrl({
          url: 'pages/profile/GiftReminderPage'
        }).catch((error: Error) => {
          console.error('Failed to navigate to GiftReminderPage:', error);
        });
        break;
      case 'checklist':
        router.pushUrl({
          url: 'pages/tools/GiftChecklistPage'
        }).catch((error: Error) => {
          console.error('Failed to navigate to GiftChecklistPage:', error);
        });
        break;
      case 'giftcard':
        router.pushUrl({
          url: 'pages/tools/GiftCardMakerPage'
        }).catch((error: Error) => {
          console.error('Failed to navigate to GiftCardMakerPage:', error);
        });
        break;
      case 'budget':
        router.pushUrl({
          url: 'pages/tools/BudgetCalculatorPage'
        }).catch((error: Error) => {
          console.error('Failed to navigate to BudgetCalculatorPage:', error);
        });
        break;
      case 'countdown':
        router.pushUrl({
          url: 'pages/tools/HolidayCountdownPage'
        }).catch((error: Error) => {
          console.error('Failed to navigate to HolidayCountdownPage:', error);
        });
        break;
      default:
        break;
    }
  }

  @Builder
  buildBannerItem(item: BannerItem) {
    Row() {
      Column({ space: 8 }) {
        Text(item.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(item.textColor)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Text(item.subtitle)
          .fontSize(14)
          .fontColor(item.textColor)
          .opacity(0.9)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Text(item.description)
           .fontSize(12)
           .fontColor(item.textColor)
           .opacity(0.8)
           .maxLines(2)
           .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      
      Image(item.icon)
        .width(60)
        .height(60)
        .fillColor(item.textColor)
        .opacity(0.8)
    }
    .width('100%')
    .height(140)
    .padding(20)
    .backgroundColor(item.backgroundColor)
    .borderRadius(12)
    .onClick(() => {
      if (item.actionType) {
        this.handleBannerAction(item.actionType);
      }
    })
  }

  // 将标签字符串转换为TagInfo对象，处理枚举值转换为中文名称
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
    
    // 检查是否是BudgetRange枚举值
    if (tag === BudgetRange.UNDER_50 || tag === BudgetRange.RANGE_50_100 || 
        tag === BudgetRange.RANGE_100_200 || tag === BudgetRange.RANGE_200_500 || 
        tag === BudgetRange.RANGE_500_1000 || tag === BudgetRange.RANGE_1000_2000 || 
        tag === BudgetRange.OVER_2000) {
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