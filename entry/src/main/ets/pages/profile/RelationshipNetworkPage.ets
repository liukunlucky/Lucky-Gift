import router from '@ohos.router';
import { Contact, GiftEvent } from '../../model/NewDataModels';
import { ContactDAO } from '../../database/ContactDAO';
import { GiftEventDAO } from '../../database/GiftEventDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';
import { common } from '@kit.AbilityKit';
import { RelationshipType, getRelationshipTypeName, getRelationshipTypeColor, getRelationshipTypeTextColor } from '../../model/RelationshipType';


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
  @State showAddContactDialog: boolean = false;
  @State showDeleteConfirmDialog: boolean = false;
  @State contactToDelete: Contact | null = null;
  private dialogController?: CustomDialogController; // 密码对话框控制器

  private dbManager = new NewDatabaseManager();
  private contactDAO = new ContactDAO(this.dbManager);
  private giftEventDAO = new GiftEventDAO(this.dbManager);
  
  async aboutToAppear() {
    // 初始化数据库
    const context = getContext(this) as common.UIAbilityContext;
    await this.dbManager.initDatabase(context);
    
    this.loadData();
  }

  onPageShow() {
    // 页面显示时重新加载数据，确保从ContactFormPage返回时数据是最新的
    this.loadData();
  }
  
  async loadData() {
    try {
      this.isLoading = true;
      
      // 确保数据库已初始化
      if (!this.dbManager.isInitialized()) {
        const context = getContext(this) as common.UIAbilityContext;
        await this.dbManager.initDatabase(context);
      }
      
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
    }).sort((a, b) => {
      // 首先按创建时间排序（新添加的在前）
      const timeA = new Date(a.contact.createdAt).getTime();
      const timeB = new Date(b.contact.createdAt).getTime();
      if (timeB !== timeA) {
        return timeB - timeA; // 新的在前
      }
      // 如果创建时间相同，再按送礼次数排序
      return b.giftCount - a.giftCount;
    });
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

  goBack() {
    router.back();
  }
  
  // 添加联系人
  addContact() {
    router.pushUrl({
      url: 'pages/profile/ContactFormPage',
      params: {
        isEdit: false
      }
    });
  }
  
  // 编辑联系人
  editContact(contact: Contact) {
    router.pushUrl({
      url: 'pages/profile/ContactFormPage',
      params: {
        contact: contact,
        isEdit: true
      }
    });
  }
  
  // 删除联系人确认
  confirmDeleteContact(contact: Contact) {
    this.contactToDelete = contact;
    this.showDeleteConfirmDialog = true;
  }
  
  // 执行删除联系人
  async deleteContact() {
    if (!this.contactToDelete) return;
    
    try {
      await this.contactDAO.deleteContact(this.contactToDelete.id);
      await this.loadData(); // 重新加载数据
      this.showDeleteConfirmDialog = false;
      this.contactToDelete = null;
    } catch (error) {
      console.error('删除联系人失败:', error);
    }
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Image($r('app.media.icon_back'))
            .width(24)
            .height(24)
            .fillColor('#333333')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.goBack()
        })
        
        Text('关系网络')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
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

                  // 联系人信息
                  Column() {
                    Row() {
                      Text(data.contact.name)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                        .margin({right: 10})
                      
                      Text(getRelationshipTypeName(data.contact.relationship as RelationshipType))
                        .fontSize(12)
                        .fontColor(getRelationshipTypeTextColor(data.contact.relationship as RelationshipType))
                        .backgroundColor(getRelationshipTypeColor(data.contact.relationship as RelationshipType))
                        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                        .borderRadius(10)
                    }
                    .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  
                  Image($r('app.media.ic_arrow_right'))
                    .width(16)
                    .height(16)
                    .fillColor('#CCCCCC')
                }
                .padding(16)
                .backgroundColor(Color.White)
                .borderRadius(12)
                .margin({ bottom: 8, left: 16, right: 16 })
                .onClick(() => {
                  // 直接进入编辑页面
                  this.editContact(data.contact);
                })
              })
              
              if (this.getFilteredData().length === 0) {
                Column() {
                  Image($r('app.media.icon_empty'))
                    .width(173)
                    .height(128)

                  Text('暂无关系数据')
                    .fontSize(16)
                    .fontColor('#666666')
                    .margin({ top: 24 })
                  
                  Text('添加联系人开始建立关系网络')
                    .fontSize(14)
                    .fontColor('#999999')
                    .margin({ top: 8 })

                  Button('去添加关系')
                    .width('calc(100% - 32vp)')
                    .height(44)
                    .fontSize(16)
                    .backgroundColor($r('app.color.brand_color'))
                    .fontColor('#FFFFFF')
                    .borderRadius(22)
                    .margin({ top: 20, left: 16, right: 16 })
                    .onClick(() => {
                      this.addContact();
                    })
                }
                .width('100%')
                .justifyContent(FlexAlign.Start)
                .padding({top: 50})
                .alignItems(HorizontalAlign.Center)
                .layoutWeight(1)
              } else {
                // 有数据时在底部显示添加按钮
                Button('去添加关系')
                  .width('calc(100% - 32vp)')
                  .height(44)
                  .fontSize(16)
                  .backgroundColor($r('app.color.brand_color'))
                  .fontColor('#FFFFFF')
                  .borderRadius(22)
                  .margin({ top: 20, left: 16, right: 16 })
                  .onClick(() => {
                    this.addContact();
                  })
              }
            }
            .width('100%')
            .padding({ top: 24, bottom: 20 })
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
    .bindSheet($$this.showDeleteConfirmDialog, this.buildDeleteConfirmDialog(), {
      height: 200,
      dragBar: false,
      backgroundColor: Color.White
    })
  }
  

  
  // 构建删除确认对话框
  @Builder
  buildDeleteConfirmDialog() {
    Column() {
      Text('确认删除')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 20, bottom: 16 })
      
      Text(`确定要删除联系人 "${this.contactToDelete?.name}" 吗？\n删除后相关的礼物记录将保留，但联系人信息将无法恢复。`)
        .fontSize(14)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 24 })
        .padding({ left: 20, right: 20 })
      
      Row() {
        Button('取消')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .onClick(() => {
            this.showDeleteConfirmDialog = false;
            this.contactToDelete = null;
          })
        
        Button('删除')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#FF4444')
          .fontColor(Color.White)
          .margin({ left: 12 })
          .onClick(() => {
            this.deleteContact();
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
    }
    .width('100%')
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