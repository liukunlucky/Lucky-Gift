import router from '@ohos.router';
import { Inspiration } from '../../model/NewDataModels';
import { InspirationDAO } from '../../database/InspirationDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';
import { InspirationDataInitializer } from '../../database/InspirationDataInitializer';

// 快速筛选器接口
interface QuickFilter {
  label: string;
  type: string;
  value: string;
}

// 分类导航接口
interface Category {
  title: string;
  icon: string;
  items: string[];
}

@Component
export struct BrowsePage {
  @State inspirations: Inspiration[] = [];
  @State filteredInspirations: Inspiration[] = [];
  @State selectedFilters: string[] = [];
  @State searchKeyword: string = '';
  @State isLoading: boolean = true;
  
  private dbManager = new NewDatabaseManager();
  private inspirationDAO: InspirationDAO = new InspirationDAO(this.dbManager);
  private dataInitializer: InspirationDataInitializer = new InspirationDataInitializer();
  
  // 快速筛选器配置
  private quickFilters: QuickFilter[] = [
    { label: '生日', type: 'occasion', value: '生日' },
    { label: '父母', type: 'audience', value: '父母' },
    { label: '500元内', type: 'budget', value: '500' },
    { label: '恋人', type: 'audience', value: '恋人' },
    { label: '纪念日', type: 'occasion', value: '纪念日' },
    { label: 'DIY', type: 'type', value: 'DIY手作' }
  ];
  
  // 分类导航配置
  private categories: Category[] = [
    { 
      title: '按对象送', 
      icon: '👥', 
      items: ['父母', '恋人', '朋友', '同事', '孩子', '长辈', '老师', '客户']
    },
    { 
      title: '按场合送', 
      icon: '🎉', 
      items: ['生日', '纪念日', '婚礼', '节日', '毕业', '道歉', '感谢', '庆祝']
    },
    { 
      title: '按兴趣送', 
      icon: '🎯', 
      items: ['美食家', '读书人', '科技迷', '旅行家', '健身达人', '艺术爱好者', '音乐迷', '游戏玩家']
    },
    { 
      title: '按预算送', 
      icon: '💰', 
      items: ['50元以下', '50-200元', '200-500元', '500-1000元', '1000元以上']
    },
    { 
      title: '按类型送', 
      icon: '🎁', 
      items: ['DIY手作', '体验之旅', '贴心日用', '搞怪惊喜', '科技数码', '美妆护肤', '书籍文具', '运动户外']
    }
  ];

  aboutToAppear() {
    this.loadInspirations();
  }

  async loadInspirations() {
    try {
      this.isLoading = true;
      
      // 初始化预置数据（如果需要）
      await this.dataInitializer.initializeAllData();
      
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
    return [
      {
        id: '1',
        title: '为她定制一本专属故事书',
        description: '收集你们的美好回忆，制作成精美的故事书',
        detailedDescription: '这是一份充满爱意的礼物，将你们的点点滴滴记录下来，制作成独一无二的故事书。可以包含照片、文字、手绘插画等元素。',
        images: ['/common/images/story_book.jpg'],
        tags: ['浪漫', '纪念', '定制', 'DIY'],
        targetAudience: ['恋人'],
        occasions: ['纪念日', '生日', '情人节'],
        interests: ['阅读', '艺术'],
        budgetRange: { min: 200, max: 500, label: '200-500元' },
        giftType: 'DIY手作',
        difficulty: 'medium',
        timeRequired: '3-5天',
        materials: ['相册', '打印照片', '彩笔', '装饰贴纸'],
        steps: ['收集照片和回忆', '设计页面布局', '打印和装订', '添加装饰元素'],
        tips: ['提前准备照片', '注意排版美观', '可以加入手写文字'],
        isRecommended: true,
        createdAt: '2024-01-01T00:00:00Z'
      },
      {
        id: '2',
        title: '亲手制作妈妈的养生茶包',
        description: '根据妈妈的体质，调配专属的养生茶',
        detailedDescription: '为妈妈精心调配的养生茶包，既实用又贴心。可以根据季节和妈妈的身体状况选择不同的茶材。',
        images: ['/common/images/tea_package.jpg'],
        tags: ['养生', '健康', '手作', '贴心'],
        targetAudience: ['父母'],
        occasions: ['生日', '母亲节', '日常关怀'],
        interests: ['养生', '茶艺'],
        budgetRange: { min: 50, max: 200, label: '50-200元' },
        giftType: 'DIY手作',
        difficulty: 'easy',
        timeRequired: '1-2天',
        materials: ['各种茶叶', '小布袋', '标签', '包装盒'],
        steps: ['了解妈妈体质', '选择合适茶材', '按比例调配', '包装成小袋'],
        tips: ['咨询中医建议', '注意茶材搭配', '制作精美标签'],
        isRecommended: true,
        createdAt: '2024-01-02T00:00:00Z'
      },
      {
        id: '3',
        title: '智能手环健康管家',
        description: '送给爱运动的朋友，监测健康数据',
        detailedDescription: '现代人越来越注重健康，一款好的智能手环可以帮助朋友更好地管理健康，记录运动数据。',
        images: ['/common/images/smart_watch.jpg'],
        tags: ['科技', '健康', '运动', '实用'],
        targetAudience: ['朋友', '同事'],
        occasions: ['生日', '毕业', '升职'],
        interests: ['健身', '科技'],
        budgetRange: { min: 500, max: 1000, label: '500-1000元' },
        giftType: '科技数码',
        difficulty: 'easy',
        timeRequired: '即买即送',
        isRecommended: false,
        createdAt: '2024-01-03T00:00:00Z'
      }
    ];
  }

  // 应用筛选
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
    
    // 快速筛选器
    this.selectedFilters.forEach(filter => {
      const filterConfig = this.quickFilters.find(f => f.label === filter);
      if (filterConfig) {
        switch (filterConfig.type) {
          case 'occasion':
            result = result.filter(item => item.occasions.includes(filterConfig.value));
            break;
          case 'audience':
            result = result.filter(item => item.targetAudience.includes(filterConfig.value));
            break;
          case 'budget':
            const budget = parseInt(filterConfig.value);
            result = result.filter(item => item.budgetRange.max <= budget);
            break;
          case 'type':
            result = result.filter(item => item.giftType === filterConfig.value);
            break;
        }
      }
    });
    
    this.filteredInspirations = result;
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
    router.pushUrl({
      url: 'pages/CategoryPage',
      params: {
        category: category.title,
        items: category.items
      }
    });
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
        
        Button('搜索')
          .height(40)
          .margin({ left: 12 })
          .backgroundColor('#FF6B35')
          .borderRadius(20)
          .onClick(() => {
            this.applyFilters();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(Color.White)

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
            // 快速筛选器
            Column() {
              Text('快速筛选')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 12 })
                .alignSelf(ItemAlign.Start)
              
              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                ForEach(this.quickFilters, (filter: QuickFilter) => {
                  Button(filter.label)
                    .fontSize(12)
                    .height(32)
                    .padding({ left: 12, right: 12 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(this.selectedFilters.includes(filter.label) ? '#FF6B35' : '#F0F0F0')
                    .fontColor(this.selectedFilters.includes(filter.label) ? Color.White : '#333333')
                    .borderRadius(16)
                    .onClick(() => {
                      this.navigateToFilter('quickFilter', filter.label);
                    })
                })
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .margin({ bottom: 8 })

            // 分类导航
            Column() {
              Text('分类浏览')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 12 })
                .alignSelf(ItemAlign.Start)
              
              Grid() {
                ForEach(this.categories, (category: Category) => {
                  GridItem() {
                    Column() {
                      Text(category.icon)
                        .fontSize(24)
                        .margin({ bottom: 8 })
                      
                      Text(category.title)
                        .fontSize(14)
                        .fontColor('#333333')
                        .textAlign(TextAlign.Center)
                    }
                    .width('100%')
                    .height(80)
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Center)
                    .backgroundColor('#F8F9FA')
                    .borderRadius(12)
                    .onClick(() => {
                      this.navigateToFilter('category', category.title);
                    })
                  }
                })
              }
              .columnsTemplate('1fr 1fr')
              .rowsGap(12)
              .columnsGap(12)
              .height(180)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .margin({ bottom: 8 })

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
                  Text('🔍')
                    .fontSize(48)
                    .margin({ bottom: 12 })
                  
                  Text('暂无匹配的灵感')
                    .fontSize(16)
                    .fontColor('#666666')
                    .margin({ bottom: 8 })
                  
                  Text('试试调整筛选条件或搜索关键词')
                    .fontSize(14)
                    .fontColor('#999999')
                }
                .width('100%')
                .height(200)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              } else {
                ForEach(this.filteredInspirations, (inspiration: Inspiration) => {
                  this.buildInspirationCard(inspiration)
                })
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
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
          
          // 标签
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(inspiration.tags.slice(0, 3), (tag: string) => {
              Text(`#${tag}`)
                .fontSize(10)
                .fontColor('#FF6B35')
                .backgroundColor('#FFF0ED')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ right: 4, bottom: 4 })
            })
          }
          
          // 预算和难度
          Row() {
            Text(inspiration.budgetRange.label)
              .fontSize(12)
              .fontColor('#FF6B35')
              .fontWeight(FontWeight.Medium)
            
            Text('|')
              .fontSize(12)
              .fontColor('#CCCCCC')
              .margin({ left: 8, right: 8 })
            
            Text(inspiration.difficulty === 'easy' ? '简单' : inspiration.difficulty === 'medium' ? '中等' : '困难')
              .fontSize(12)
              .fontColor('#666666')
          }
          .margin({ top: 8 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        
        // 缩略图占位
        Column() {
          Text('🎁')
            .fontSize(32)
        }
        .width(80)
        .height(80)
        .backgroundColor('#F0F0F0')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ left: 12 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 12 })
    .onClick(() => {
      this.navigateToInspirationDetail(inspiration);
    })
  }
}