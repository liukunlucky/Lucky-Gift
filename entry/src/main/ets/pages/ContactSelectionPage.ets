import router from '@ohos.router';
import { Contact } from '../model/NewDataModels';
import { ContactDAO } from '../database/ContactDAO';
import { NewDatabaseManager } from '../database/NewDatabaseManager';
import { common } from '@kit.AbilityKit';
import {
  getRelationshipTypeColor,
  getRelationshipTypeName, getRelationshipTypeTextColor, RelationshipType } from '../model/RelationshipType';

@Entry
@Component
struct ContactSelectionPage {
  @State contacts: Contact[] = [];
  @State isLoading: boolean = true;
  @State searchText: string = '';
  @State filteredContacts: Contact[] = [];

  private dbManager: NewDatabaseManager = new NewDatabaseManager();
  private contactDAO: ContactDAO = new ContactDAO(this.dbManager);

  async aboutToAppear() {
    // 初始化数据库
    const context = getContext(this) as common.UIAbilityContext;
    await this.dbManager.initDatabase(context);
    
    // 加载联系人数据
    await this.loadContacts();
  }

  async onPageShow() {
    await this.loadContacts();
  }

  async loadContacts() {
    try {
      this.isLoading = true;
      this.contacts = await this.contactDAO.getAllContacts();
      this.filteredContacts = this.contacts;
    } catch (error) {
      console.error('加载联系人失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 搜索联系人
  onSearchTextChange(text: string) {
    this.searchText = text;
    if (text.trim() === '') {
      this.filteredContacts = this.contacts;
    } else {
      this.filteredContacts = this.contacts.filter(contact => 
        contact.name.toLowerCase().includes(text.toLowerCase()) ||
        contact.relationship.toLowerCase().includes(text.toLowerCase())
      );
    }
  }

  // 选择联系人，跳转到情感时间轴
  selectContact(contact: Contact) {
    router.pushUrl({
      url: 'pages/EmotionalTimelinePage',
      params: {
        selectedContact: contact
      }
    }).catch((error: Error) => {
      console.error('跳转到情感时间轴失败:', error);
    });
  }

  // 创建新联系人
  createNewContact() {
    router.pushUrl({
      url: 'pages/profile/ContactFormPage',
      params: {
        isEdit: false,
        returnToTimeline: true
      }
    }).catch((error: Error) => {
      console.error('跳转到联系人创建页面失败:', error);
    });
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button() {
          Image($r('app.media.icon_back'))
            .width(24)
            .height(24)
            .fillColor('#182431')
        }
        .type(ButtonType.Circle)
        .backgroundColor('#F1F3F5')
        .width(40)
        .height(40)
        .onClick(() => {
          router.back();
        })

        Text('选择联系人')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位，保持标题居中
        Row().width(40).height(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#007DFF')
          
          Text('加载联系人中...')
            .fontSize(14)
            .fontColor('#99182431')
            .margin({ top: 12 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.filteredContacts.length === 0) {
        // 空状态
        Column() {
          Image($r('sys.media.ohos_ic_public_add'))
            .width(64)
            .height(64)
            .fillColor('#99182431')
          
          Text(this.contacts.length === 0 ? '暂无联系人' : '未找到匹配的联系人')
            .fontSize(16)
            .fontColor('#99182431')
            .margin({ top: 16 })
          
          if (this.contacts.length === 0) {
            Text('创建第一个联系人，开始记录你们的情感时间轴')
              .fontSize(14)
              .fontColor('#66182431')
              .margin({ top: 8 })
              .textAlign(TextAlign.Center)
            
            Button('创建联系人')
              .type(ButtonType.Capsule)
              .backgroundColor('#007DFF')
              .fontColor(Color.White)
              .fontSize(16)
              .width(120)
              .height(40)
              .margin({ top: 20 })
              .onClick(() => {
                this.createNewContact();
              })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding(32)
      } else {
        // 联系人列表
        List({ space: 12 }) {
          ForEach(this.filteredContacts, (contact: Contact) => {
            ListItem() {
              Row() {
                // 头像
                Row() {
                  if (contact.avatar && contact.avatar.trim() !== '') {
                    Text(contact.avatar)
                      .fontSize(24)
                  } else {
                    Text(contact.name.charAt(0))
                      .fontSize(20)
                      .fontColor('#007DFF')
                      .fontWeight(FontWeight.Medium)
                  }
                }
                .width(48)
                .height(48)
                .backgroundColor('#F0F8FF')
                .borderRadius(24)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)

                // 联系人信息
                Column() {
                  Text(contact.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#182431')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Text(getRelationshipTypeName(contact.relationship as RelationshipType))
                    .fontSize(12)
                    .fontColor(getRelationshipTypeTextColor(contact.relationship as RelationshipType))
                    .backgroundColor(getRelationshipTypeColor(contact.relationship as RelationshipType))
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .borderRadius(10)

                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })

                // 箭头
                Image($r('sys.media.ohos_ic_public_arrow_right'))
                  .width(16)
                  .height(16)
                  .fillColor('#99182431')
              }
              .width('100%')
              .height(72)
              .padding({ left: 16, right: 16 })
              .backgroundColor(Color.White)
              .borderRadius(12)
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                this.selectContact(contact);
              })
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
        .scrollBar(BarState.Off)
      }

      // 底部创建联系人按钮
      if (!this.isLoading && this.contacts.length > 0) {
        Row() {
          Button('创建新联系人')
            .type(ButtonType.Capsule)
            .backgroundColor('#F1F3F5')
            .fontColor('#007DFF')
            .fontSize(16)
            .width('100%')
            .height(48)
            .onClick(() => {
              this.createNewContact();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}