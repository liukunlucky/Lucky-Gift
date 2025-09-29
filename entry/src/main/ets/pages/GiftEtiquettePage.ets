import router from '@ohos.router';

// 送礼知识分类
interface EtiquetteCategory {
  id: string;
  name: string;
  icon: Resource;
  description: string;
  articles: EtiquetteArticle[];
}

// 送礼知识文章
interface EtiquetteArticle {
  id: string;
  title: string;
  summary: string;
  content: string;
  tags: string[];
  readTime: number; // 阅读时间（分钟）
  difficulty: '入门' | '进阶' | '专家';
  publishDate: string;
  views: number;
  likes: number;
}

@Entry
@Component
struct GiftEtiquettePage {
  @State currentTabIndex: number = 0;
  @State categories: EtiquetteCategory[] = [];
  @State selectedCategory: EtiquetteCategory | null = null;
  @State selectedArticle: EtiquetteArticle | null = null;
  @State showArticleDetail: boolean = false;
  @State searchKeyword: string = '';

  aboutToAppear() {
    this.loadEtiquetteData();
  }

  loadEtiquetteData() {
    this.categories = [
      {
        id: '1',
        name: '商务送礼',
        icon: $r('app.media.icon_money'),
        description: '商务场合的送礼礼仪和技巧',
        articles: [
          {
            id: '1-1',
            title: '商务送礼的基本原则',
            summary: '了解商务送礼的基本礼仪，避免踩雷',
            content: `商务送礼是职场中重要的社交技能，需要遵循以下基本原则：

1. 适度原则
- 礼品价值要适中，不宜过于昂贵
- 避免给对方造成心理负担
- 符合公司政策和法律法规

2. 实用原则
- 选择实用性强的礼品
- 考虑收礼人的实际需求
- 避免过于个人化的物品

3. 文化敏感性
- 了解对方的文化背景
- 避免文化禁忌
- 尊重宗教信仰

4. 时机选择
- 选择合适的送礼时机
- 避免敏感时期
- 注意节日习俗

5. 包装礼仪
- 精美的包装体现用心
- 选择合适的包装风格
- 附上得体的贺卡`,
            tags: ['商务', '礼仪', '原则'],
            readTime: 5,
            difficulty: '入门',
            publishDate: '2024-01-15',
            views: 1250,
            likes: 89
          },
          {
            id: '1-2',
            title: '不同国家的商务送礼文化',
            summary: '了解各国商务送礼的文化差异和注意事项',
            content: `不同国家有着不同的商务送礼文化，了解这些差异有助于避免文化冲突：

中国：
- 重视礼品的寓意
- 避免钟表、白花等不吉利物品
- 数字4要避免，8和6比较吉利
- 双手递送礼品

日本：
- 包装比礼品本身更重要
- 避免偶数花朵
- 不要当面打开礼品
- 鞠躬表示感谢

美国：
- 注重实用性
- 当面打开礼品并表示感谢
- 避免过于昂贵的礼品
- 简单包装即可

欧洲：
- 重视礼品的品质
- 花朵要注意数量和颜色
- 避免过于个人化的礼品
- 准时赴约很重要`,
            tags: ['国际', '文化', '差异'],
            readTime: 8,
            difficulty: '进阶',
            publishDate: '2024-01-20',
            views: 980,
            likes: 67
          },
          {
            id: '1-3',
            title: '商务宴请礼仪',
            summary: '商务宴请中的送礼时机和礼品选择',
            content: `商务宴请是重要的商务社交活动，送礼环节需要特别注意：

宴请前：
- 了解参与人员背景
- 准备适合的伴手礼
- 考虑文化差异
- 确认宴请规格

礼品选择：
- 具有地方特色的礼品
- 公司纪念品
- 高档茶叶或酒类
- 工艺品或书籍

送礼时机：
- 宴请开始时的见面礼
- 宴请结束时的告别礼
- 特殊场合的纪念礼
- 节日庆祝礼品

注意事项：
- 礼品价值要适中
- 包装要精美得体
- 避免过于个人化
- 考虑对方的接受能力`,
            tags: ['宴请', '商务', '社交'],
            readTime: 6,
            difficulty: '进阶',
            publishDate: '2024-01-28',
            views: 756,
            likes: 52
          },
          {
            id: '1-4',
            title: '客户关系维护送礼策略',
            summary: '如何通过送礼维护和发展客户关系',
            content: `客户关系维护是商务成功的关键，合适的送礼策略能够有效促进关系发展：

客户分析：
- 了解客户的个人喜好
- 分析客户的文化背景
- 评估客户的重要程度
- 掌握客户的特殊需求

送礼策略：
- 节日祝福礼品
- 项目成功庆祝礼
- 客户生日纪念礼
- 年终感谢礼品

礼品类型：
- 实用办公用品
- 高档商务礼品
- 地方特色产品
- 定制纪念品

效果评估：
- 观察客户反应
- 跟进后续合作
- 调整送礼策略
- 建立长期关系`,
            tags: ['客户', '关系', '策略'],
            readTime: 7,
            difficulty: '专家',
            publishDate: '2024-02-05',
            views: 892,
            likes: 71
          }
        ]
      },
      {
        id: '2',
        name: '节日送礼',
        icon: $r('app.media.icon_changjing'),
        description: '各种节日的送礼传统和建议',
        articles: [
          {
            id: '2-1',
            title: '春节送礼指南',
            summary: '春节期间的送礼礼仪和推荐礼品',
            content: `春节是中国最重要的传统节日，送礼有着深厚的文化内涵：

传统礼品：
- 年货：坚果、糖果、茶叶
- 酒类：白酒、红酒、黄酒
- 保健品：燕窝、人参、枸杞
- 工艺品：字画、瓷器、玉器

现代选择：
- 电子产品：智能设备、数码产品
- 生活用品：家居用品、厨具
- 体验类：旅游券、SPA券
- 定制礼品：个性化定制

送礼对象：
- 长辈：保健品、传统礼品
- 平辈：实用礼品、时尚用品
- 晚辈：红包、学习用品、玩具
- 领导：高档茶叶、工艺品

注意事项：
- 避免钟表、鞋子等不吉利物品
- 礼品数量要成双
- 包装要喜庆
- 拜年时间要合适`,
            tags: ['春节', '传统', '年货'],
            readTime: 6,
            difficulty: '入门',
            publishDate: '2024-02-01',
            views: 2100,
            likes: 156
          },
          {
            id: '2-2',
            title: '情人节送礼创意指南',
            summary: '让情人节礼物更有创意和意义',
            content: `情人节是表达爱意的重要节日，创意礼物能让感情更加深厚：

经典选择：
- 鲜花：玫瑰、百合、满天星
- 巧克力：手工巧克力、定制包装
- 珠宝：项链、手链、戒指
- 香水：经典香型、限量版

创意礼物：
- 定制相册：记录美好时光
- 手写情书：真挚情感表达
- DIY礼品：手工制作的心意
- 体验礼品：浪漫晚餐、旅行

个性化定制：
- 刻字饰品
- 定制T恤
- 专属香水
- 个人画像

浪漫包装：
- 精美包装盒
- 浪漫卡片
- 特殊包装纸
- 创意展示方式

送礼技巧：
- 制造惊喜
- 选择合适时机
- 营造浪漫氛围
- 真诚表达情感`,
            tags: ['情人节', '浪漫', '创意'],
            readTime: 5,
            difficulty: '入门',
            publishDate: '2024-02-14',
            views: 1890,
            likes: 142
          },
          {
            id: '2-3',
            title: '母亲节感恩礼物推荐',
            summary: '表达对母亲感恩之情的礼物选择',
            content: `母亲节是感恩母爱的特殊日子，礼物要体现孝心和关爱：

健康关怀：
- 保健品：维生素、钙片、燕窝
- 按摩器具：颈椎按摩器、足浴盆
- 体检套餐：全面健康检查
- 运动装备：瑜伽垫、运动鞋

美容护肤：
- 护肤套装：适合年龄的护肤品
- 美容仪器：美容仪、洁面仪
- 化妆品：口红、粉底、眼霜
- SPA体验：美容院护理

生活用品：
- 厨房用具：高档锅具、小家电
- 家居装饰：花瓶、摆件、字画
- 服装配饰：丝巾、包包、首饰
- 智能设备：智能手表、平板电脑

情感表达：
- 亲手制作的礼物
- 全家福照片
- 感谢信或诗歌
- 陪伴时光

贴心服务：
- 家务服务
- 陪伴购物
- 一起旅行
- 学习新技能`,
            tags: ['母亲节', '感恩', '健康'],
            readTime: 6,
            difficulty: '入门',
            publishDate: '2024-05-12',
            views: 1654,
            likes: 118
          },
          {
            id: '2-4',
            title: '圣诞节礼物交换指南',
            summary: '圣诞节礼物交换的规则和创意',
            content: `圣诞节礼物交换是西方传统，现在也成为很多人的节日活动：

交换规则：
- 设定价格范围
- 确定参与人数
- 制定交换方式
- 准备备用礼品

礼品选择：
- 实用小物件：文具、杯子、装饰品
- 美食类：巧克力、饼干、茶叶
- 创意用品：新奇小玩意、DIY套装
- 节日主题：圣诞装饰、节日用品

包装创意：
- 圣诞主题包装纸
- 彩带和蝴蝶结
- 圣诞袜包装
- 创意包装盒

游戏方式：
- 抽签交换
- 神秘圣诞老人
- 白象礼品交换
- 主题礼品交换

注意事项：
- 考虑收礼人喜好
- 避免过于个人化
- 保持神秘感
- 营造节日氛围`,
            tags: ['圣诞节', '交换', '游戏'],
            readTime: 5,
            difficulty: '入门',
            publishDate: '2024-12-20',
            views: 1234,
            likes: 87
          }
        ]
      },
      {
        id: '3',
        name: '人生礼仪',
        icon: $r('app.media.icon_home'),
        description: '人生重要时刻的送礼指导',
        articles: [
          {
            id: '3-1',
            title: '婚礼送礼完全指南',
            summary: '婚礼送礼的礼仪、金额和礼品选择',
            content: `婚礼是人生重要时刻，送礼需要特别用心：

礼金标准：
- 关系亲密程度决定金额
- 参考当地习俗
- 考虑自身经济能力
- 数字要吉利（避免4，选择6、8、9）

礼品选择：
- 实用家居用品：餐具、床品、小家电
- 装饰品：相框、花瓶、摆件
- 体验类：蜜月旅行券、SPA券
- 定制礼品：刻字餐具、定制相册

送礼时机：
- 婚礼当天：礼金为主
- 婚前：可送实用礼品
- 婚后：新居礼品

注意事项：
- 提前了解新人需求
- 避免重复礼品
- 包装要精美
- 附上祝福卡片`,
            tags: ['婚礼', '礼金', '家居'],
            readTime: 7,
            difficulty: '入门',
            publishDate: '2024-01-25',
            views: 1680,
            likes: 124
          },
          {
            id: '3-2',
            title: '生日送礼创意指南',
            summary: '让生日礼物更有意义和创意',
            content: `生日礼物要体现心意和创意，让收礼人感受到特别的关爱：

了解收礼人：
- 兴趣爱好和需求
- 最近的心愿清单
- 生活状态和变化
- 个性特点和喜好

创意礼品类型：
- 定制礼品：刻字饰品、定制相册、个人画像
- 体验礼品：演唱会票、旅行券、课程体验
- DIY礼品：手工制作、烘焙甜点、编织用品
- 惊喜礼品：神秘盒子、寻宝游戏、快闪庆祝

不同年龄段选择：
- 儿童：益智玩具、教育用品、运动器材
- 青少年：时尚用品、电子产品、兴趣用品
- 成年人：实用礼品、奢侈品、体验类
- 老年人：健康用品、怀旧物品、陪伴时光

包装创意：
- 主题包装设计
- 多层惊喜包装
- 环保材料包装
- 互动式包装

送礼技巧：
- 制造惊喜感
- 选择合适时机
- 营造仪式感
- 真诚表达祝福`,
            tags: ['生日', '创意', '个性化'],
            readTime: 6,
            difficulty: '入门',
            publishDate: '2024-03-15',
            views: 1800,
            likes: 134
          },
          {
            id: '3-3',
            title: '儿童生日礼物选择指南',
            summary: '为不同年龄段儿童选择合适的生日礼物',
            content: `儿童生日礼物要考虑年龄特点、安全性和教育意义：

0-2岁婴幼儿：
- 安全玩具：软胶玩具、布书、摇铃
- 益智用品：积木、拼图、音乐盒
- 生活用品：可爱餐具、毛毯、衣服
- 纪念品：手脚印泥、成长相册

3-6岁学龄前：
- 教育玩具：拼图、积木、画板
- 运动用品：滑板车、自行车、球类
- 角色扮演：医生套装、厨房玩具
- 艺术用品：彩笔、橡皮泥、贴纸

7-12岁小学生：
- 科学玩具：显微镜、实验套装
- 益智游戏：魔方、棋类、机器人
- 运动装备：轮滑鞋、羽毛球拍
- 学习用品：文具套装、书籍

13-18岁青少年：
- 电子产品：耳机、平板、智能手表
- 时尚用品：背包、饰品、服装
- 兴趣用品：乐器、画材、运动装备
- 体验礼品：演唱会票、课程体验

安全注意事项：
- 检查年龄适用性
- 确保材质安全
- 避免小零件
- 选择知名品牌`,
            tags: ['儿童', '生日', '年龄'],
            readTime: 6,
            difficulty: '入门',
            publishDate: '2024-06-01',
            views: 2156,
            likes: 178
          },
          {
            id: '3-4',
            title: '老人生日礼物贴心推荐',
            summary: '为长辈选择实用贴心的生日礼物',
            content: `为老人选择生日礼物要考虑实用性、健康性和情感价值：

健康保健：
- 保健品：钙片、维生素、蜂蜜
- 按摩用品：按摩椅、足浴盆、按摩器
- 运动器材：太极剑、健身球、计步器
- 医疗用品：血压计、血糖仪、护腰带

生活便利：
- 智能设备：大字体手机、智能音箱
- 家居用品：防滑垫、夜灯、放大镜
- 厨房用具：电饭煲、豆浆机、保温杯
- 服装配饰：保暖内衣、舒适鞋子

精神慰藉：
- 书籍杂志：养生书籍、回忆录
- 娱乐用品：收音机、棋牌、戏曲光盘
- 植物花卉：好养护的绿植、鲜花
- 宠物陪伴：小鸟、金鱼等

情感表达：
- 全家福照片
- 手写感谢信
- 陪伴时光
- 回忆相册

贴心服务：
- 定期探望
- 帮助家务
- 陪同就医
- 学习新技能

选择原则：
- 实用为主
- 安全第一
- 操作简单
- 情感价值`,
            tags: ['老人', '生日', '健康'],
            readTime: 7,
            difficulty: '入门',
            publishDate: '2024-09-09',
            views: 1432,
            likes: 96
          }
        ]
      },
      {
        id: '4',
        name: '关系维护',
        icon: $r('app.media.icon_heart'),
        description: '通过送礼维护和发展人际关系',
        articles: [
          {
            id: '4-1',
            title: '如何通过送礼增进友谊',
            summary: '用心的礼物如何成为友谊的桥梁',
            content: `送礼是维护友谊的重要方式，关键在于用心而非价值：

了解朋友：
- 观察朋友的兴趣爱好
- 记住重要的日子
- 了解朋友的需求
- 关注朋友的近况

选礼原则：
- 心意比价值更重要
- 个性化胜过标准化
- 实用性考虑
- 纪念意义

时机把握：
- 生日、节日等特殊日子
- 朋友遇到困难时的安慰
- 庆祝朋友的成就
- 平时的小惊喜

创意礼品：
- 手工制作的礼品
- 共同回忆的纪念品
- 朋友一直想要的东西
- 体验类礼品

维护技巧：
- 定期联系
- 记住重要信息
- 真诚表达关心
- 适度而不过分`,
            tags: ['友谊', '关系', '维护'],
            readTime: 5,
            difficulty: '入门',
            publishDate: '2024-02-10',
            views: 1420,
            likes: 98
          }
        ]
      }
    ];
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航
        this.buildHeader()

        // 搜索栏
        // this.buildSearchBar()

        // 内容区域
        if (this.selectedCategory) {
          this.buildCategoryDetail()
        } else {
          this.buildCategoriesGrid()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8F9FA')

      // 文章详情弹窗
      if (this.showArticleDetail && this.selectedArticle) {
        this.buildArticleDetailDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildHeader() {
    Row() {
      if (this.selectedCategory) {
        Image($r('app.media.icon_back'))
          .width(24)
          .height(24)
          .fillColor('#2C3E50')
          .onClick(() => {
            this.selectedCategory = null;
          })
      } else {
        Image($r('app.media.icon_back'))
          .width(24)
          .height(24)
          .fillColor('#2C3E50')
          .onClick(() => {
            router.back();
          })
      }

      Text(this.selectedCategory ? this.selectedCategory.name : '送礼学问')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2C3E50')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Blank().width(24)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: 1 })
  }

  @Builder
  buildSearchBar() {
    Row({ space: 12 }) {
      Row({ space: 8 }) {
        Image($r('app.media.icon_search'))
          .width(16)
          .height(16)
          .fillColor('#7F8C8D')

        TextInput({ placeholder: '搜索送礼知识...', text: this.searchKeyword })
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .placeholderColor('#CCCCCC')
          .border({ width: 0 })
          .fontSize(14)
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
      }
      .layoutWeight(1)
      .height(36)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#F5F5F5')
      .borderRadius(18)

    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
  }

  @Builder
  buildCategoriesGrid() {
    Scroll() {
      Column({ space: 16 }) {
        // 介绍卡片
        this.buildIntroCard()

        // 分类网格
        Grid() {
          ForEach(this.categories, (category: EtiquetteCategory) => {
            GridItem() {
              this.buildCategoryCard(category)
            }
          }, (category: EtiquetteCategory) => category.id)
        }
        .columnsTemplate('1fr 1fr')
        .rowsGap(12)
        .columnsGap(12)
        .width('100%')

        // 热门文章
        this.buildHotArticles()
      }
      .padding(16)
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildIntroCard() {
    Column({ space: 12 }) {
      Text('送礼的艺术')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2C3E50')

      Text('送礼不仅是一种礼仪，更是一门艺术。合适的礼物能够传达心意，增进感情，维护关系。')
        .fontSize(14)
        .fontColor('#7F8C8D')
        .lineHeight(20)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildCategoryCard(category: EtiquetteCategory) {
    Column({ space: 12 }) {
      // 图标
      Stack() {
        Circle({ width: 60, height: 60 })
          .fill('#FFF0ED')

        Image(category.icon)
          .width(32)
          .height(32)
          .fillColor('#FF6B35')
      }

      // 标题
      Text(category.name)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2C3E50')

      // 描述
      Text(category.description)
        .fontSize(12)
        .fontColor('#7F8C8D')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(16)
        .textAlign(TextAlign.Center)

      // 文章数量
      Text(`${category.articles.length}篇文章`)
        .fontSize(10)
        .fontColor('#95A5A6')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      this.selectedCategory = category;
    })
  }

  @Builder
  buildHotArticles() {
    Column({ space: 12 }) {
      Text('热门文章')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2C3E50')

      Column({ space: 8 }) {
        ForEach(this.getHotArticles(), (article: EtiquetteArticle) => {
          this.buildHotArticleItem(article)
        }, (article: EtiquetteArticle) => article.id)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildHotArticleItem(article: EtiquetteArticle) {
    Row({ space: 12 }) {
      // 热门标识
      Text('热')
        .fontSize(10)
        .fontColor(Color.White)
        .width(20)
        .height(20)
        .textAlign(TextAlign.Center)
        .backgroundColor('#FF6B35')
        .borderRadius(10)

      // 文章信息
      Column({ space: 4 }) {
        Text(article.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2C3E50')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: 8 }) {
          Text(`${article.readTime}分钟`)
            .fontSize(10)
            .fontColor('#95A5A6')

          Text(`${article.views}阅读`)
            .fontSize(10)
            .fontColor('#95A5A6')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(8)
    .backgroundColor('#F8F9FA')
    .borderRadius(8)
    .onClick(() => {
      this.selectedArticle = article;
      this.showArticleDetail = true;
    })
  }

  @Builder
  buildCategoryDetail() {
    if (this.selectedCategory) {
      List({ space: 12 }) {
        ForEach(this.selectedCategory.articles, (article: EtiquetteArticle) => {
          ListItem() {
            this.buildArticleCard(article)
          }
        }, (article: EtiquetteArticle) => article.id)
      }
      .width('100%')
      .layoutWeight(1)
      .padding(16)
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  buildArticleCard(article: EtiquetteArticle) {
    Column({ space: 12 }) {
      // 标题和难度
      Row() {
        Text(article.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2C3E50')
          .layoutWeight(1)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(article.difficulty)
          .fontSize(10)
          .fontColor(this.getDifficultyColor(article.difficulty))
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor(this.getDifficultyBgColor(article.difficulty))
          .borderRadius(8)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      // 摘要
      Text(article.summary)
        .fontSize(14)
        .fontColor('#7F8C8D')
        .lineHeight(18)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 标签
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(article.tags, (tag: string) => {
          Text(`#${tag}`)
            .fontSize(10)
            .fontColor('#FF6B35')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor('#FFF0ED')
            .borderRadius(8)
        }, (tag: string) => tag)
      }

      // 底部信息
      Row() {
        Text(`${article.readTime}分钟阅读`)
          .fontSize(10)
          .fontColor('#95A5A6')

        Blank()

        Row({ space: 12 }) {
          Row({ space: 4 }) {
            Image($r('app.media.icon_eye'))
              .width(12)
              .height(12)
              .fillColor('#95A5A6')

            Text(article.views.toString())
              .fontSize(10)
              .fontColor('#95A5A6')
          }

          Row({ space: 4 }) {
            Image($r('app.media.icon_like'))
              .width(12)
              .height(12)
              .fillColor('#95A5A6')

            Text(article.likes.toString())
              .fontSize(10)
              .fontColor('#95A5A6')
          }
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      this.selectedArticle = article;
      this.showArticleDetail = true;
    })
  }

  @Builder
  buildArticleDetailDialog() {
    if (this.selectedArticle) {
      Stack() {
        // 遮罩
        Stack() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#80000000')
            .onClick(() => {
              this.showArticleDetail = false;
            })

          // 详情内容
          Column({ space: 0 }) {
            // 标题栏
            Row() {
              Text(this.selectedArticle.title)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2C3E50')
                .layoutWeight(1)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Image($r('app.media.icon_close'))
                .width(24)
                .height(24)
                .fillColor('#7F8C8D')
                .onClick(() => {
                  this.showArticleDetail = false;
                })
            }
            .width('100%')
            .padding(20)

            // 文章信息
            Row({ space: 12 }) {
              Text(this.selectedArticle.difficulty)
                .fontSize(10)
                .fontColor(this.getDifficultyColor(this.selectedArticle.difficulty))
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .backgroundColor(this.getDifficultyBgColor(this.selectedArticle.difficulty))
                .borderRadius(8)

              Text(`${this.selectedArticle.readTime}分钟阅读`)
                .fontSize(12)
                .fontColor('#95A5A6')

              Text(this.selectedArticle.publishDate)
                .fontSize(12)
                .fontColor('#95A5A6')
            }
            .width('100%')
            .padding({ left: 20, right: 20, bottom: 16 })

            // 内容滚动区域
            Scroll() {
              Text(this.selectedArticle.content)
                .fontSize(14)
                .fontColor('#2C3E50')
                .lineHeight(22)
                .padding(20)
            }
            .layoutWeight(1)
            .scrollBar(BarState.Auto)

            // 底部操作
            Row({ space: 16 }) {
              Button('收藏')
                .backgroundColor('#F5F5F5')
                .fontColor('#2C3E50')
                .borderRadius(20)
                .layoutWeight(1)

              Button('分享')
                .backgroundColor('#FF6B35')
                .fontColor(Color.White)
                .borderRadius(20)
                .layoutWeight(1)
            }
            .width('100%')
            .padding(20)
            .visibility(Visibility.None)
          }
          .width('95%')
          .height('90%')
          .backgroundColor(Color.White)
          .borderRadius(16)
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1000)
    }
  }

  // 获取热门文章
  getHotArticles(): EtiquetteArticle[] {
    const allArticles: EtiquetteArticle[] = [];
    this.categories.forEach(category => {
      allArticles.push(...category.articles);
    });
    return allArticles.sort((a, b) => b.views - a.views).slice(0, 3);
  }

  // 获取难度颜色
  getDifficultyColor(difficulty: string): string {
    switch (difficulty) {
      case '入门':
        return '#4CAF50';
      case '进阶':
        return '#FF9800';
      case '专家':
        return '#F44336';
      default:
        return '#7F8C8D';
    }
  }

  // 获取难度背景色
  getDifficultyBgColor(difficulty: string): string {
    switch (difficulty) {
      case '入门':
        return '#E8F5E8';
      case '进阶':
        return '#FFF3E0';
      case '专家':
        return '#FFEBEE';
      default:
        return '#F5F5F5';
    }
  }
}