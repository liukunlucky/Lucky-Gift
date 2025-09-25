import { GiftStory } from '../model/NewDataModels';

/**
 * Mock故事数据类
 * 用于在故事页面没有真实数据时提供示例内容
 */
export class MockStoryData {
  
  /**
   * 获取mock故事数据
   * @returns 逼真煽情的mock故事
   */
  static getMockStory(): GiftStory {
    const mockStory: GiftStory = {
      id: '-1', // 使用负数ID标识mock数据
      giftEventId: '-1',
      giftEventTitle: '母亲节的温暖回忆',
      contactName: '妈妈',
      title: '那束永远不会凋谢的康乃馨',
      content: '那是一个阳光明媚的母亲节早晨，我怯生生地走到妈妈面前，手里紧紧握着用零花钱买的那束粉色康乃馨。当我把花递给她时，妈妈的眼中瞬间盈满了泪水，她轻抚着我的头说："这是我收到过最珍贵的礼物。"那一刻，我看到了世界上最美的笑容，温暖如春日阳光，深深印在我心里。多年过去了，每当想起那个瞬间，心中依然涌起无尽的温暖与感动。',
      images: ['mock_carnation.svg', 'mock_mom_smile.svg', 'mock_family_moment.svg'], // 引用本地图片
      emotion: '感动',
      reason: '表达对妈妈的爱',
      scene: '家中客厅',
      tags: ['母亲节', '康乃馨', '感恩', '温暖'],
      createdAt: '2024-05-12T08:30:00',
      updatedAt: '2024-05-12T08:30:00'
    };
    return mockStory;
  }

  /**
   * 获取mock故事的提示文本
   * @returns 提示用户这是示例数据的文本
   */
  static getMockStoryTip(): string {
    return '这是一个示例故事，帮助您了解如何记录珍贵的送礼故事。您可以在设置中关闭示例故事的显示。';
  }

  /**
   * 判断是否为mock故事
   * @param story 故事对象
   * @returns 是否为mock故事
   */
  static isMockStory(story: GiftStory): boolean {
    return story.id === '-1';
  }
}