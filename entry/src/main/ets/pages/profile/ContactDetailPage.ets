import router from '@ohos.router';
import { Contact, GiftEvent, ContactPreference } from '../../model/NewDataModels';
import { ContactDAO } from '../../database/ContactDAO';
import { GiftEventDAO } from '../../database/GiftEventDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';

// 路由参数接口
interface RouterParams {
  contactId: string;
}

@Entry
@Component
struct ContactDetailPage {
  @State contact: Contact | null = null;
  @State giftEvents: GiftEvent[] = [];
  @State isLoading: boolean = true;
  @State showEditDialog: boolean = false;
  @State editName: string = '';
  @State editBirthday: string = '';
  @State editRelationship: string = '';
  @State editPreferences: string = '';
  @State editDislikes: string = '';
  @State editNotes: string = '';
  
  private contactDAO: ContactDAO = new ContactDAO(new NewDatabaseManager());
  private giftEventDAO: GiftEventDAO = new GiftEventDAO(new NewDatabaseManager());
  private contactId: string = '';
  
  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params && params.contactId) {
      this.contactId = params.contactId;
      this.loadContactDetail();
    }
  }
  
  async loadContactDetail() {
    this.isLoading = true;
    
    try {
      // 加载联系人信息
      this.contact = await this.contactDAO.getContactById(this.contactId);
      
      if (this.contact) {
        // 加载该联系人的礼物事件
        this.giftEvents = await this.giftEventDAO.getGiftEventsByContactId(this.contactId);
        this.giftEvents.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
      }
    } catch (error) {
      console.error('加载联系人详情失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  showEditContactDialog() {
    if (this.contact) {
      this.editName = this.contact.name;
      this.editBirthday = this.contact.birthday || '';
      this.editRelationship = this.contact.relationship;
      this.editPreferences = this.contact.preferences?.filter(p => p.category === '喜好').map(p => p.content).join(', ') || '';
      this.editDislikes = this.contact.preferences?.filter(p => p.category === '厌恶').map(p => p.content).join(', ') || '';
      this.editNotes = this.contact.notes || '';
      this.showEditDialog = true;
    }
  }
  
  async saveContact() {
    if (!this.contact || !this.editName.trim()) {
      return;
    }
    
    try {
      const preferences: ContactPreference[] = [];
      
      // 添加喜好偏好
      const likes = this.editPreferences.split(',').map(p => {
        const preference: ContactPreference = {
          id: '',
          contactId: this.contact!.id,
          category: '喜好',
          content: p.trim(),
          priority: 'medium' as 'high' | 'medium' | 'low'
        };
        return preference;
      }).filter(p => p.content);
      preferences.push(...likes);
      
      // 添加厌恶偏好
      const dislikes = this.editDislikes.split(',').map(d => {
        const preference: ContactPreference = {
          id: '',
          contactId: this.contact!.id,
          category: '厌恶',
          content: d.trim(),
          priority: 'medium' as 'high' | 'medium' | 'low'
        };
        return preference;
      }).filter(d => d.content);
      preferences.push(...dislikes);
      
      const updatedContact: Contact = {
        id: this.contact.id,
        name: this.editName.trim(),
        relationship: this.editRelationship,
        avatar: this.contact.avatar,
        birthday: this.editBirthday || undefined,
        importantDates: this.contact.importantDates,
        preferences: preferences,
        notes: this.editNotes || undefined,
        createdAt: this.contact.createdAt,
        updatedAt: new Date().toISOString()
      };
      
      await this.contactDAO.updateContact(this.contact.id, updatedContact);
      this.contact = updatedContact;
      this.showEditDialog = false;
    } catch (error) {
      console.error('保存联系人失败:', error);
    }
  }
  
  async deleteContact() {
    if (!this.contact) return;
    
    try {
      await this.contactDAO.deleteContact(this.contact.id);
      router.back();
    } catch (error) {
      console.error('删除联系人失败:', error);
    }
  }
  
  navigateToCreateGiftEvent() {
    if (this.contact) {
      router.pushUrl({
        url: 'pages/tabs/CreateGiftEventPage',
        params: {
          recipientId: this.contact.id,
          recipientName: this.contact.name
        }
      });
    }
  }
  
  navigateToEventDetail(event: GiftEvent) {
    router.pushUrl({
      url: 'pages/tabs/CreateGiftEventPage',
      params: {
        eventId: event.id,
        mode: 'view'
      }
    });
  }
  
  formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    const now = new Date();
    const diffTime = now.getTime() - date.getTime();
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays === 0) {
      return '今天';
    } else if (diffDays === 1) {
      return '昨天';
    } else if (diffDays < 30) {
      return `${diffDays}天前`;
    } else if (diffDays < 365) {
      const diffMonths = Math.floor(diffDays / 30);
      return `${diffMonths}个月前`;
    } else {
      const diffYears = Math.floor(diffDays / 365);
      return `${diffYears}年前`;
    }
  }
  
  getRelationshipColor(relationship: string): string {
    const colorMap: Record<string, string> = {
      '家人': '#FF6B35',
      '恋人': '#E91E63',
      '朋友': '#4CAF50',
      '同事': '#2196F3',
      '同学': '#9C27B0',
      '其他': '#607D8B'
    };
    return colorMap[relationship] || '#607D8B';
  }
  
  getRelationshipIcon(relationship: string): string {
    const iconMap: Record<string, string> = {
      '家人': '👨‍👩‍👧‍👦',
      '恋人': '💕',
      '朋友': '👫',
      '同事': '💼',
      '同学': '🎓',
      '其他': '👤'
    };
    return iconMap[relationship] || '👤';
  }
  
  goBack() {
    router.back();
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Text('←')
            .fontSize(20)
            .fontColor('#333333')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.goBack())
        
        Text(this.contact?.name || '联系人详情')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button() {
          Text('✏️')
              .fontSize(16)
            .width(20)
            .height(20)
            .fontColor('#666666')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.showEditContactDialog())
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#FF6B35')
          
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (!this.contact) {
        Column() {
          Text('⚠️')
              .fontSize(16)
            .width(60)
            .height(60)
            .fontColor('#CCCCCC')
          
          Text('联系人不存在')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 联系人信息卡片
            Column() {
              // 头像和基本信息
              Column() {
                // 头像
                Stack() {
                  Circle({ width: 80, height: 80 })
                    .fill(this.getRelationshipColor(this.contact.relationship))
                  
                  Text(this.contact.name.charAt(0))
                    .fontSize(32)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                }
                .margin({ bottom: 16 })
                
                // 姓名
                Text(this.contact.name)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .margin({ bottom: 8 })
                
                // 关系标签
                Row() {
                  Text(this.getRelationshipIcon(this.contact.relationship))
                    .fontSize(16)
                    .margin({ right: 6 })
                  
                  Text(this.contact.relationship)
                    .fontSize(14)
                    .fontColor('#FFFFFF')
                }
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.getRelationshipColor(this.contact.relationship))
                .borderRadius(12)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
              .padding({ top: 24, bottom: 24 })
              
              // 详细信息
              Column() {
                if (this.contact.birthday) {
                  Row() {
                    Text('🎂')
                      .fontSize(16)
                      .margin({ right: 12 })
                    
                    Text('生日')
                      .fontSize(14)
                      .fontColor('#666666')
                      .layoutWeight(1)
                    
                    Text(this.contact.birthday)
                      .fontSize(14)
                      .fontColor('#333333')
                  }
                  .width('100%')
                  .padding({ top: 12, bottom: 12 })
                  .alignItems(VerticalAlign.Center)
                }
                
                if (this.contact.preferences?.filter(p => p.category === '喜好').length > 0) {
                  Column() {
                    Row() {
                      Text('❤️')
                        .fontSize(16)
                        .margin({ right: 12 })
                      
                      Text('喜好')
                        .fontSize(14)
                        .fontColor('#666666')
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Center)
                    .margin({ bottom: 8 })
                    
                    Flex({ wrap: FlexWrap.Wrap }) {
                      ForEach(this.contact.preferences?.filter(p => p.category === '喜好') || [], (preference: ContactPreference) => {
                        Text(preference.content)
                          .fontSize(12)
                          .fontColor('#4CAF50')
                          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                          .backgroundColor('#E8F5E8')
                          .borderRadius(8)
                          .margin({ right: 6, bottom: 6 })
                      })
                    }
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                  .padding({ top: 12, bottom: 12 })
                }
                
                if (this.contact.preferences?.filter(p => p.category === '厌恶').length > 0) {
                  Column() {
                    Row() {
                      Text('💔')
                        .fontSize(16)
                        .margin({ right: 12 })
                      
                      Text('不喜欢')
                        .fontSize(14)
                        .fontColor('#666666')
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Center)
                    .margin({ bottom: 8 })
                    
                    Flex({ wrap: FlexWrap.Wrap }) {
                      ForEach(this.contact.preferences?.filter(p => p.category === '厌恶') || [], (dislike: ContactPreference) => {
                        Text(dislike.content)
                          .fontSize(12)
                          .fontColor('#F44336')
                          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                          .backgroundColor('#FFEBEE')
                          .borderRadius(8)
                          .margin({ right: 6, bottom: 6 })
                      })
                    }
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                  .padding({ top: 12, bottom: 12 })
                }
                
                if (this.contact.notes) {
                  Row() {
                    Text('📝')
                      .fontSize(16)
                      .margin({ right: 12 })
                    
                    Column() {
                      Text('备注')
                        .fontSize(14)
                        .fontColor('#666666')
                        .alignSelf(ItemAlign.Start)
                        .margin({ bottom: 4 })
                      
                      Text(this.contact.notes)
                        .fontSize(14)
                        .fontColor('#333333')
                        .alignSelf(ItemAlign.Start)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  .padding({ top: 12, bottom: 12 })
                  .alignItems(VerticalAlign.Top)
                }
              }
              .width('100%')
              .padding(16)
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ bottom: 16 })
            
            // 专属时间轴
            Column() {
              Row() {
                Text('专属时间轴')
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                
                Blank()
                
                Button() {
                  Row() {
                    Image($r('app.media.ic_add'))
                      .width(16)
                      .height(16)
                      .fillColor('#FF6B35')
                      .margin({ right: 4 })
                    
                    Text('添加记录')
                      .fontSize(14)
                      .fontColor('#FF6B35')
                  }
                }
                .backgroundColor(Color.Transparent)
                .onClick(() => this.navigateToCreateGiftEvent())
              }
              .width('100%')
              .margin({ bottom: 16 })
              
              if (this.giftEvents.length === 0) {
                Column() {
                  Image($r('app.media.ic_empty'))
                    .width(60)
                    .height(60)
                    .fillColor('#CCCCCC')
                  
                  Text('还没有送礼记录')
                    .fontSize(16)
                    .fontColor('#999999')
                    .margin({ top: 16 })
                  
                  Text('点击上方按钮添加第一条记录')
                    .fontSize(14)
                    .fontColor('#CCCCCC')
                    .margin({ top: 8 })
                }
                .width('100%')
                .height(120)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              } else {
                Column() {
                  ForEach(this.giftEvents, (event: GiftEvent) => {
                    Row() {
                      // 时间线
                      Column() {
                        Circle({ width: 12, height: 12 })
                          .fill('#FF6B35')
                        
                        if (this.giftEvents.indexOf(event) < this.giftEvents.length - 1) {
                          Line()
                            .width(2)
                            .height(60)
                            .stroke('#E0E0E0')
                            .margin({ top: 8 })
                        }
                      }
                      .width(20)
                      .alignItems(HorizontalAlign.Center)
                      .margin({ right: 16 })
                      
                      // 事件内容
                      Column() {
                        Row() {
                          Text(event.giftIdea)
                            .fontSize(16)
                            .fontWeight(FontWeight.Medium)
                            .fontColor('#333333')
                            .layoutWeight(1)
                          
                          Text(`¥${event.budget}`)
                            .fontSize(14)
                            .fontColor('#FF6B35')
                            .fontWeight(FontWeight.Medium)
                        }
                        .width('100%')
                        .alignItems(VerticalAlign.Center)
                        .margin({ bottom: 4 })
                        
                        Row() {
                          Text(event.occasion)
                            .fontSize(12)
                            .fontColor('#666666')
                            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                            .backgroundColor('#F0F0F0')
                            .borderRadius(6)
                          
                          Blank()
                          
                          Text(this.formatDate(event.date))
                            .fontSize(12)
                            .fontColor('#999999')
                        }
                        .width('100%')
                        .alignItems(VerticalAlign.Center)
                        
                        if (event.story) {
                          Text(event.story)
                            .fontSize(14)
                            .fontColor('#666666')
                            .maxLines(2)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .margin({ top: 8 })
                        }
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                      .padding({ bottom: 16 })
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Top)
                    .onClick(() => this.navigateToEventDetail(event))
                  })
                }
              }
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .padding(16)
          }
          .padding(16)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      
      // 编辑对话框
      if (this.showEditDialog) {
        Stack() {
          // 背景遮罩
          Rect()
            .width('100%')
            .height('100%')
            .fill('#80000000')
            .onClick(() => {
              this.showEditDialog = false;
            })
          
          // 对话框内容
          Scroll() {
            Column() {
              Text('编辑联系人')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 20 })
              
              // 姓名
              Column() {
                Text('姓名 *')
                  .fontSize(14)
                  .fontColor('#666666')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 8 })
                
                TextInput({ placeholder: '输入姓名', text: this.editName })
                  .fontSize(16)
                  .backgroundColor('#F8F9FA')
                  .borderRadius(8)
                  .padding({ left: 16, right: 16 })
                  .onChange((value: string) => {
                    this.editName = value;
                  })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .margin({ bottom: 16 })
              
              // 关系
              Column() {
                Text('关系')
                  .fontSize(14)
                  .fontColor('#666666')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 8 })
                
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(['家人', '恋人', '朋友', '同事', '同学', '其他'], (relationship: string) => {
                    Button() {
                      Text(relationship)
                        .fontSize(14)
                        .fontColor(this.editRelationship === relationship ? '#FFFFFF' : '#666666')
                    }
                    .backgroundColor(this.editRelationship === relationship ? '#FF6B35' : '#F5F5F5')
                    .borderRadius(16)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .margin({ right: 8, bottom: 8 })
                    .onClick(() => {
                      this.editRelationship = relationship;
                    })
                  })
                }
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .margin({ bottom: 16 })
              
              // 生日
              Column() {
                Text('生日')
                  .fontSize(14)
                  .fontColor('#666666')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 8 })
                
                TextInput({ placeholder: 'YYYY-MM-DD', text: this.editBirthday })
                  .fontSize(16)
                  .backgroundColor('#F8F9FA')
                  .borderRadius(8)
                  .padding({ left: 16, right: 16 })
                  .onChange((value: string) => {
                    this.editBirthday = value;
                  })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .margin({ bottom: 16 })
              
              // 喜好
              Column() {
                Text('喜好（用逗号分隔）')
                  .fontSize(14)
                  .fontColor('#666666')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 8 })
                
                TextInput({ placeholder: '例如：读书, 旅行, 美食', text: this.editPreferences })
                  .fontSize(16)
                  .backgroundColor('#F8F9FA')
                  .borderRadius(8)
                  .padding({ left: 16, right: 16 })
                  .onChange((value: string) => {
                    this.editPreferences = value;
                  })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .margin({ bottom: 16 })
              
              // 不喜欢
              Column() {
                Text('不喜欢（用逗号分隔）')
                  .fontSize(14)
                  .fontColor('#666666')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 8 })
                
                TextInput({ placeholder: '例如：辛辣, 噪音', text: this.editDislikes })
                  .fontSize(16)
                  .backgroundColor('#F8F9FA')
                  .borderRadius(8)
                  .padding({ left: 16, right: 16 })
                  .onChange((value: string) => {
                    this.editDislikes = value;
                  })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .margin({ bottom: 16 })
              
              // 备注
              Column() {
                Text('备注')
                  .fontSize(14)
                  .fontColor('#666666')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 8 })
                
                TextArea({ placeholder: '其他备注信息', text: this.editNotes })
                  .fontSize(16)
                  .backgroundColor('#F8F9FA')
                  .borderRadius(8)
                  .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                  .height(80)
                  .onChange((value: string) => {
                    this.editNotes = value;
                  })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .margin({ bottom: 24 })
              
              // 按钮
              Row() {
                Button('删除')
                  .fontSize(16)
                  .fontColor('#F44336')
                  .backgroundColor('#FFEBEE')
                  .borderRadius(8)
                  .layoutWeight(1)
                  .margin({ right: 8 })
                  .onClick(() => this.deleteContact())
                
                Button('取消')
                  .fontSize(16)
                  .fontColor('#666666')
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                  .layoutWeight(1)
                  .margin({ left: 4, right: 4 })
                  .onClick(() => {
                    this.showEditDialog = false;
                  })
                
                Button('保存')
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#FF6B35')
                  .borderRadius(8)
                  .layoutWeight(1)
                  .margin({ left: 8 })
                  .onClick(() => this.saveContact())
              }
              .width('100%')
            }
            .width('100%')
            .padding(24)
          }
          .width('90%')
          .height('80%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}