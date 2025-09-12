import router from '@ohos.router';
import { Inspiration } from '../../model/NewDataModels';
import { InspirationDAO } from '../../database/InspirationDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';
import { InspirationDataInitializer } from '../../database/InspirationDataInitializer';
import { MockData } from '../../data/MockData';

// 搜索条件接口
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

// 快速筛选器接口（保留兼容）
interface QuickFilter {
  label: string;
  type: string;
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
  @State activeDropdownId: string = '';
  @State showDropdown: boolean = false;
  
  private dbManager = new NewDatabaseManager();
  private inspirationDAO: InspirationDAO = new InspirationDAO(this.dbManager);
  private dataInitializer: InspirationDataInitializer = new InspirationDataInitializer();
  
  // 热门标签配置（替代原快速筛选器）
  private hotTags: QuickFilter[] = [
    { label: '💝 生日必备', type: 'occasion', value: '生日' },
    { label: '❤️ 情侣专属', type: 'audience', value: '恋人' },
    { label: '🎨 DIY手作', type: 'type', value: 'DIY手作' },
    { label: '💰 百元好礼', type: 'budget', value: '200' },
    { label: '🎉 节日庆祝', type: 'occasion', value: '节日' },
    { label: '👨‍👩‍👧‍👦 孝敬父母', type: 'audience', value: '父母' }
  ];
  
  // 分类导航配置（丰富数据）
  private categories: Category[] = [
    { 
      title: '按对象送', 
      icon: $r('app.media.icon_rq'),
      items: ['父母长辈', '恋人爱人', '闺蜜好友', '同事领导', '小朋友', '老师导师', '客户合作伙伴', '兄弟姐妹', '祖父母', '岳父岳母', '新朋友', '网友']
    },
    { 
      title: '按场合送', 
      icon: $r('app.media.icon_ch'),
      items: ['生日庆祝', '结婚纪念', '恋爱纪念日', '毕业典礼', '升职加薪', '乔迁新居', '新生儿诞生', '康复出院', '道歉和解', '感谢答谢', '节日祝福', '开业庆典']
    },
    { 
      title: '按兴趣送', 
      icon: $r('app.media.icon_xq'),
      items: ['美食烹饪', '阅读写作', '科技数码', '旅行摄影', '健身运动', '艺术绘画', '音乐舞蹈', '游戏电竞', '手工制作', '园艺种植', '收藏古玩', '时尚美妆']
    },
    { 
      title: '按预算送', 
      icon:  $r('app.media.icon_money'),
      items: ['50元以下', '50-100元', '100-200元', '200-500元', '500-1000元', '1000-2000元', '2000-5000元', '5000元以上']
    },
    { 
      title: '按类型送', 
      icon: $r('app.media.icon_lx'),
      items: ['DIY手作', '体验服务', '日用实物', '创意新奇', '科技数码', '美妆护肤', '书籍文具', '运动户外', '家居装饰', '珠宝首饰', '服装配饰', '美食特产']
    },
    {
       title: '按季节送',
       icon: $r('app.media.icon_rl'),
       items: ['春季踏青', '夏日清凉', '秋季温馨', '冬日暖心', '情人节', '母亲节', '父亲节', '儿童节', '教师节', '中秋节', '国庆节', '圣诞节']
     }
  ];

  aboutToAppear() {
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
          { label: '父母长辈', value: '父母' },
          { label: '恋人爱人', value: '恋人' },
          { label: '闺蜜好友', value: '朋友' },
          { label: '同事领导', value: '同事' },
          { label: '小朋友', value: '孩子' },
          { label: '老师导师', value: '老师' }
        ]
      },
      {
        id: 'occasion',
        label: '什么场合',
        type: 'occasion',
        options: [
          { label: '不限', value: '' },
          { label: '生日庆祝', value: '生日' },
          { label: '恋爱纪念日', value: '纪念日' },
          { label: '节日祝福', value: '节日' },
          { label: '毕业典礼', value: '毕业' },
          { label: '升职加薪', value: '升职' },
          { label: '感谢答谢', value: '感谢' }
        ]
      },
      {
        id: 'budget',
        label: '预算范围',
        type: 'budget',
        options: [
          { label: '不限', value: '' },
          { label: '50元以下', value: '50' },
          { label: '50-100元', value: '100' },
          { label: '100-200元', value: '200' },
          { label: '200-500元', value: '500' },
          { label: '500-1000元', value: '1000' },
          { label: '1000元以上', value: '9999' }
        ]
      },
      {
        id: 'type',
        label: '礼物类型',
        type: 'type',
        options: [
          { label: '不限', value: '' },
          { label: 'DIY手作', value: 'DIY手作' },
          { label: '体验服务', value: '体验服务' },
          { label: '日用实物', value: '日用实物' },
          { label: '创意新奇', value: '创意新奇' },
          { label: '科技数码', value: '科技数码' },
          { label: '美妆护肤', value: '美妆护肤' }
        ]
      }
    ];
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
            result = result.filter(item => item.targetAudience.includes(condition.selectedValue!));
            break;
          case 'occasion':
            result = result.filter(item => item.occasions.includes(condition.selectedValue!));
            break;
          case 'budget':
            const budget = parseInt(condition.selectedValue!);
            if (budget === 9999) {
              result = result.filter(item => item.budgetRange.max >= 1000);
            } else {
              result = result.filter(item => item.budgetRange.max <= budget);
            }
            break;
          case 'type':
            result = result.filter(item => item.giftType === condition.selectedValue);
            break;
        }
      }
    });
    
    // 兼容原有热门标签筛选
    this.selectedFilters.forEach(filter => {
      const filterConfig = this.hotTags.find(f => f.label === filter);
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
  
  // 显示/隐藏下拉框
  toggleDropdown(conditionId: string) {
    if (this.activeDropdownId === conditionId && this.showDropdown) {
      this.showDropdown = false;
      this.activeDropdownId = '';
    } else {
      this.activeDropdownId = conditionId;
      this.showDropdown = true;
    }
  }
  
  // 选择搜索条件
  selectSearchOption(conditionId: string, option: SearchOption) {
    const conditionIndex = this.searchConditions.findIndex(c => c.id === conditionId);
    if (conditionIndex !== -1) {
      this.searchConditions[conditionIndex].selectedValue = option.value;
      this.searchConditions[conditionIndex].selectedLabel = option.label;
    }
    this.showDropdown = false;
    this.activeDropdownId = '';
    this.applyFilters();
  }
  
  // 重置所有筛选条件
  resetAllFilters() {
    this.searchConditions.forEach(condition => {
      condition.selectedValue = '';
      condition.selectedLabel = '';
    });
    this.selectedFilters = [];
    this.searchKeyword = '';
    this.showDropdown = false;
    this.activeDropdownId = '';
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
          
          // 重置按钮
          Button('重置')
            .fontSize(14)
            .height(40)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#FF6B35')
            .fontColor(Color.White)
            .borderRadius(20)
            .margin({ left: 12 })
            .onClick(() => {
              this.resetAllFilters();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor(Color.White)
        
        // 多维度搜索条件栏
        Row() {
          ForEach(this.searchConditions, (condition: SearchCondition) => {
            Button() {
              Row() {
                Text(condition.selectedLabel || condition.label)
                  .fontSize(14)
                  .fontColor(condition.selectedValue ? Color.White : '#333333')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                
                Text('▼')
                   .fontSize(10)
                   .fontColor(condition.selectedValue ? Color.White : '#666666')
                   .margin({ left: 4 })
              }
            }
            .layoutWeight(1)
            .height(36)
            .backgroundColor(condition.selectedValue ? '#FF6B35' : '#F8F9FA')
            .borderRadius(18)
            .margin({ right: condition.id === 'type' ? 0 : 8 })
            .onClick(() => {
              this.toggleDropdown(condition.id);
            })
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })
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
                    Image($r('app.media.icon_search'))
                      .width(64)
                      .height(64)
                      .fillColor('#CCCCCC')
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
                  .height(200)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .padding({ left: 24, right: 24 })
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
      
      // 下拉框 - 在搜索条件栏下方展开
      if (this.showDropdown) {
        Column() {
          // 占位空间 - 搜索栏和条件栏的高度
          Column()
            .width('100%')
            .height(104) // 搜索栏40+padding24 + 条件栏36+padding12 = 112，调整为104
          
          // 下拉选项列表
          Column() {
            ForEach(this.searchConditions.find(c => c.id === this.activeDropdownId)?.options || [], (option: SearchOption) => {
              Row() {
                Text(option.label)
                  .fontSize(16)
                  .fontColor('#333333')
                  .layoutWeight(1)
                
                if (this.searchConditions.find(c => c.id === this.activeDropdownId)?.selectedValue === option.value) {
                   Text('✓')
                     .fontSize(16)
                     .fontColor('#FF6B35')
                     .fontWeight(FontWeight.Bold)
                 }
              }
              .width('100%')
              .height(50)
              .padding({ left: 20, right: 20 })
              .backgroundColor(Color.White)
              .onClick(() => {
                this.selectSearchOption(this.activeDropdownId, option);
              })
              
              if (option !== (this.searchConditions.find(c => c.id === this.activeDropdownId)?.options || []).slice(-1)[0]) {
                Divider()
                  .height(1)
                  .color('#F0F0F0')
              }
            })
          }
           .width('90%')
           .height(250)
           .backgroundColor(Color.White)
           .borderRadius(8)
           .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
           .margin({ left: 16, right: 16 })
          
          // 剩余空间 - 点击关闭下拉框
          Column()
            .width('100%')
            .layoutWeight(1)
            .onClick(() => {
              this.showDropdown = false;
              this.activeDropdownId = '';
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
      }
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
          Image($r('app.media.ic_gift_placeholder'))
                 .width(60)
                 .height(60)
        }
        .width(80)
        .height(80)
        .backgroundColor('#F0F0F0')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ left: 16 }) // 增加左边距
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
}