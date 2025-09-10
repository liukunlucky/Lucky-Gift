import { DatabaseManager } from '../database/DatabaseManager';
import { GiftDAO } from '../database/GiftDAO';
import { Gift, GiftCategory, PurchaseLink, PriceRange, CONSTANTS } from '../model/DataModels';

// 进度接口
interface InitProgress {
  current: number;
  total: number;
}

// 数据初始化服务
export class DataInitService {
  private dbManager: DatabaseManager;
  private giftDAO: GiftDAO;

  constructor() {
    this.dbManager = DatabaseManager.getInstance();
    this.giftDAO = new GiftDAO();
  }

  // 初始化所有数据
  public async initializeData(): Promise<void> {
    try {
      console.info('开始初始化数据...');
      
      // 检查是否已经初始化过
      const existingGifts = await this.giftDAO.searchGifts('', undefined, 1);
      if (existingGifts.length > 0) {
        console.info('数据已存在，跳过初始化');
        return;
      }
      
      // 初始化礼物数据
      await this.initializeGifts();
      
      console.info('数据初始化完成');
    } catch (error) {
      console.error('数据初始化失败:', error);
      throw new Error(`数据初始化失败: ${error}`);
    }
  }

  // 初始化礼物数据
  private async initializeGifts(): Promise<void> {
    const gifts: Gift[] = [
      // 首饰类
      {
        id: this.dbManager.generateId(),
        name: '施华洛世奇天鹅项链',
        description: '经典天鹅造型，水晶闪耀，象征优雅与纯洁',
        category: '首饰',
        subcategory: '项链',
        price: 899,
        priceRange: { min: 500, max: 1000 } as PriceRange,
        imageUrl: 'https://example.com/necklace1.jpg',
        images: ['https://example.com/necklace1_1.jpg', 'https://example.com/necklace1_2.jpg'],
        brand: '施华洛世奇',
        rating: 4.8,
        reviewCount: 1256,
        tags: ['浪漫', '优雅', '经典'],
        scenarios: ['情人节', '生日', '纪念日'],
        targetGender: 'female',
        targetAge: '18-35',
        relationship: ['恋人', '配偶'],
        meaning: '天鹅象征忠贞不渝的爱情，寓意永恒的美好',
        availability: true,
        purchaseLinks: [
          { platform: '施华洛世奇官网', url: 'https://swarovski.cn', price: 899, inStock: true } as PurchaseLink,
          { platform: '天猫旗舰店', url: 'https://tmall.com', price: 899, inStock: true } as PurchaseLink
        ],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      } as Gift,

      {
        id: this.dbManager.generateId(),
        name: 'Tiffany & Co. 经典六爪钻戒',
        description: '经典六爪镶嵌设计，璀璨钻石，永恒承诺',
        category: '首饰',
        subcategory: '戒指',
        price: 15800,
        priceRange: { min: 10000, max: 20000 } as PriceRange,
        imageUrl: 'https://example.com/ring1.jpg',
        brand: 'Tiffany & Co.',
        rating: 4.9,
        reviewCount: 856,
        tags: ['奢华', '永恒', '承诺'],
        scenarios: ['求婚', '结婚', '纪念日'],
        targetGender: 'female',
        targetAge: '22-40',
        relationship: ['恋人', '配偶'],
        meaning: '钻石恒久远，一颗永流传，象征永恒的爱情',
        availability: true,
        purchaseLinks: [
          { platform: 'Tiffany官网', url: 'https://tiffany.cn', price: 15800, inStock: true } as PurchaseLink
        ],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      } as Gift,

      {
        id: this.dbManager.generateId(),
        name: 'Cartier卡地亚手表',
        description: '瑞士制造，精工细作，彰显品味与地位',
        category: '首饰',
        subcategory: '手表',
        price: 28000,
        priceRange: { min: 20000, max: 50000 } as PriceRange,
        imageUrl: 'https://example.com/watch1.jpg',
        brand: 'Cartier',
        rating: 4.9,
        reviewCount: 432,
        tags: ['奢华', '精工', '品味'],
        scenarios: ['生日', '升职', '成功庆祝'],
        targetGender: 'male',
        targetAge: '25-50',
        relationship: ['配偶', '父亲', '老板'],
        meaning: '时间见证成功，象征对时间的珍视和对成功的追求',
        availability: true,
        purchaseLinks: [
          { platform: 'Cartier官网', url: 'https://cartier.cn', price: 28000, inStock: true } as PurchaseLink
        ],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      } as Gift,

      // 电子产品类
      {
        id: this.dbManager.generateId(),
        name: 'Apple iPhone 15 Pro',
        description: '最新旗舰手机，钛金属机身，专业摄影系统',
        category: '电子产品',
        subcategory: '手机',
        price: 8999,
        priceRange: { min: 5000, max: 10000 } as PriceRange,
        imageUrl: 'https://example.com/iphone15.jpg',
        brand: 'Apple',
        rating: 4.7,
        reviewCount: 3245,
        tags: ['科技', '实用', '时尚'],
        scenarios: ['生日', '毕业', '升职'],
        targetGender: 'unisex',
        targetAge: '18-45',
        relationship: ['朋友', '家人', '恋人'],
        meaning: '科技改变生活，寓意对美好未来的期待',
        availability: true,
        purchaseLinks: [
          { platform: 'Apple官网', url: 'https://apple.com.cn', price: 8999, inStock: true } as PurchaseLink,
          { platform: '京东自营', url: 'https://jd.com', price: 8999, inStock: true } as PurchaseLink
        ],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      } as Gift,

      {
        id: this.dbManager.generateId(),
        name: 'Sony WH-1000XM5 降噪耳机',
        description: '业界领先的降噪技术，Hi-Res音质，舒适佩戴',
        category: '电子产品',
        subcategory: '耳机',
        price: 2399,
        priceRange: { min: 2000, max: 3000 } as PriceRange,
        imageUrl: 'https://example.com/sony_headphones.jpg',
        brand: 'Sony',
        rating: 4.8,
        reviewCount: 1876,
        tags: ['音质', '降噪', '舒适'],
        scenarios: ['生日', '感谢', '毕业'],
        targetGender: 'unisex',
        targetAge: '16-40',
        relationship: ['朋友', '同事', '学生'],
        meaning: '享受纯净音乐世界，寓意对美好生活的追求',
        availability: true,
        purchaseLinks: [
          { platform: 'Sony官网', url: 'https://sony.com.cn', price: 2399, inStock: true } as PurchaseLink,
          { platform: '天猫旗舰店', url: 'https://tmall.com', price: 2399, inStock: true } as PurchaseLink
        ],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      } as Gift,

      // 书籍类
      {
        id: this.dbManager.generateId(),
        name: '《百年孤独》精装版',
        description: '马尔克斯经典之作，魔幻现实主义文学巨著',
        category: '书籍',
        subcategory: '文学',
        price: 68,
        priceRange: { min: 50, max: 100 } as PriceRange,
        imageUrl: 'https://example.com/book1.jpg',
        brand: '人民文学出版社',
        rating: 4.9,
        reviewCount: 5432,
        tags: ['经典', '文学', '思考'],
        scenarios: ['毕业', '生日', '感谢'],
        targetGender: 'unisex',
        targetAge: '18-60',
        relationship: ['朋友', '老师', '学生'],
        meaning: '书籍是人类进步的阶梯，寓意知识的传承与智慧的启迪',
        availability: true,
        purchaseLinks: [
          { platform: '当当网', url: 'https://dangdang.com', price: 68, inStock: true } as PurchaseLink,
          { platform: '京东图书', url: 'https://jd.com', price: 68, inStock: true } as PurchaseLink
        ],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      } as Gift,

      // 鲜花类
      {
        id: this.dbManager.generateId(),
        name: '99朵红玫瑰花束',
        description: '新鲜红玫瑰，精美包装，表达深深爱意',
        category: '鲜花',
        subcategory: '玫瑰',
        price: 299,
        priceRange: { min: 200, max: 500 } as PriceRange,
        imageUrl: 'https://example.com/roses.jpg',
        rating: 4.6,
        reviewCount: 2134,
        tags: ['浪漫', '爱情', '表白'],
        scenarios: ['情人节', '表白', '道歉', '纪念日'],
        targetGender: 'female',
        targetAge: '16-50',
        relationship: ['恋人', '配偶'],
        meaning: '玫瑰代表爱情，99朵寓意天长地久的爱',
        availability: true,
        purchaseLinks: [
          { platform: '花点时间', url: 'https://hua.com', price: 299, inStock: true } as PurchaseLink,
          { platform: '野兽派花店', url: 'https://thebeast.cn', price: 299, inStock: true } as PurchaseLink
        ],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      } as Gift,

      // 化妆品类
      {
        id: this.dbManager.generateId(),
        name: 'Dior迪奥口红套装',
        description: '经典色号组合，滋润持久，彰显女性魅力',
        category: '化妆品',
        subcategory: '口红',
        price: 680,
        priceRange: { min: 500, max: 1000 } as PriceRange,
        imageUrl: 'https://example.com/dior_lipstick.jpg',
        brand: 'Dior',
        rating: 4.8,
        reviewCount: 1567,
        tags: ['美妆', '奢华', '魅力'],
        scenarios: ['生日', '情人节', '感谢'],
        targetGender: 'female',
        targetAge: '18-45',
        relationship: ['恋人', '朋友', '同事'],
        meaning: '美丽是女性的天赋，寓意对美好形象的追求',
        availability: true,
        purchaseLinks: [
          { platform: 'Dior官网', url: 'https://dior.cn', price: 680, inStock: true } as PurchaseLink,
          { platform: '丝芙兰', url: 'https://sephora.cn', price: 680, inStock: true } as PurchaseLink
        ],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      } as Gift,

      // 食品类
      {
        id: this.dbManager.generateId(),
        name: 'Godiva歌帝梵巧克力礼盒',
        description: '比利时进口巧克力，甜蜜浓郁',
        category: '美食',
        subcategory: '巧克力',
        price: 288,
        priceRange: { min: 200, max: 500 },
        imageUrl: 'https://example.com/godiva.jpg',
        brand: 'Godiva',
        rating: 4.8,
        reviewCount: 2156,
        tags: ['甜蜜', '浪漫', '奢华'],
        scenarios: ['情人节', '道歉', '感谢'],
        targetGender: 'unisex',
        targetAge: '18-55',
        relationship: ['恋人', '朋友', '家人'],
        meaning: '甜蜜如巧克力，寓意甜蜜的爱情与友谊',
        availability: true,
        purchaseLinks: [
          { platform: 'Godiva官网', url: 'https://godiva.cn', price: 288, inStock: true } as PurchaseLink,
          { platform: '京东自营', url: 'https://jd.com', price: 288, inStock: true } as PurchaseLink
        ],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      } as Gift,

      // 服装类
      {
        id: this.dbManager.generateId(),
        name: 'Uniqlo优衣库羊绒围巾',
        description: '100%羊绒材质，柔软保暖，多色可选',
        category: '服装',
        subcategory: '围巾',
        price: 199,
        priceRange: { min: 100, max: 300 } as PriceRange,
        imageUrl: 'https://example.com/scarf.jpg',
        brand: 'Uniqlo',
        rating: 4.7,
        reviewCount: 3421,
        tags: ['保暖', '舒适', '实用'],
        scenarios: ['冬季', '关怀', '生日'],
        targetGender: 'unisex',
        targetAge: '16-60',
        relationship: ['家人', '朋友', '恋人'],
        meaning: '温暖如围巾，寓意关怀与温暖的情感',
        availability: true,
        purchaseLinks: [
          { platform: 'Uniqlo官网', url: 'https://uniqlo.cn', price: 199, inStock: true } as PurchaseLink,
          { platform: '天猫旗舰店', url: 'https://tmall.com', price: 199, inStock: true } as PurchaseLink
        ],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      } as Gift
    ];

    // 批量插入礼物数据
    for (const gift of gifts) {
      try {
        await this.giftDAO.insertGift(gift);
        console.info(`插入礼物: ${gift.name}`);
      } catch (error) {
        console.error(`插入礼物失败: ${gift.name}`, error);
      }
    }
  }

  // 获取初始化进度
  public getInitProgress(): InitProgress {
    // 这里可以实现实际的进度跟踪逻辑
    return {
      current: 100,
      total: 100
    };
  }

  // 清空所有数据
  public async clearAllData(): Promise<void> {
    try {
      // 这里可以添加清空数据的逻辑
      console.info('清空所有数据完成');
    } catch (error) {
      console.error('清空数据失败:', error);
      throw new Error(`清空数据失败: ${error}`);
    }
  }
}