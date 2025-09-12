import router from '@ohos.router';
import { Contact, GiftEvent } from '../../model/NewDataModels';
import { ContactDAO } from '../../database/ContactDAO';
import { GiftEventDAO } from '../../database/GiftEventDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';

interface RelationshipData {
  contact: Contact;
  giftCount: number;
  totalSpent: number;
  lastGiftDate?: string;
  intimacyLevel: string;
}

interface RelationshipItem {
  contact: Contact;
  giftCount: number;
  totalSpent: number;
  lastGiftDate?: string;
  intimacyLevel: string;
}

@Entry
@Component
struct RelationshipNetworkPage {
  @State contacts: Contact[] = [];
  @State giftEvents: GiftEvent[] = [];
  @State relationshipData: RelationshipData[] = [];
  @State isLoading: boolean = true;
  @State selectedFilter: string = 'all'; // all, family, friend, colleague, other
  
  private dbManager = new NewDatabaseManager();
  private contactDAO = new ContactDAO(this.dbManager);
  private giftEventDAO = new GiftEventDAO(this.dbManager);
  
  aboutToAppear() {
    this.loadData();
  }
  
  async loadData() {
    try {
      this.isLoading = true;
      
      // 加载联系人和礼物事件数据
      this.contacts = await this.contactDAO.getAllContacts();
      this.giftEvents = await this.giftEventDAO.getAllGiftEvents();
      
      // 计算关系数据
      this.calculateRelationshipData();
      
    } catch (error) {
      console.error('加载关系网络数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  calculateRelationshipData() {
    this.relationshipData = this.contacts.map(contact => {
      const contactGifts = this.giftEvents.filter(event => event.contactId === contact.id);
      const giftCount = contactGifts.length;
      const totalSpent = contactGifts.reduce((sum, event) => sum + (event.actualCost || event.budget || 0), 0);
      const lastGift = contactGifts.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())[0];
      
      // 计算亲密度等级
      let intimacyLevel = '陌生';
      if (giftCount >= 10) {
        intimacyLevel = '挚友';
      } else if (giftCount >= 5) {
        intimacyLevel = '好友';
      } else if (giftCount >= 2) {
        intimacyLevel = '熟悉';
      } else if (giftCount >= 1) {
        intimacyLevel = '一般';
      }
      
      const relationshipItem: RelationshipItem = {
        contact,
        giftCount,
        totalSpent,
        lastGiftDate: lastGift?.date,
        intimacyLevel
      };
      return relationshipItem;
    }).sort((a, b) => b.giftCount - a.giftCount); // 按送礼次数排序
  }
  
  getFilteredData(): RelationshipData[] {
    if (this.selectedFilter === 'all') {
      return this.relationshipData;
    }
    return this.relationshipData.filter(data => data.contact.relationship === this.selectedFilter);
  }
  
  getIntimacyColor(level: string): string {
    switch (level) {
      case '挚友': return '#FF6B35';
      case '好友': return '#FFA500';
      case '熟悉': return '#32CD32';
      case '一般': return '#87CEEB';
      default: return '#D3D3D3';
    }
  }
  
  formatAmount(amount: number): string {
    if (amount >= 10000) {
      return (amount / 10000).toFixed(1) + '万';
    } else if (amount >= 1000) {
      return (amount / 1000).toFixed(1) + 'k';
    }
    return amount.toString();
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_arrow_right'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })
        
        Text('关系网络')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 占位符保持居中
        Row().width(24).height(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
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
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Column() {
          // 统计概览
          Row() {
            Column() {
              Text(this.contacts.length.toString())
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF6B35')
              
              Text('总联系人')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            
            Column() {
              Text(this.relationshipData.filter(d => d.giftCount > 0).length.toString())
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#32CD32')
              
              Text('有互动')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            
            Column() {
              Text(this.relationshipData.filter(d => d.intimacyLevel === '挚友').length.toString())
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFA500')
              
              Text('挚友')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ top: 8, left: 16, right: 16 })
          
          // 筛选器
          Row() {
            ForEach(['all', 'family', 'friend', 'colleague', 'other'], (filter: string) => {
              Text(this.getFilterName(filter))
                .fontSize(14)
                .fontColor(this.selectedFilter === filter ? Color.White : '#666666')
                .backgroundColor(this.selectedFilter === filter ? '#FF6B35' : '#F0F0F0')
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .borderRadius(16)
                .margin({ right: 8 })
                .onClick(() => {
                  this.selectedFilter = filter;
                })
            }, (filter: string) => filter)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })
          
          // 关系列表
          Scroll() {
            Column() {
              ForEach(this.getFilteredData(), (data: RelationshipData) => {
                Row() {
                  // 头像
                  Stack() {
                    if (data.contact.avatar) {
                      Text(data.contact.avatar)
                        .fontSize(20)
                        .width(50)
                        .height(50)
                        .borderRadius(25)
                        .backgroundColor('#F0F0F0')
                        .textAlign(TextAlign.Center)
                    } else {
                      Image($r('app.media.icon_mine'))
                        .width(40)
                        .height(40)
                        .fillColor('#CCCCCC')
                        .borderRadius(25)
                        .backgroundColor('#F0F0F0')
                    }
                    
                    // 亲密度指示器
                    Circle({ width: 12, height: 12 })
                      .fill(this.getIntimacyColor(data.intimacyLevel))
                      .position({ x: 38, y: 38 })
                  }
                  .margin({ right: 12 })
                  
                  // 联系人信息
                  Column() {
                    Row() {
                      Text(data.contact.name)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                        .layoutWeight(1)
                      
                      Text(data.intimacyLevel)
                        .fontSize(12)
                        .fontColor(this.getIntimacyColor(data.intimacyLevel))
                        .backgroundColor(this.getIntimacyColor(data.intimacyLevel) + '20')
                        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                        .borderRadius(10)
                    }
                    .width('100%')
                    
                    Row() {
                      Text(`送礼 ${data.giftCount} 次`)
                        .fontSize(12)
                        .fontColor('#666666')
                      
                      if (data.totalSpent > 0) {
                        Text(`·`)
                          .fontSize(12)
                          .fontColor('#666666')
                          .margin({ left: 4, right: 4 })
                        
                        Text(`¥${this.formatAmount(data.totalSpent)}`)
                          .fontSize(12)
                          .fontColor('#666666')
                      }
                      
                      if (data.lastGiftDate) {
                        Text(`·`)
                          .fontSize(12)
                          .fontColor('#666666')
                          .margin({ left: 4, right: 4 })
                        
                        Text(`最近 ${data.lastGiftDate}`)
                          .fontSize(12)
                          .fontColor('#666666')
                      }
                    }
                    .width('100%')
                    .margin({ top: 4 })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  
                  Image($r('app.media.ic_arrow_right'))
                    .width(16)
                    .height(16)
                    .fillColor('#CCCCCC')
                }
                .width('100%')
                .padding(16)
                .backgroundColor(Color.White)
                .borderRadius(12)
                .margin({ bottom: 8, left: 16, right: 16 })
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/profile/ContactDetailPage',
                    params: { contactId: data.contact.id }
                  });
                })
              })
              
              if (this.getFilteredData().length === 0) {
                Column() {
                  Image($r('app.media.ic_empty'))
                    .width(80)
                    .height(80)
                    .fillColor('#CCCCCC')
                  
                  Text('暂无数据')
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ top: 16 })
                }
                .width('100%')
                .height(200)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
            }
            .width('100%')
            .padding({ bottom: 20 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
  
  getFilterName(filter: string): string {
    switch (filter) {
      case 'all': return '全部';
      case 'family': return '家人';
      case 'friend': return '朋友';
      case 'colleague': return '同事';
      case 'other': return '其他';
      default: return '全部';
    }
  }
}